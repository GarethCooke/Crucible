#pragma once
// Captures machine state into a JSON string by shelling out to common Linux tools.
// Called once at benchmark startup; output is embedded in the emitted JSON.

#include <array>
#include <cstdio>
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

} // namespace detail

// Returns a JSON object string (no surrounding braces) for the "machine" field.
inline std::string machine_info_json() {
    using detail::shell;

    const auto cpu      = shell("lscpu | grep 'Model name' | sed 's/.*: *//'");
    const auto phys     = shell("lscpu | grep '^Core(s) per socket' | awk '{print $NF}'");
    const auto logical  = shell("lscpu | grep '^CPU(s):' | awk 'NR==1{print $NF}'");
    const auto smt_raw  = shell("lscpu | grep '^Thread(s) per core' | awk '{print $NF}'");
    const auto ram_gb   = shell("awk '/MemTotal/{printf \"%.0f\", $2/1024/1024}' /proc/meminfo");
    const auto ram_mhz  = shell("dmidecode -t 17 2>/dev/null | awk '/Speed:.*MHz/{print $2; exit}'");
    const auto compiler = shell("gcc --version | head -1");
    const auto flags    = shell("echo \"$CXXFLAGS\"");
    const auto kernel   = shell("uname -r");
    const auto governor = shell("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown");
    const auto turbo_r  = shell("cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo 1");
    const auto iso_cpus = shell("grep -o 'isolcpus=[^ ]*' /proc/cmdline | cut -d= -f2");

    const bool smt_on   = (smt_raw != "1");
    const bool turbo_on = (turbo_r != "0");

    return
        "\"cpu\":\""           + cpu      + "\","
        "\"cores_physical\":"  + (phys.empty()    ? "0" : phys)    + ","
        "\"cores_logical\":"   + (logical.empty() ? "0" : logical) + ","
        "\"smt_enabled\":"     + (smt_on ? "true" : "false")       + ","
        "\"ram_gb\":"          + (ram_gb.empty()  ? "0" : ram_gb)  + ","
        "\"ram_speed_mhz\":"   + (ram_mhz.empty() ? "0" : ram_mhz)+ ","
        "\"compiler\":\""      + compiler  + "\","
        "\"compiler_flags\":\"" + (flags.empty() ? "-O3 -march=native" : flags) + "\","
        "\"kernel\":\""        + kernel   + "\","
        "\"governor\":\""      + governor + "\","
        "\"turbo\":"           + (turbo_on ? "true" : "false")     + ","
        "\"isolated_cpus\":\"" + iso_cpus + "\"";
}

} // namespace crucible
