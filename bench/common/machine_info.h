#pragma once
// Captures machine state into a JSON string by shelling out to common Linux tools.
// Called once at benchmark startup; output is embedded in the emitted JSON.

#include <array>
#include <cstdio>
#include <sched.h>
#include <string>

namespace crucible {

namespace detail {

inline std::string shell(const char* cmd) {
    std::array<char, 512> buf;
    std::string out;
    FILE* fp = ::popen(cmd, "r");
    if (!fp) return "";
    while (std::fgets(buf.data(), static_cast<int>(buf.size()), fp))
        out += buf.data();
    ::pclose(fp);
    while (!out.empty() && (out.back() == '\n' || out.back() == '\r'))
        out.pop_back();
    // Escape for JSON: strip control chars, escape backslash and double-quote
    std::string safe;
    for (unsigned char c : out) {
        if (c < 0x20 || c == 0x7f) continue;  // drop all ASCII control chars
        if (c == '\\') { safe += "\\\\"; continue; }
        if (c == '"')  { safe += "\\\""; continue; }
        safe += static_cast<char>(c);
    }
    return safe;
}

// Returns the CPU affinity of the calling process as a compact range string,
// e.g. "4-7" or "0-7".  Reports what the kernel actually scheduled on, not
// what was requested via CLI flags or environment variables.
inline std::string cpu_affinity_string() {
    cpu_set_t set;
    CPU_ZERO(&set);
    if (sched_getaffinity(0, sizeof(set), &set) != 0)
        return "";

    std::string result;
    int range_start = -1;
    int range_end   = -1;

    auto flush = [&]() {
        if (range_start < 0) return;
        if (!result.empty()) result += ',';
        result += std::to_string(range_start);
        if (range_end > range_start) {
            result += '-';
            result += std::to_string(range_end);
        }
        range_start = range_end = -1;
    };

    for (int cpu = 0; cpu < CPU_SETSIZE; ++cpu) {
        if (CPU_ISSET(cpu, &set)) {
            if (range_start < 0)   range_start = cpu;
            range_end = cpu;
        } else {
            flush();
        }
    }
    flush();
    return result;
}

} // namespace detail

// Returns a JSON object string (no surrounding braces) for the "machine" field.
inline std::string machine_info_json() {
    using detail::shell;

    // head -1: guard against lscpu printing one line per socket/NUMA node
    const auto cpu      = shell("lscpu | grep 'Model name' | sed 's/.*: *//' | head -1");
    const auto phys     = shell("lscpu | grep '^Core(s) per socket' | awk '{print $NF}'");
    const auto logical  = shell("lscpu | grep '^CPU(s):' | awk 'NR==1{print $NF}'");
    const auto smt_raw  = shell("lscpu | grep '^Thread(s) per core' | awk '{print $NF}'");
    const auto ram_gb   = shell("awk '/MemTotal/{printf \"%.0f\", $2/1024/1024}' /proc/meminfo");
    // null when dmidecode is unavailable without sudo; renderer treats null as "not captured"
    const auto ram_mhz  = shell("dmidecode -t 17 2>/dev/null | awk '/Speed:.*MHz/{print $2; exit}'");
    const auto compiler = shell("gcc --version | head -1");
    const auto kernel   = shell("uname -r");
    const auto governor = shell("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown");
    // CRUCIBLE_TURBO is set by run_one.sh after verifying CPB state via cpupower.
    // Null means the caller did not verify — avoids asserting unobserved facts.
    const auto turbo_env = shell("echo \"$CRUCIBLE_TURBO\"");
    // isolated_cpus: kernel-level isolation (empty unless isolcpus= is on the cmdline)
    const auto iso_cpus    = shell("grep -o 'isolcpus=[^ ]*' /proc/cmdline | cut -d= -f2");
    // cpu_affinity: actual cpuset the process is running on (taskset, cset, or unrestricted)
    const auto cpu_affinity = detail::cpu_affinity_string();

    const bool smt_on   = (smt_raw != "1");

    std::string turbo_field;
    if      (turbo_env == "off") turbo_field = "false";
    else if (turbo_env == "on")  turbo_field = "true";
    else                          turbo_field = "null";

    return
        "\"cpu\":\""            + cpu      + "\","
        "\"cores_physical\":"   + (phys.empty()    ? "0" : phys)    + ","
        "\"cores_logical\":"    + (logical.empty() ? "0" : logical) + ","
        "\"smt_enabled\":"      + (smt_on ? "true" : "false")       + ","
        "\"ram_gb\":"           + (ram_gb.empty()  ? "0" : ram_gb)  + ","
        "\"ram_speed_mhz\":"    + (ram_mhz.empty() ? "null" : ram_mhz) + ","
        "\"compiler\":\""       + compiler  + "\","
        "\"kernel\":\""         + kernel   + "\","
        "\"governor\":\""       + governor + "\","
        "\"turbo\":"            + turbo_field + ","
        "\"isolated_cpus\":\""  + iso_cpus + "\","
        "\"cpu_affinity\":\""   + cpu_affinity + "\"";
}

} // namespace crucible
