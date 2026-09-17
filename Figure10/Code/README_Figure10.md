# Figure 10: Temporal Dissociation of Mitochondrial Dysfunction and Electrophysiological Remodeling

This folder contains the simulation code and plotting script used to
examine the relative onset and magnitude of mitochondrial versus
electrophysiological changes across DOX severity at a single pacing
rate (500 ms CL, 2 Hz).

## Overview

To evaluate the temporal relationship between mitochondrial dysfunction
and electrophysiological remodeling, the 500 ms (2 Hz) cycle length
condition was examined separately across DOX effect levels D=0.5-1.0.
Percent change from baseline (D=0) was compared across APD90, cytosolic
superoxide ([O2.-]i), mitochondrial calcium ([Ca2+]m), and mitochondrial
membrane potential (ΔΨ) to assess the relative onset and magnitude of
mitochondrial versus electrophysiological changes.

This uses the same steady-state simulation protocol as Figure 9 (DOX
effect levels D=0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0, each run from its
own steady-state IC), restricted to the single 500 ms cycle length used
throughout this figure.

## Files

| File / folder | Description |
|---|---|
| `ZukowskiECMROS_Fig10.cpp` | Runs the model at 500 ms CL across the 8 DOX severity levels (D = 0, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0). Reads each run's steady-state IC from a text file rather than hardcoding it, and writes one output file per D value. Produces the traces underlying **Fig. 10A-H**. |
| `InitialConditions/` | Folder of steady-state IC files, one per D value, named `SSIC_500CL_<Dlabel>.txt` (e.g. `SSIC_500CL_D0.txt`, `SSIC_500CL_D75.txt`). Each file is a list of `name = value;` lines, one per state variable. |
| `Figure10Plot.m` | MATLAB script that loads all 8 simulation outputs, computes percent change from baseline (D=0) for APD90, peak ROSi, peak [Ca2+]m, and min ΔΨ, and generates the bar-chart (log-scale percent change) and representative time-trace panels for D=0, D=0.75, and D=1.0. |

## How to run

```bash
g++ -O2 -o ZukowskiECMROS_Fig10 ZukowskiECMROS_Fig10.cpp
./ZukowskiECMROS_Fig10
```

This must be run from a directory containing the `InitialConditions/`
folder alongside the compiled executable. For each of the 8 D values,
the code:

1. Loads that D value's steady-state IC from `InitialConditions/SSIC_500CL_<Dlabel>.txt`
2. Recomputes the DOX-dependent parameters (`alpha_DOX`, `beta_DOX`, `ETC_Leak`) for that D value
3. Runs 2 beats and saves both
4. Writes `output_500CL_<Dlabel>.txt`

e.g. `output_500CL_D0.txt`, `output_500CL_D75.txt`, `output_500CL_D1.txt`.
Each output file has 33 columns: `t, v, cai, cass, cansr, cajsr, Jrel,
Jup, INa, INaL, Ito, ICaL, ICaNa, ICaK, IKr, IKs, IK1, INaCa_i,
INaCa_ss, INaCa, INaK, IKb, INab, IpCa, ICab, APD, ROSi, ROSm, H2O2,
GSH, Psi, NADHm, Cam`.

If an expected IC file is missing, the code prints an error naming the
missing file and skips that run rather than crashing or silently
reusing stale state.

Run `Figure10Plot.m` in MATLAB from the same folder as the simulation
outputs to generate the figure: log-scale percent-change bar charts for
APD90, ROSi, [Ca2+]m, and ΔΨ (D=0.5 through D=1.0), each paired with
representative time traces at D=0, D=0.75, and D=1.0.

## Notes

- This code is a restricted, single-cycle-length version of the Figure
  9 sweep code; see the Figure 9 folder for the full 3-cycle-length dose
  response and the additional 2000 ms (0.5 Hz) validation endpoints.
