# Handover — methodology correction note + commitment-#2 rewrite

For the session that lands the public correction, **after** the re-derivation and the hostile cross-read are complete. Part A (commitment-#2 rewrite) is finalisable now — the new mechanism is known and shipped. Part B (the correction note) is drafted with marked placeholders that can only be filled once the cross-read findings and the per-demo re-derivation results are in. Both edit `site/src/app/methodology/page.tsx` (static JSX; preserve the surrounding component structure and hard-coded heading `id`s — `rehype` plugins don't touch this page).

## Context

The Machine 1 corpus (demos 01–08) was originally captured with CPU boost silently enabled while the methodology claimed "turbo off." Root cause: `machine.turbo` was echoed from the `CRUCIBLE_TURBO` env var (operator intent), not measured. Detection has since been rewritten to real sysfs signals (per-CPU `cpb` authoritative; MAXMHZ advisory — it reads 4560 on this acpi-cpufreq board regardless of boost state), a capture gate added, and the corpus recaptured at a pinned 3900 MHz. Full incident detail in `crucible-cross-read-handover.md`.

---

## Part A — commitment #2 rewrite (final; ready to apply)

The current commitment #2 ("Turbo Boost disabled") describes the dead mechanism — `cpupower frequency-info` verification, `CRUCIBLE_TURBO=off` exported into `machine.turbo`, fail-closed on indeterminacy. None of that is how it works now, and the env-var→field path it describes _was the bug_. Replace the body of the commitment-#2 block with this prose (slot into the existing JSX structure):

> **Turbo Boost disabled.** Core Performance Boost is disabled in BIOS, pinning the cores to their 3900 MHz base clock. Boost state is _measured from the kernel_, never asserted: each capture reads the per-CPU `cpb` flag (`/sys/devices/system/cpu/cpu*/cpufreq/cpb`) — authoritative on this AMD `acpi-cpufreq` board — and cross-checks it against the top entry of `scaling_available_frequencies`. The result and the signal it came from are recorded in every JSON as `machine.turbo` and `machine.turbo_source`. A hard capture-time gate aborts the run before any benchmark executes if boost is detected as enabled, so a boosted capture cannot be taken silently.
>
> Note that `cpuinfo_max_freq` / `lscpu` MAXMHZ is **not** used to infer boost state: on this board it reports the silicon's 4560 MHz ceiling whether or not boost is enabled, so it is recorded as `machine.freq_max_advertised_mhz` (advisory) while `machine.freq_max_available_mhz` — the highest real P-state, 3900 MHz with boost off — is the value that tracks state. Where no boost signal is exposed (e.g. the AArch64 rig), `machine.turbo` is recorded as `null` rather than guessed. Boost obscures the true steady-state throughput the predictor and cache hierarchy deliver at nominal frequency.

End the block with a forward pointer to the Corrections section (Part B): one line, e.g. _"An earlier version of this pipeline derived turbo state from an environment variable rather than measuring it; see Corrections."_

---

## Part B — correction note (draft; fill placeholders post-cross-read)

**Placement.** A dated **Corrections** section on the methodology page is the canonical home — discoverable, permanent, and the natural place a sceptical reader looks. Add it as a new `<h2 id="corrections">` section. Per-post correction footers are optional and can be deferred; the methodology Corrections entry is the single source of record.

**Draft text** (fill the bracketed placeholders from the cross-read findings doc, the per-demo re-derivation results, and the demo-02 old-counter audit):

> ## Corrections
>
> **[DATE] — Boost state in the original Machine 1 corpus.**
>
> The benchmarks for demos 01–08, as originally published, were captured with AMD Core Performance Boost **enabled**, despite this page and each post stating it was disabled. The cause was a measurement defect: `machine.turbo` was recorded from an operator-set environment variable (`CRUCIBLE_TURBO`) — an assertion of intent, not a reading of hardware — while the `lscpu` output committed in the same machine blocks showed the boost ceiling active, contradicting the claim. It surfaced during setup for a later piece of work, when the advertised maximum frequency was noticed to be the boost ceiling on a rig that should have been pinned to base.
>
> The pipeline now derives boost state from kernel sysfs signals (per-CPU `cpb`, cross-checked against the available-frequency list), gates every capture on boost being off, and records which signal verified it. The full Machine 1 corpus was recaptured at the controlled 3900 MHz base clock.
>
> **Effect on results.** The comparisons each post is built on are same-session speedup ratios, in which both arms ran under identical conditions. [PLACEHOLDER — state the cross-read verdict: "these are unchanged" / "these changed as follows: …". Do not write "unchanged" unless the re-derivation actually showed that for every demo.] Absolute figures (ns/op, throughput) are now approximately [PLACEHOLDER — X]% lower than originally published, reflecting the true base clock rather than a boosted one. [PLACEHOLDER — demo-02 line: the L1 cache figures in demo 02 were separately affected by a performance-counter event that did not resolve on this hardware in the original capture; the recaptured figures use `L1-dcache-load-misses`. State the audit's conclusion on the original figures' validity.] [PLACEHOLDER — any other specific corrections the cross-read surfaced.]
>
> The raw `lscpu` capture committed alongside every result is what made this auditable: the underlying data was honest even where the derived field was not. The detection logic that replaced it is described under [Turbo Boost disabled](#commitments) above.

## Fill instructions

- **Effect-on-results / ratios:** take verbatim from the cross-read's go/no-go and the per-demo re-derivation outcomes. If any ratio shifted enough to change a post's framing, name it here rather than claiming blanket invariance — the integrity of the note depends on this being literally true.
- **Absolute % figure:** the boost ceiling was ~4560 vs 3900 base (~15–17% headroom), but the _effective_ old clock under sustained single-core load may have been below the 4560 ceiling — derive the real delta from a representative old-vs-new median pair, don't assume the nominal ratio.
- **Demo-02 line:** pull the conclusion from that demo's re-derivation session (was the old counter figure real, null, or wrong?).

## Sequencing / out of scope

- Apply Part A and Part B in the **same change that merges the recaptured corpus** — the page must not describe the new mechanism while old (boosted) numbers are still live, nor vice versa.
- Tone: matter-of-fact, owning, technical; no grovelling and no defensiveness. For this audience the correction is a credibility gain — the story is "our committed raw data caught our derived field lying, here is the audit and the hardened pipeline."
- Not here: per-post correction footers (optional, defer), the quantum special edition, demo 09.
