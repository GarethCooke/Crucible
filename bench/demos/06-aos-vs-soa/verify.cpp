// Standalone codegen verification for demo 06 kernels.
//
// Usage:
//   verify_06_aos_vs_soa <path/to/bench_06_aos_vs_soa>
//
// Alternatively, use the --verify-codegen flag on the main binary itself:
//   bench_06_aos_vs_soa aos-scalar --verify-codegen
//
// Checks:
//   scan_aos        — must NOT emit ymm packed-double ops (strided AoS is not SIMD-friendly)
//   scan_soa_scalar — must NOT emit ymm packed-double ops (no-tree-vectorize is in effect)
//   scan_soa_autovec — MUST emit ymm packed-double ops (auto-vectorisation enabled)

#include <cstdio>
#include <cstring>
#include <sstream>
#include <string>

static std::string run_objdump(const char* bin_path) {
    char cmd[4096 + 64];
    std::snprintf(cmd, sizeof(cmd),
        "objdump -d -C --no-show-raw-insn '%s' 2>&1", bin_path);
    FILE* fp = popen(cmd, "r");
    if (!fp) return "";
    std::string out;
    char line[512];
    while (std::fgets(line, sizeof(line), fp))
        out += line;
    pclose(fp);
    return out;
}

static std::string extract_fn(const std::string& disasm, const char* sym) {
    std::string marker = std::string("<") + sym;
    std::string fn_asm;
    bool in_fn = false;
    std::istringstream ss(disasm);
    std::string ln;
    while (std::getline(ss, ln)) {
        if (!in_fn) {
            // Only match function header lines (column 0), not call sites.
            // Headers look like: "0000addr <sym...>:"
            if (!ln.empty() && ln[0] != ' ' && ln[0] != '\t'
                    && ln.find(marker) != std::string::npos)
                in_fn = true;
        } else {
            if (ln.empty() || (ln[0] != ' ' && ln[0] != '\t'
                               && ln.find(marker) == std::string::npos
                               && ln.find('<') != std::string::npos))
                break;
            fn_asm += ln + "\n";
        }
    }
    return fn_asm;
}

static bool has_ymm_packed(const std::string& asm_) {
    return asm_.find("ymm") != std::string::npos &&
           (asm_.find("vaddpd") != std::string::npos ||
            asm_.find("vmovapd") != std::string::npos ||
            asm_.find("vmulpd") != std::string::npos ||
            asm_.find("vperm") != std::string::npos);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::fprintf(stderr,
            "Usage: verify_06_aos_vs_soa <path/to/bench_06_aos_vs_soa>\n");
        return 1;
    }

    const char* bin = argv[1];
    std::fprintf(stderr, "Verifying codegen in: %s\n\n", bin);

    const std::string disasm = run_objdump(bin);
    if (disasm.empty()) {
        std::fprintf(stderr, "ERROR: objdump failed or produced no output\n");
        return 1;
    }

    struct Check {
        const char* sym;
        const char* variant;
        bool        expect_ymm;
        const char* description;
    };

    Check checks[] = {
        { "scan_aos",         "aos-scalar",
          false, "strided 128 B access must NOT emit ymm packed-double" },
        { "scan_soa_scalar",  "soa-scalar",
          false, "no-tree-vectorize must suppress ymm packed-double" },
        { "scan_soa_autovec", "soa-autovec",
          true,  "auto-vectorised column loop MUST emit ymm packed-double" },
    };

    int exit_code = 0;

    for (const auto& c : checks) {
        const std::string fn_asm = extract_fn(disasm, c.sym);
        if (fn_asm.empty()) {
            std::fprintf(stdout,
                "  [FAIL] %s: symbol not found in disassembly\n", c.sym);
            exit_code = 1;
            continue;
        }

        bool got_ymm = has_ymm_packed(fn_asm);
        bool pass = c.expect_ymm ? got_ymm : !got_ymm;

        std::fprintf(stdout, "  [%s] %s (%s)\n        %s\n",
            pass ? "PASS" : "FAIL",
            c.sym, c.variant, c.description);

        if (!pass) {
            exit_code = 1;
            if (c.expect_ymm)
                std::fprintf(stdout,
                    "        PROBLEM: expected ymm packed-double but found none.\n"
                    "        Check that -O3 -march=native are applied to this TU.\n");
            else
                std::fprintf(stdout,
                    "        PROBLEM: found ymm packed-double — vectorisation leaked.\n"
                    "        Confirm __attribute__((optimize(\"no-tree-vectorize\"))) "
                    "is on the function.\n");
        }
    }

    std::fprintf(stdout, "\nCodegen verification %s\n",
        exit_code == 0 ? "PASSED" : "FAILED");
    return exit_code;
}
