#pragma once
// Captures machine state into a JSON string by shelling out to common Linux tools.
// Called once at benchmark startup; output is embedded in the emitted JSON.

#include <array>
#include <cstdio>
#include <cstring>
#include <sched.h>
#include <string>

namespace crucible {

namespace detail {

// Shared popen/fgets/pclose/trim plumbing used by shell() and shell_multiline().
inline std::string shell_capture(const char* cmd) {
    std::array<char, 512> buf;
    std::string out;
    FILE* fp = ::popen(cmd, "r");
    if (!fp) return out;
    while (std::fgets(buf.data(), static_cast<int>(buf.size()), fp))
        out += buf.data();
    ::pclose(fp);
    while (!out.empty() && (out.back() == '\n' || out.back() == '\r'))
        out.pop_back();
    return out;
}

// Escape for single-line JSON: drop control chars, escape \ and ".
inline std::string shell(const char* cmd) {
    std::string safe;
    for (unsigned char c : shell_capture(cmd)) {
        if (c < 0x20 || c == 0x7f) continue;
        if (c == '\\') { safe += "\\\\"; continue; }
        if (c == '"')  { safe += "\\\""; continue; }
        safe += static_cast<char>(c);
    }
    return safe;
}

// Like shell() but preserves newlines as \n and tabs as spaces — for multiline output.
inline std::string shell_multiline(const char* cmd) {
    std::string safe;
    for (unsigned char c : shell_capture(cmd)) {
        if (c == '\n' || c == '\r') { safe += "\\n"; continue; }
        if (c == '\t')              { safe += ' ';   continue; }
        if (c < 0x20 || c == 0x7f) continue;
        if (c == '\\') { safe += "\\\\"; continue; }
        if (c == '"')  { safe += "\\\""; continue; }
        safe += static_cast<char>(c);
    }
    return safe;
}

// Reads /sys/devices/system/cpu/cpufreq/boost (acpi-cpufreq: "1"=on, "0"=off).
// Returns "on", "off", or "" if the node is absent or unreadable (e.g. amd_pstate_epp).
inline std::string boost_from_cpufreq_boost() {
    FILE* f = ::fopen("/sys/devices/system/cpu/cpufreq/boost", "r");
    if (!f) return "";
    char buf[8] = {};
    bool ok = (::fgets(buf, sizeof(buf), f) != nullptr);
    ::fclose(f);
    if (!ok) return "";
    std::string v(buf);
    while (!v.empty() && (v.back() == '\n' || v.back() == '\r' || v.back() == ' '))
        v.pop_back();
    if (v == "1") return "on";
    if (v == "0") return "off";
    return "";
}

// Parses "CPU max MHz" from lscpu output. Returns integer MHz, or 0 if unavailable.
// This reflects the CPU's hardware maximum — changes with BIOS CPB state: ~3900 with
// CPB off, ~4560 with CPB on (Ryzen 7 3800X). This is the ground truth for boost state.
inline int max_freq_mhz_from_lscpu() {
    std::string raw = shell_capture("lscpu 2>/dev/null | awk '/CPU max MHz/{gsub(/\\..*/, \"\", $NF); print $NF+0}'");
    if (raw.empty()) return 0;
    int val = 0;
    for (char c : raw) {
        if (c >= '0' && c <= '9') val = val * 10 + (c - '0');
        else if (val > 0) break;
    }
    return val;
}

// Reads base_frequency for cpu0 from sysfs (amd_pstate driver, value in KHz → MHz).
// Returns MHz as integer, or 0 if the node is absent (acpi-cpufreq does not expose it).
inline int base_freq_mhz_from_sysfs() {
    FILE* f = ::fopen("/sys/devices/system/cpu/cpu0/cpufreq/base_frequency", "r");
    if (!f) return 0;
    unsigned long khz = 0;
    bool ok = (::fscanf(f, "%lu", &khz) == 1);
    ::fclose(f);
    if (!ok || khz == 0) return 0;
    return static_cast<int>(khz / 1000);
}

// Read the kernel's effective isolated CPU set from /sys/devices/system/cpu/isolated.
// Returns the trimmed contents (e.g. "1-7") or empty string if unavailable.
inline std::string isolated_cpus_from_sys() {
    FILE* f = ::fopen("/sys/devices/system/cpu/isolated", "r");
    if (!f) return "";
    char buf[256] = {};
    if (::fgets(buf, sizeof(buf), f) == nullptr) {
        ::fclose(f);
        return "";
    }
    ::fclose(f);
    std::string val(buf);
    while (!val.empty() && (val.back() == '\n' || val.back() == '\r' || val.back() == ' '))
        val.pop_back();
    return val;
}

// Parse isolcpus= value directly from /proc/cmdline.
// Returns the verbatim value (e.g. "1-7") or empty string if not present.
inline std::string isolated_cpus_from_cmdline() {
    FILE* f = ::fopen("/proc/cmdline", "r");
    if (!f) return "";
    char line[4096] = {};
    if (::fgets(line, sizeof(line), f) == nullptr) {
        ::fclose(f);
        return "";
    }
    ::fclose(f);
    const char* tok = std::strstr(line, "isolcpus=");
    if (!tok) return "";
    tok += 9;  // skip "isolcpus="
    std::string val;
    while (*tok && *tok != ' ' && *tok != '\t' && *tok != '\n' && *tok != '\r')
        val += *tok++;
    return val;
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
    using detail::shell_multiline;

    // head -1: guard against lscpu printing one line per socket/NUMA node
    const auto cpu      = shell("lscpu | grep 'Model name' | sed 's/.*: *//' | head -1");
    const auto phys     = shell("lscpu -b -p=core | grep -v '^#' | sort -u | wc -l | tr -dc '0-9'");
    const auto logical  = shell("lscpu | grep '^CPU(s):' | awk 'NR==1{print $NF}'");
    const auto smt_raw  = shell("lscpu | grep '^Thread(s) per core' | awk '{print $NF}'");
    const auto ram_gb   = shell("awk '/MemTotal/{printf \"%.0f\", $2/1024/1024}' /proc/meminfo");
    // null when dmidecode is unavailable without sudo; renderer treats null as "not captured"
    const auto ram_mhz  = shell("dmidecode -t 17 2>/dev/null | awk '/Speed:.*MHz/{print $2; exit}'");
    const auto compiler = shell("gcc --version | head -1");
    const auto kernel   = shell("uname -r");
    const auto governor = shell("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo unknown");
    // Derive boost state from kernel sysfs — never from an env assertion.
    // Primary: /sys/devices/system/cpu/cpufreq/boost (acpi-cpufreq, "1"=on/"0"=off).
    // Cross-check: lscpu MAXMHZ vs amd_pstate base_frequency; MAXMHZ reflects BIOS CPB
    // state directly (CPB off → ~3900, CPB on → ~4560 on Ryzen 7 3800X) and overrides
    // the software toggle if the two disagree.
    const auto boost_sysfs = detail::boost_from_cpufreq_boost();
    const int freq_max     = detail::max_freq_mhz_from_lscpu();
    const int freq_base    = detail::base_freq_mhz_from_sysfs();

    // isolated_cpus: parse requested value from /proc/cmdline; read effective value
    // from /sys/devices/system/cpu/isolated (kernel's view, may exclude core 0).
    const auto iso_requested = detail::isolated_cpus_from_cmdline();
    const auto iso_effective = detail::isolated_cpus_from_sys();
    const auto iso_source = (!iso_requested.empty() && !iso_effective.empty())
                            ? "cmdline+probe"
                            : (!iso_requested.empty() ? "cmdline" : "cgroup");
    // iso_cpus: backward-compat field; prefer effective when available
    const auto iso_cpus = !iso_effective.empty() ? iso_effective : iso_requested;

    // cpu_affinity: actual cpuset the process is running on (taskset, cset, or unrestricted)
    const auto cpu_affinity = detail::cpu_affinity_string();

    // lscpu --extended: makes CCX topology visible; condensed to one line via \n escaping
    const auto lscpu_ext = shell_multiline("lscpu --extended 2>/dev/null");

    // arch: ISA family (e.g. "x86_64", "aarch64") — distinguishes the two rigs.
    const auto arch = shell("uname -m");
    // soc: SoC/board model from device-tree (Pi: "Raspberry Pi 5 Model B Rev 1.0").
    // Absent on x86 (no device-tree); 2>/dev/null + tr strip the NUL terminator.
    const auto soc  = shell("tr -d '\\0' < /proc/device-tree/model 2>/dev/null");

    const bool smt_on   = (smt_raw != "1");

    // Resolve turbo: MAXMHZ comparison is ground truth when both signals are available
    // (it catches BIOS CPB on even when the software sysfs toggle is off).
    std::string turbo_field;
    std::string turbo_source;

    const bool have_freq_compare = (freq_max > 0 && freq_base > 0);
    const bool freq_says_boosted = have_freq_compare && (freq_max > freq_base * 105 / 100);

    if (have_freq_compare) {
        turbo_field  = freq_says_boosted ? "true" : "false";
        turbo_source = boost_sysfs.empty() ? "freq_compare" : "freq_compare+cpufreq/boost";
    } else if (!boost_sysfs.empty()) {
        turbo_field  = (boost_sysfs == "on") ? "true" : "false";
        turbo_source = "cpufreq/boost";
    } else {
        turbo_field  = "null";
        turbo_source = "unavailable";
    }

    return
        "\"cpu\":\""                  + cpu      + "\","
        "\"cores_physical\":"         + (phys.empty()    ? "0" : phys)    + ","
        "\"cores_logical\":"          + (logical.empty() ? "0" : logical) + ","
        "\"smt_enabled\":"            + (smt_on ? "true" : "false")       + ","
        "\"ram_gb\":"                 + (ram_gb.empty()  ? "0" : ram_gb)  + ","
        "\"ram_speed_mhz\":"          + (ram_mhz.empty() ? "null" : ram_mhz) + ","
        "\"compiler\":\""             + compiler  + "\","
        "\"kernel\":\""               + kernel   + "\","
        "\"governor\":\""             + governor + "\","
        "\"turbo\":"                  + turbo_field + ","
        "\"turbo_source\":\""         + turbo_source + "\","
        "\"freq_max_mhz\":"           + (freq_max  > 0 ? std::to_string(freq_max)  : "null") + ","
        "\"freq_base_mhz\":"          + (freq_base > 0 ? std::to_string(freq_base) : "null") + ","
        "\"isolated_cpus\":\""              + iso_cpus      + "\","
        "\"isolated_cpus_requested\":\""    + iso_requested + "\","
        + (iso_effective.empty() ? "" : "\"isolated_cpus_effective\":\"" + iso_effective + "\",")
        + "\"isolated_cpus_source\":\""     + iso_source    + "\","
        "\"cpu_affinity\":\""               + cpu_affinity  + "\","
        "\"lscpu_extended\":\""             + lscpu_ext     + "\","
        "\"arch\":\""                       + arch          + "\","
        "\"soc\":"                          + (soc.empty() ? "null" : "\"" + soc + "\"");
}

} // namespace crucible
