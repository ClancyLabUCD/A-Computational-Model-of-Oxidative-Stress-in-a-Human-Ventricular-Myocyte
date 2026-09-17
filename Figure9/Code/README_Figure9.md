# Figure 9: DOX-Induced Mitochondrial and Electrophysiological Dysfunction

This folder contains the simulation code, initial conditions, and
plotting script used to characterize DOX (doxorubicin)-induced
mitochondrial and electrophysiological dysfunction across pacing rates,
and to validate model-predicted APD prolongation against two independent
experimental datasets.

## Overview

**DOX Dose-Response Simulation Protocol.** To characterize DOX-induced
mitochondrial and electrophysiological dysfunction across pacing rates,
steady-state simulations were performed across DOX effect levels (D=0,
0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0) at cycle lengths of 500, 750, and
1000 ms. For each combination of D and cycle length, peak cytosolic
calcium ([Ca2+]i), peak mitochondrial calcium ([Ca2+]m), peak cytosolic
superoxide ([O2.-]i), minimum mitochondrial membrane potential (ΔΨ), and
APD90 were extracted. Percent change for each variable was calculated
relative to baseline (D=0) at the corresponding cycle length.

**DOX-Induced APD Prolongation Validation.** To validate model-predicted
DOX-induced APD prolongation, simulations were performed at D=1.0 with
cycle length matched to the pacing rate reported in each experimental
dataset (1 Hz, 0.5 Hz). Baseline steady-state APD was extracted at D=0
for each cycle length, and percent change in APD was calculated at D=1.0
relative to baseline. At 0.5 Hz, percent change in APD90 was compared
against experimental measurements from Wang and Korth (1995), in which
isolated guinea pig ventricular myocardium was acutely treated with
100 µM DOX and action potentials were recorded at 0.5 Hz, with APD90
prolongation of 38.6 ± 2.9% (n=3) reported relative to control. At 1 Hz,
percent change in APD80 was compared against experimental data from
George et al. (2026), in which human ventricular slices from older male
donors were cultured in 5 µM DOX for 24 hours, with APD80 prolongation
of 32 ± 17% (N=10 hearts) reported relative to control. D=1.0 represents
maximum DOX stress in the model and was selected for comparison against
both datasets on the basis that each experimental preparation represents
a condition of maximal acute DOX exposure, despite differences in
species, DOX concentration, exposure duration, and pacing rate between
the two datasets.

## Files

| File / folder | Description |
|---|---|
| `ZukowskiECMROS_Fig9.cpp` | Runs the model across 3 pacing conditions (CL = 500, 750, 1000 ms) x 8 DOX severity levels (D = 0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0), and writes one output file per (CL, D) combination. Produces the traces underlying **Fig. 9A-F**. |
| `InitialConditions/` | Folder of steady-state IC files, one per (CL, D) combination, named `SSIC_<CL>CL_<Dlabel>.txt` (e.g. `SSIC_1000CL_D0.txt`, `SSIC_500CL_D75.txt`). Each file is a list of `name = value;` lines, one per state variable. |
| `Figure9Plot.m` | MATLAB script that loads all simulation outputs once, builds the DOX dose-response panels (Fig. 9A-E) and the experimental validation panels (Fig. 9F), and generates both figures from a single script run. |

## How to run

```bash
g++ -O2 -o ZukowskiECMROS_Fig9 ZukowskiECMROS_Fig9.cpp
./ZukowskiECMROS_Fig9
```

This must be run from a directory containing the `InitialConditions/`
folder alongside the compiled executable. For each of the 26 valid
(CL, D) combinations - 8 D values at 500/750/1000 ms, plus D=0 and D=1.0
at 2000 ms - the code:

1. Loads that combination's steady-state IC from `InitialConditions/SSIC_<CL>CL_<Dlabel>.txt`
2. Recomputes the DOX-dependent parameters (`alpha_DOX`, `beta_DOX`, `ETC_Leak`) for that D value
3. Runs 2 beats and saves both
4. Writes `output_<CL>CL_<Dlabel>.txt`

e.g. `output_1000CL_D0.txt`, `output_500CL_D75.txt`. Each output file has 33 columns: `t, v, cai, cass, cansr, cajsr, Jrel, Jup, INa, INaL, Ito, ICaL, ICaNa, ICaK, IKr, IKs, IK1, INaCa_i, INaCa_ss, INaCa, INaK, IKb, INab, IpCa, ICab, APD, ROSi, ROSm, H2O2, GSH, Psi, NADHm, Cam`.

If an expected IC file is missing, the code prints an error naming the
missing file and skips that run rather than crashing or silently reusing
stale state.

Run `Figure9Plot.m` in MATLAB from the same folder as the simulation
outputs to generate both figures: the dose-response figure (peak
[Ca2+]i, peak [Ca2+]m, peak ROSi, min ΔΨ, and APD90 vs. DOX severity
across the three pacing rates) and the validation figure (%ΔAPD90 vs.
Wang and Korth, 1995; %ΔAPD80 vs. George et al., 2026).

## Notes



