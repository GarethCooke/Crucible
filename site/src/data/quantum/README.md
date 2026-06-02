# quantum/ data directory

**This directory is quantum-specific and is entirely outside the locked Crucible
performance schema** (the `machine` / `benchmarks` / `stats` shape used by demos
1–9). Nothing here should be consumed by `lib/perf-data.ts` or compared against
ns/op figures.

## File: `measuring-the-gap.json`

Schema identifier: `"schema": "quantum-measuring-the-gap-v1"`

### Top-level fields

| Field | Type | Description |
|---|---|---|
| `schema` | `string` | Schema version tag. Bump when the shape changes. |
| `data_status` | `"aer-only" \| "hardware-captured"` | `"aer-only"` while hardware numbers are null; flip to `"hardware-captured"` after the capture run. Gates all device-conditional rendering in the site. |
| `note` | `string` | Human-readable status note. |

### `capture_meta`

Metadata about the hardware run. All fields are `null` until the capture run is committed.

| Field | Type | Description |
|---|---|---|
| `backend` | `{ name: string; num_qubits: number } \| null` | IBM backend identifier and qubit count. |
| `physical_qubits` | `number[] \| null` | Pinned physical qubit layout used for this capture. Layout-dependent; recorded for reproducibility. |
| `calibration_timestamp` | `string \| null` | ISO-8601 timestamp of the backend calibration snapshot at capture time. |
| `shots` | `number` | Measurement shots per circuit execution. |
| `ns` | `number[]` | The qubit counts swept (e.g. `[3, 4, 5]`). |
| `captured_at` | `string` | ISO-8601 timestamp of when `capture.py` was run. |

### `ns_sweep`

Per-N success-probability data. Each series is an array of points keyed by `n` (qubit count) and `N` (search-space size, `N = 2^n`).

#### Point shape (all series except `classical_floor` / `random_floor`)

| Field | Type | Description |
|---|---|---|
| `n` | `number` | Qubit count. |
| `N` | `number` | Search-space size (`2^n`). |
| `mean` | `number \| null` | Mean P(success) across all repeats. Null until captured. |
| `min` | `number \| null` | Minimum across repeats. |
| `max` | `number \| null` | Maximum across repeats. |
| `per_repeat` | `number[]` | Raw per-repeat values. Empty array until captured. |
| `status` | `string?` | `"hardware-capture-pending"` while null. Absent once captured. |

#### Series

| Series | Source | Description |
|---|---|---|
| `grover_ideal` | Aer (simulator) | Grover success rate on the noiseless ideal simulator. Reproducible without hardware. |
| `grover_device` | IBM QPU | Grover success rate on real quantum hardware. Null until capture. |
| `bv_ideal` | Aer (simulator) | Bernstein–Vazirani success rate on the ideal simulator. |
| `bv_device` | IBM QPU | BV success rate on real hardware. Null until capture. |
| `classical_floor` | Deterministic | Classical linear search always succeeds: P=1.0 by construction. |
| `random_floor` | Analytic | Random-guess floor: `1/N`. Used as a lower reference line in charts. |

### `mitigation`

Grover device success with error mitigation off vs on (dynamical decoupling + measurement twirling). All values null until hardware capture.

| Field | Type | Description |
|---|---|---|
| `note` | `string` | Status note. |
| `off` | `MitigationPoint[]` | Per-N results with mitigation disabled. Same point shape as `ns_sweep`. |
| `on` | `MitigationPoint[]` | Per-N results with mitigation enabled. |

The site derives per-N significance from the `[min, max]` spread of `off` vs `on` at each N. If the intervals overlap, no effect is claimed. If disjoint, the signed difference `off−on` is shown. No directional claim is rendered while these values are null.

### `teaching_sweep`

Aer-only data showing the amplitude-amplification oscillation for a fixed N. No QPU cost.

| Field | Type | Description |
|---|---|---|
| `n` | `number` | Qubit count for this sweep. |
| `N` | `number` | Search-space size. |
| `marked` | `string` | Binary string of the marked item. |
| `note` | `string` | Description. |
| `curve` | `{ iters: number; p_marked: number }[]` | P(marked) at each Grover iteration count. Shows over-rotation past the optimal. |

### `circuit_depth`

Transpiled circuit depth and two-qubit gate counts, used to explain the noise mechanism.

| Field | Type | Description |
|---|---|---|
| `grover` | `DepthPoint[]` | Per-N Grover circuit stats. |
| `bv` | `DepthPoint[]` | Per-N BV circuit stats. |

#### `DepthPoint`

| Field | Type | Description |
|---|---|---|
| `n` / `N` | `number` | Qubit count / search-space size. |
| `optimal_iters` | `number?` | Grover-only: optimal iteration count `≈ π/4·√N`. |
| `depth` | `number` | Aer-transpiled circuit depth. On real hardware depth is higher due to routing. |
| `two_qubit_gates` | `number` | Two-qubit gate count after transpilation. Primary driver of accumulated error. |

### `raw_archive_paths`

`string[]` — Paths to committed raw job-result archives alongside this JSON. Empty until the hardware capture run is committed. Populated by `quantum/capture.py` after a successful hardware run.
