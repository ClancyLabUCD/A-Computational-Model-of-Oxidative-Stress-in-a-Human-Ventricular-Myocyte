# Figure 8: ETC ROS Leak Modulation of Calcium Handling and ROS Production

This folder contains the simulation code and plotting script used to
characterize how the fraction of electron transport chain flux
contributing to mitochondrial ROS production ("ETC ROS leak") drives
rate-dependent APD prolongation, calcium accumulation, and cytosolic
ROS generation across pacing frequencies.

## Overview

To investigate the model-predicted effects of mitochondrial ROS
production on electrophysiology and calcium dynamics, the ETC ROS leak
parameter, representing the fraction of electron transport chain flux
(JETC) contributing to mitochondrial ROS production ([O2.-]m), was
varied from 0.40 to 0.60 (increment 0.01) at cycle lengths of 2000,
1000, 750, and 500 ms. For each combination of ETC ROS leak and cycle
length, the model was run to steady state (see Numerical
Implementation), and APD90, peak cytosolic calcium ([Ca2+]i), peak
mitochondrial calcium ([Ca2+]m), and peak cytosolic superoxide ([O2.-]i)
were extracted.

Representative time-domain traces of membrane voltage, cytosolic
calcium, mitochondrial calcium, and cytosolic ROS were generated at a
fixed ETC ROS leak of 0.55 across all cycle lengths to illustrate
rate-dependent effects at a single representative leak value.

The ETC ROS leak range (0.40-0.60) was selected to span a physiologically
relevant range of cytosolic superoxide concentrations without producing
unbounded accumulation, since values approaching the upper end of this
range across all tested cycle lengths still allowed the model to reach a
stable steady state under the convergence criteria described in
Numerical Implementation.

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_Fig8_sweep.cpp` | Sweeps ETC_Leak from 0.40 to 0.60 (step 0.01) at each of 4 pacing conditions (CL = 500, 750, 1000, 2000 ms). Each leak value runs from a starting IC until the model reaches genuine beat-to-beat steady state (peak cai/Cam/ROSi converge within an absolute threshold), fails (NaN), hits a ROSm floor, or hits a safety cap of 200,000 beats. Produces the summary data underlying **Fig. 8B, 8D, 8F, 8H**. |
| `ZukowskiECMROS_Fig8_ETC55.cpp` | Runs 2 beats at a fixed ETC_Leak = 0.55 for each of the 4 pacing conditions, each starting from that pacing rate's own distinct steady-state IC at this leak value. Produces the representative traces for **Fig. 8C, 8E, 8G, 8I**. |
| `Fig8Plot.m` | MATLAB script that reads both the sweep summaries and the ETC_Leak=0.55 representative traces and generates all Figure 8 panels. |

## How to run

### Sweep (Fig. 8B, D, F, H)

```bash
g++ -O2 -o ZukowskiECMROS_Fig8_sweep ZukowskiECMROS_Fig8_sweep.cpp
./ZukowskiECMROS_Fig8_sweep
```

**Note:** this sweep is computationally heavy. It runs 4 pacing
conditions x 21 ETC_Leak values = 84 total runs, each simulated until
genuine convergence (up to 200,000 beats as a safety cap). Running this
overnight or in the background is recommended.

For each pacing condition, this writes one summary file with one row per
ETC_Leak value:

- `ETCLeak_sweep_summary_500CL.txt`
- `ETCLeak_sweep_summary_750CL.txt`
- `ETCLeak_sweep_summary_1000CL.txt`
- `ETCLeak_sweep_summary_2000CL.txt`

Each summary row contains: `ETC_Leak, status, fail_time_ms, SS_APD90,
SS_peak_Cai, SS_peak_Cam, SS_peak_ROSi`. The sweep halts for a given
pacing condition at the first ETC_Leak value that fails (NaN or ROSm
floor), and writes a failure trace file
(`failure_trace_<CL>CL_ETC_<leak>.txt`) only when that occurs.

Note: the 500CL, 750CL, and 1000CL conditions in this sweep share the
same starting IC by design. Because each leak value is run to genuine
convergence rather than a fixed beat count, each pacing condition
settles into its own correct steady state regardless of starting IC; the
2000CL condition uses its own distinct starting IC.

### Representative traces at ETC_Leak=0.55 (Fig. 8C, E, G, I)

```bash
g++ -O2 -o ZukowskiECMROS_Fig8_ETC55 ZukowskiECMROS_Fig8_ETC55.cpp
./ZukowskiECMROS_Fig8_ETC55
```

This runs quickly (2 beats per condition) and writes:

- `output_500CL_55.txt`
- `output_750CL_55.txt`
- `output_1000CL_55.txt`
- `output_2000CL_55.txt`

Each file has 5 columns: `t, v, cai, Cam, ROSi`. Unlike the sweep code,
each of these 4 conditions starts from its own genuinely distinct
steady-state IC specific to ETC_Leak=0.55.

### Plotting

Run `Fig8Plot.m` in MATLAB from the same folder as both sets of
simulation outputs. The script reads the 4 sweep summary files to
generate the ETC_Leak-dependence panels (8B, 8D, 8F, 8H) and the 4
ETC_Leak=0.55 trace files to generate the representative trace panels
(8C, 8E, 8G, 8I).

## Notes

- ETC ROS leak represents the fraction of JETC contributing to
  mitochondrial ROS production; it is not a clamped/fixed ROS
  concentration (unlike the Figure 5-7 codes) - ROSi is fully dynamic
  and integrated in both codes here, and steady-state ROS concentration
  is an emergent output of the model at each ETC_Leak value, not an
  input.
- The sweep code's steady-state detection compares beat-to-beat peak
  cai, Cam, and ROSi against an absolute threshold (1e-7); a run is
  classified as `steady_state`, `NaN` (failure), `ROSm_floor`, or
  `max_beats_reached` (safety cap only reached, not true convergence).
  Check the `status` column in each summary file before treating a row
  as a valid steady-state result.
- The 500ms (fastest) pacing condition shows the most pronounced
  nonlinear amplification in peak [Ca2+]i between ETC_Leak=0.40 and
  0.55, consistent with a pacing-dependent threshold for calcium
  overload at higher ROS levels.
