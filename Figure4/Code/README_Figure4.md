# Figure 4: Cytosolic Calcium Perturbation 

This folder contains the simulation code and plotting scripts used to
investigate the model-predicted relationship between cytosolic calcium and
mitochondrial energetics and ROS production.

## Overview

To investigate the model-predicted relationship between cytosolic calcium
and mitochondrial energetics and ROS production, cytosolic and subspace
calcium ([Ca2+]i, [Ca2+]ss) were scaled by a fixed multiplicative factor
applied directly to the calcium concentration derivative:

```
[Ca2+]x(t+dt) = [Ca2+]x(t) + dt * (Ca2+_scaling * Δ[Ca2+]x)
```

where x = i (cytosol) or ss (subspace), and Ca2+_scaling is the fixed
scaling factor.

Two sets of simulations were performed:

**Panels B-E.** At 1000 ms cycle length, cytosolic and subspace calcium
were scaled by factors of 1.3 and 1.5, which predicted steady-state peak
cytosolic calcium increases of 37% and 62%, respectively. Time-dependent
percent change from baseline was recorded for mitochondrial calcium
([Ca2+]m), electron transport chain flux (JETC), mitochondrial membrane
potential (ΔΨ), and cytosolic superoxide ([O2.-]i) following the calcium
perturbation.

**Panel F.** To evaluate the dependence of the cytosolic calcium to ROS
relationship on pacing rate, cytosolic and subspace calcium were scaled by
factors of 1.1 to 1.5 (in increments of 0.1), corresponding to peak
cytosolic calcium increases of approximately 10-50%, at cycle lengths of
2000, 1000, 750, and 500 ms. For each combination of calcium scaling
factor and cycle length, the model was run to steady state (see Numerical
Implementation). Percent change in cytosolic superoxide ([O2.-]i) from
baseline was calculated, and the ROS amplification ratio was defined as
the percent change in [O2.-]i divided by the percent change in [Ca2+]i for
each condition.

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_1Hz_Fig4BthruE.cpp` | Runs the model at 1000 ms cycle length across cai_scaling = 1.0, 1.3, and 1.5, each restarting from the original steady-state ICs. Produces the traces for **Fig. 4B-E**. |
| `Figure4BthruEPlot.m` | MATLAB script that reads the Fig. 4B-E simulation outputs and generates panels B-E. |
| `ZukowskiECMROS_Fig4F.cpp` | Nested sweep over 4 pacing conditions (CL = 500, 750, 1000, 2000 ms) x 6 cai_scaling values (1.0-1.5), each combination restarting from that pacing rate's own steady-state ICs. Produces the data for **Fig. 4F**. |
| `Fig4FPlot.m` | MATLAB script that reads the Fig. 4F simulation outputs and generates panel F, including the percent-change-from-baseline and ROS amplification ratio calculations. |

## How to run

### Panels B-E

```bash
g++ -O2 -o ZukowskiECMROS_1Hz_Fig4BthruE ZukowskiECMROS_1Hz_Fig4BthruE.cpp
./ZukowskiECMROS_1Hz_Fig4BthruE
```

This runs three conditions at CL = 1000 ms (cai_scaling = 1.0, 1.3, 1.5),
resetting to the original ICs before each run, and writes:

- `output3_HZ_1Hz_100perCai.txt` (cai_scaling = 1.0, baseline)
- `output3_HZ_1Hz_30perCai.txt` (cai_scaling = 1.3)
- `output3_HZ_1Hz_50perCai.txt` (cai_scaling = 1.5)

Run `Figure4BthruEPlot.m` in MATLAB from the same folder to generate
panels B-E, showing time-dependent percent change from baseline for
[Ca2+]m, JETC, ΔΨ, and [O2.-]i.

### Panel F

```bash
g++ -O2 -o ZukowskiECMROS_Fig4F ZukowskiECMROS_Fig4F.cpp
./ZukowskiECMROS_Fig4F
```

This runs all 24 combinations of the 4 pacing conditions and 6
cai_scaling values, each restarting from that pacing rate's own
steady-state ICs (100 beats per run, last 2 beats saved) and writes:

`output_<CL>CL_<scaling>perCai.txt`

e.g. `output_1000CL_100perCai.txt`, `output_1000CL_10perCai.txt`, ...,
`output_1000CL_50perCai.txt`, `output_500CL_100perCai.txt`, etc.
(24 files total: 4 cycle lengths x 6 scaling conditions, where the
scaling label is the percent increase relative to cai_scaling = 1.0,
e.g. cai_scaling = 1.3 -> `30perCai`.)

Run `Fig4FPlot.m` in MATLAB from the same folder to generate panel F,
including the peak %[O2.-]i table and the ROS amplification ratio
([O2.-]i % change / [Ca2+]i % change) across pacing rates.

## Notes

- The calcium scaling factor is applied to **both** the cytosolic ([Ca2+]i)
  and subspace ([Ca2+]ss) calcium derivatives in `FBC()`, since subspace
  calcium directly drives L-type calcium current inactivation and RyR
  release; scaling only [Ca2+]i without also scaling [Ca2+]ss under-drives
  the perturbation and produces an artificially blunted ROS response.
- For panel F, each of the 24 conditions starts from that cycle length's
  own steady-state IC (not a shared IC across cycle lengths), since
  steady-state ion concentrations and gating variables differ
  substantially between pacing rates.
- cai_scaling = 1.0 in both files serves as the unperturbed baseline
  against which percent changes are calculated.
