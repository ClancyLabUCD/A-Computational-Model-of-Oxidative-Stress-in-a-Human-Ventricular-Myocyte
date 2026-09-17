# Figure 7: Validation of ROS-Dependent APD Prolongation and Calcium Handling

This folder contains the simulation code and plotting script used to
validate model-predicted ROS effects on action potential duration and
cytosolic calcium handling against independent experimental H2O2
exposure data.

## Overview

**APD50 Validation.** To validate model-predicted ROS-dependent APD
prolongation, cytosolic ROS ([O2.-]i) was held constant at 200 µM and the
model was paced for 50 beats at cycle lengths of 2000, 1000, 750, and
500 ms (0.5-2 Hz). Baseline simulations were performed with [O2.-]i held
constant at 1x10^-6 mM. APD50 was extracted from the final beat and
expressed as percent increase from baseline APD50. Simulated values were
compared against experimental measurements from Song et al. (2006), in
which guinea pig ventricular myocytes exposed to 200 µM H2O2 with action
potentials induced by a 5-ms depolarizing pulse at 0.16 Hz exhibited
37.25 ± 13.41% APD50 prolongation relative to control, extracted from
Figure 2 of Song et al. (2006). The experimental pacing rate (0.16 Hz)
falls outside the simulated range (0.5-2 Hz), which was chosen to
reflect physiologically relevant human heart rates from bradycardic to
tachycardic conditions.

**Cytosolic Calcium Validation.** To validate model-predicted
ROS-dependent calcium handling, cytosolic ROS was held constant at
0.5 mM and the model was paced for 50 beats at cycle lengths of 2000,
1000, 750, and 500 ms. Baseline simulations were performed with [O2.-]i
held constant at 1x10^-6 mM. Diastolic cytosolic calcium was calculated
as percent increase from baseline at each pacing condition. Simulated
values were compared against experimental measurements from Wang et al.
(1999), in which resting [Ca2+]i in cell suspensions of Fura-2-loaded
adult male Sprague-Dawley rat ventricular myocytes increased by
52.8 ± 4.7% following a 10-minute incubation with 0.5 mmol/L H2O2 at room
temperature, extracted from Figure 3 of Wang et al. (1999).

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_Fig7.cpp` | Runs the model across 4 pacing conditions (CL = 500, 750, 1000, 2000 ms) x 3 fixed ROSi conditions (base = 1e-6 mM, 200 = 200 µM, 500 = 0.5 mM), each restarting from that pacing rate's own steady-state ICs. ROS is held constant for the full 50-beat run (not integrated) and drives GNaL_factor, pca_factor, Jrel_ROS, and Jup_ROS. Produces the traces for **Fig. 7A-B**. |
| `Fig7Plot.m` | MATLAB script that reads the Fig. 7 simulation outputs, computes APD50 percent increase (base vs. 200 µM ROS) and diastolic calcium percent increase (base vs. 0.5 mM ROS) at each pacing rate, and generates the validation panels against Song et al. (2006) and Wang et al. (1999). |

## How to run

```bash
g++ -O2 -o ZukowskiECMROS_Fig7 ZukowskiECMROS_Fig7.cpp
./ZukowskiECMROS_Fig7
```

This runs all 12 combinations of the 4 pacing conditions and 3 ROSi
conditions, each restarting from that pacing rate's own steady-state IC
and paced for 50 beats (only the final beat saved), and writes:

`output_<CL>CL_<condition>.txt`

- `base` = ROSi held at 1e-6 mM (no/minimal ROS)
- `200` = ROSi held at 200E-3 mM (used for APD50 validation, Fig. 7A)
- `500` = ROSi held at 0.5 mM (used for calcium validation, Fig. 7B)

e.g. `output_1000CL_base.txt`, `output_1000CL_200.txt`,
`output_1000CL_500.txt`, `output_500CL_base.txt`, etc. (12 files total).
Each file has 7 columns: time, v, cai, ICaL, INaL, ROSi, APD.

Run `Fig7Plot.m` in MATLAB from the same folder as the simulation
outputs. The script prints APD50 percent increase (simulation values,
compared against the Song et al. experimental value) and diastolic
calcium percent increase (simulation values, compared against the Wang
et al. experimental value) to the command window, then generates the
two-panel validation figure: Panel A (APD50 vs. Song et al., 2006) and
Panel B (diastolic [Ca2+]i vs. Wang et al., 1999), with simulation bars
grouped by cycle length on the left and the experimental value (with
error bar) on the right of each panel.

## Notes

- ROS ([O2.-]i) is held fixed for the entire simulation in this code (the
  `ROSi += dROSi*dt` integration step is intentionally left out) so that
  each run isolates the effect of a specific, constant ROS level,
  independent of the model's own ROS production dynamics.
- Each of the 12 conditions starts from that cycle length's own
  steady-state IC (not a shared IC across cycle lengths), since
  steady-state ion concentrations and gating variables differ
  substantially between pacing rates.
- Wang et al. (1999)'s calcium measurement was made in an unpaced,
  room-temperature cell suspension (no electrical stimulation), unlike
  Song et al. (2006)'s paced APD measurement. The model's diastolic
  (interbeat) [Ca2+]i during pacing serves as the closest available
  correlate to Wang et al.'s unpaced resting [Ca2+]i, since the paced
  model does not have a distinct unstimulated resting state.
