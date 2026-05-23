# Demo 06 preflight calibration — AoS vs SoA

## Purpose

This is §4 of the demo-06 plan: a sparse calibration run against the formal
pipeline (built harness, full isolation), confirming that the §1 pilot's
findings reproduce before committing the headline-capture budget (§6).

Run this before the headline sweep. If P1, P2, or P3 fail, stop and
diagnose rather than proceeding to the 135-cell headline.

---

## 1. Date and machine state

*(To be filled in when the preflight is run on the reference machine.)*

```
Date:
Machine: AMD Ryzen 7 3800X (Zen 2)
Turbo: off (BIOS CPB, /sys/devices/system/cpu/cpufreq/boost == 0)
Governor: performance
SMT: off
Shield: sudo cset shield --reset called before session
isolcpus: 0-7 (GRUB entry)
Benchmark thread: core 4 (CCX1)
```

---

## 2. Procedure

```bash
# 1. Build
cmake --build bench/build --clean-first

# 2. Codegen verification
taskset -c 4 ./bench/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa \
    aos-scalar --verify-codegen

# 3. Sparse calibration grid:
#    3 variants × 3 N values × 5 K values × 3 iterations
#    N: {4096, 131072, 1048576}

for VARIANT in aos-scalar soa-scalar soa-autovec; do
  for N in 4096 131072 1048576; do
    for K in 1 2 4 8 16; do
      sudo -E cset shield --exec -- taskset -c 4 \
        ./bench/build/demos/06-aos-vs-soa/bench_06_aos_vs_soa \
        "${VARIANT}" --n "${N}" --k "${K}" --iterations 3 \
        | grep -v '^cset:' > "preflight-${VARIANT}-n${N}-k${K}.json"
    done
  done
done
```

---

## 3. Codegen verification result

*(Paste --verify-codegen output here.)*

```
[PASS/FAIL] scan_aos (aos-scalar): ...
[PASS/FAIL] scan_soa_scalar (soa-scalar): ...
[PASS/FAIL] scan_soa_autovec (soa-autovec): ...
```

---

## 4. P1 — Bandwidth-amplification ratios at N = 1 048 576

AoS/SoA ratio = `aos-scalar.ns_per_op.median / soa-scalar.ns_per_op.median`

| K  | Model | Pilot (3800X §8) | Calibration | PASS/FAIL threshold  |
|----|-------|------------------|-------------|----------------------|
| 1  | 8.0×  | 6.79×            | *(TBD)*     | ≥ 5.0× or FAIL       |
| 2  | 4.0×  | 3.46×            | *(TBD)*     | ≥ 2.8× or FAIL       |
| 4  | 2.0×  | 1.52×            | *(TBD)*     | ≥ 1.3× or FAIL       |
| 8  | 1.0×  | 1.03×            | *(TBD)*     | 0.95–1.10× or FAIL   |
| 16 | 1.0×  | 1.00×            | *(TBD)*     | 0.95–1.05× or FAIL   |

**P1 result:** *(PASS / FAIL — fill in after run)*

---

## 5. P2 — DRAM cliff at the L3 boundary (aos-scalar, K = 1)

`ns_per_op.median(N=1048576) / ns_per_op.median(N=4096)` for `aos-scalar`, K = 1.

| Metric        | Pilot (3800X §8)           | Calibration | PASS/FAIL threshold |
|---------------|----------------------------|-------------|---------------------|
| N=4096 (L2)   | ~1.58 ns/element           | *(TBD)*     | —                   |
| N=1048576 (DRAM) | ~5.24 ns/element        | *(TBD)*     | —                   |
| Cliff ratio   | **3.32×**                  | *(TBD)*     | ≥ 2.5× or FAIL      |

**P2 result:** *(PASS / FAIL — fill in after run)*

---

## 6. P3 — SoA scalar vs SoA autovec at (N = 1 048 576, K = 16)

`soa-scalar.ns_per_op.median / soa-autovec.ns_per_op.median` — measures
the SIMD speed-up (AVX2 on Zen 2, expected 2–4× for double-precision sum).

| Metric                    | Expected | Calibration | PASS/FAIL threshold          |
|---------------------------|----------|-------------|------------------------------|
| soa-scalar (K=16, DRAM)   | —        | *(TBD)*     | —                            |
| soa-autovec (K=16, DRAM)  | —        | *(TBD)*     | —                            |
| Scalar/autovec ratio      | 2–4×     | *(TBD)*     | ≥ 1.5× or FAIL (re-verify codegen) |

**P3 result:** *(PASS / FAIL — fill in after run)*

---

## 7. Divergences from pilot

*(If any P1/P2/P3 numbers differ significantly from the pilot, note here.)*

---

## 8. Recommendation

*(PROCEED to §6 headline capture / STOP and diagnose — fill in after run.)*
