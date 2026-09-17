# Figure 11: Population Modeling of DOX and IKr Block on Pause-Dependent Arrhythmia Susceptibility

This folder contains the population (virtual cell cohort) simulation
code, condition-specific outputs, and plotting script used to
investigate whether DOX-induced oxidative stress and pharmacological
IKr block combine to increase arrhythmia susceptibility following a
pacing pause.

## Overview

Cancer patients treated with DOX are frequently co-administered
medications known to prolong the QT interval through block of the
rapid delayed rectifier potassium current (IKr) (Agnihotri et al.,
2024; Ramasubbu et al., 2025). To investigate whether DOX-induced
oxidative stress and pharmacological IKr block combine to increase
arrhythmia susceptibility, five simulation conditions were examined:
(1) no DOX (D=0), 0% IKr block; (2) full DOX effect (D=1), 0% IKr
block; (3) full DOX effect (D=1), 30% IKr block; (4) full DOX effect
(D=1), 40% IKr block; and (5) no DOX (D=0), 40% IKr block. Conditions 1
and 2 isolate the effect of DOX alone, conditions 3 and 4 examine DOX
combined with progressive IKr block, and condition 5 isolates the
effect of IKr block alone. IKr block was implemented as a fixed scaling
constant on maximal IKr conductance (GKr), hard-coded for each condition
(IKr_scaling = 1.0, 0.7, or 0.6 for 0%, 30%, and 40% block,
respectively).

A population of N=1000 virtual human ventricular cells was generated to
investigate inter-individual variability in ion channel expression
under DOX. Twelve ion channel conductance scaling factors (GNa, Gto,
GNaL, PCa, GKs, GK1, Gncx, Pnak, GKb, PNab, PCab, GpCa) were
independently sampled from a uniform distribution spanning 0.8-1.2x
(±20%) baseline for each cell to simulate physiological variability in
channel expression across a virtual patient population. A fixed random
seed was used to generate a single population of 1000 virtual cells,
with the same twelve conductance scaling factors applied identically
across all five simulation conditions to ensure the differences in
outcomes between conditions reflect the applied DOX effect and IKr
block perturbations rather than variability in the sampled population.

| Ion Channel | Conductance Parameter Scaled ± 20% |
|---|---|
| INa | GNa |
| INaL | GNaL |
| INaCa | Gncx |
| INaK | Pnak |
| IKs | GKs |
| IK1 | GK1 |
| Ito | Gto |
| ICaL | PCa |
| IKb | GKb |
| INab | PNab |
| ICab | PCab |
| IpCa | GpCa |

For each of the five conditions, every cell in the population was
simulated as a single continuous run: starting from fixed initial
conditions representing 2 Hz steady-state under that condition's DOX
effect (D=0 or D=1), each cell was paced at 2 Hz (cycle length 500 ms)
for 10 beats, followed by a single 1000 ms pause, after which one
additional beat was recorded using forward Euler integration
(dt=0.01 ms). DOX effect and IKr block were applied throughout the full
simulation for each condition. Pause-dependent early afterdepolarizations
have been implicated in the initiation of torsade de pointes in the
setting of prolonged repolarization, and computational modeling has
demonstrated that a pause following rapid pacing can unmask EAD
susceptibility not evident during steady-state pacing alone (Tang et
al., 2012; Liu and Laurita, 2005; Viswanathan and Rudy, 1999). A trial
was flagged as failed and excluded from subsequent analysis if, at the
end of the pacing protocol, cytosolic calcium was negative, cytosolic
calcium exceeded 5.0 mM, or membrane potential was non-finite. No
trials met these exclusion criteria across the five simulation
conditions.

For each cell, membrane potential, cytosolic calcium ([Ca2+]i),
mitochondrial calcium ([Ca2+]m), and cytosolic ROS ([O2.-]i) traces
were recorded for the post-pause beat. APD90 was calculated from the
voltage traces. Mean and standard deviation of APD90 were calculated
across the population of 1000 cells for each of the five simulation
conditions.

## Folder structure

```
Figure11_code/                                    <- this README lives here
├── D0_IKr0percentBlock_500CL_pauseprotocol/
├── D0_IKr40percentBlock_500CL_pauseprotocol/
├── D1_IKr0percentBlock_500CL_pauseprotocol/
├── D1_IKr30percentBlock_500CL_pauseprotocol/
├── D1_IKr40percentBlock_500CL_pauseprotocol/
└── PlotFigure/
    ├── Figure11Plot.m
    └── (all 5 outputs_pause_*.mat files copied in here)
```

Each of the 5 condition folders is self-contained and runs one
simulation condition end-to-end (population generation -> steady-state
IC generation -> pause protocol -> output `.mat` file). All 5 condition
folders contain the same 5 scripts, differing only in the D and
IKr_scaling values set inside them for that condition. The initial conditions
differ between D0 and D1. D0 initial conditions "SSIC_500CL_D0.txt" and D1 initial
conditions "SSIC_500CL_D1.txt" can be found in Figure10>Code>InitialConditions.

## Files (identical set in each of the 5 condition folders)

| File | Description |
|---|---|
| `ord_dox_SA1_generate_parameters.m` | Generates the population parameter matrix: N=1000 virtual cells x 12 ion channel conductance scaling factors (GNa, Gto, GNaL, PCa, GKs, GK1, Gncx, Pnak, GKb, PNab, PCab, GpCa), each independently sampled from U[0.8, 1.2] (±20% of baseline). Also sets this condition's D value (0 or 1) and other fixed settings (CL, stimulus parameters) in `p_fixed`. Saves `parameter_ord_dox_pop.mat`. N_trials (line 53) determines the number of virtual cells. Lines 73-82 define fixed values necessary for simulation conditions (cell type, DOX level, cycle length, etc.)|
| `ord_dox_euler_step.m` | Forward Euler integration function (dt=0.01 ms) for the ORd+DOX model - the MATLAB implementation of the same DOX model used in the Figure 9/10 C++ code. Takes a cell's 12 conductance scaling factors (`sc`), number of steady-state beats, number of output beats, and D as input. `IKr_scaling` is **hard-coded inside this file** (e.g. `IKr_scaling = 1.0;`) - this must be manually edited to 1.0, 0.7, or 0.6 to match this condition folder's 0%, 30%, or 40% IKr block before running. Called internally by both `SA2` and `SA3b`; not run directly. |
| `ord_dox_SA2_obtain_ICs.m` | Runs each of the 1000 virtual cells to steady state (10 beats) at this condition's D value, using `ord_dox_euler_step.m`. Flags any trial that fails (negative cytosolic calcium, cytosolic calcium >5.0 mM, or non-finite membrane potential) for exclusion. n_beats_SS (line 13) can be modified for a desired amount of beats to SS. Saves `ICs_ord_dox_pop.mat`. |
| `ord_dox_SA3b_pause_protocol.m` | For each non-flagged cell: paces at 2 Hz (CL=500ms) for 10 beats, applies a single 1000 ms pause, then records 1 additional post-pause beat. Calculates APD90 and peak/diastolic cytosolic calcium, and EAD detection in the post-pause beat. Saves downsampled V, Cai, Cam, and ROSi traces for every cell. Saves this condition's output file (e.g. `outputs_pause_D0IKr0.mat`). |
| `plot_pause_traces.m` | Quick-look plotting script for this condition alone (all valid trials overlaid: V, ICaL, Cai, Cam, ROSi). Useful for checking this condition's traces before combining all 5 conditions in `Figure11Plot.m`. |

## Files (in `PlotFigure/`)

| File | Description |
|---|---|
| `Figure11Plot.m` | Loads all 5 conditions' `outputs_pause_*.mat` files (each loaded once), prints the post-pause APD90 summary table (mean, SD, median, N cells per condition) to the command window, and generates the combined post-pause trace figure (V, [Ca2+]i, [Ca2+]m, ROSi - one column per condition, all valid trials overlaid). |

## How to run

For **each** of the 5 condition folders:

1. Open `ord_dox_euler_step.m` and confirm/set `IKr_scaling` to match this
   condition (1.0 / 0.7 / 0.6 for 0% / 30% / 40% block).
2. Open `ord_dox_SA1_generate_parameters.m` and confirm `p_fixed(102)`
   (D) is set correctly for this condition (0 or 1).
3. Run the scripts in order:
   ```matlab
   ord_dox_SA1_generate_parameters   % -> parameter_ord_dox_pop.mat
   ord_dox_SA2_obtain_ICs            % -> ICs_ord_dox_pop.mat
   ord_dox_SA3b_pause_protocol       % -> outputs_pause_<condition>.mat
   ```
4. (Optional) Run `plot_pause_traces.m` to spot-check this condition's
   traces on their own.

Once all 5 condition folders have produced their output `.mat` file,
copy all 5 files into `PlotFigure/`, then run `Figure11Plot.m` from
within `PlotFigure/` to generate the combined figure and APD90 summary
table.

## Notes

- The random seed for population generation (`rng(42)` in `SA1`) must
  be identical across all 5 condition folders so that all five
  conditions simulate the same underlying 1000 virtual cells - only D
  and IKr_scaling should differ between condition folders.
- `n_beats_SS = 10` (steady-state pacing beats) and the pause protocol
  timing (`pre_pause_ms = 500`, `pause_ms = 1000`, `extra_ms = 1000`,
  CL = 500 ms) must also match across all 5 condition folders for the
  comparison across conditions to be valid.
- No trials were excluded (negative cytosolic calcium, cytosolic
  calcium >5.0 mM, or non-finite membrane potential) across any of the
  five conditions in the reported results.
- `ord_dox_euler_step.m`'s input comment lists the 4th scaling factor as
  "PCap" but the code variable is `sc_PCa` (baseline ICaL permeability,
  scaled ±20% per virtual cell) - this is unrelated to the ROS-dependent
  `pca_factor` scaling used elsewhere in the paper (Figures 5-9); it is
  simply this parameter's per-cell population variability factor.
