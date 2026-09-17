# Figure 5: ROS-Dependent Modulation of RyR and SERCA Calcium Handling

This folder contains the simulation code and plotting script used to
characterize how ROS-dependent modulation of ryanodine receptor (RyR) and
SERCA flux shapes intracellular calcium handling in the Zukowski ECM-ROS
model.

## Overview

To incorporate experimentally observed ROS-dependent modulation of
sarcoplasmic reticulum (SR) calcium handling, cytosolic ROS was coupled to
both ryanodine receptor (RyR) release flux (JRyR) and SERCA uptake flux
(Jup) in the Zukowski ECM-ROS integrated model (Fig. 5A). ROS-dependent
scaling functions were calculated from experimental measurements
describing oxidative modulation of RyR open probability and SERCA
activity (Fig. 5B). For RyR, fold-change in channel open probability was
extracted from Oba et al. 2002, normalized to baseline RyR open
probability in the absence of ROS, and fit with a sigmoidal function to
define ROS-dependent modulation of JRyR. For SERCA, ROS-dependent changes
in SERCA flux were extracted from Xu et al. 1997, normalized to baseline
SERCA activity under no ROS conditions, and similarly fit with a
sigmoidal function to define ROS-dependent modulation of Jup. Together,
these functions enabled ROS-dependent modulation of intracellular calcium
cycling between the cytosol, network SR (NSR), junctional SR (JSR), and
mitochondria.

The shaded region in Fig. 5B represents the physiologically relevant ROS
concentration range investigated in this study (10^-4-10^-2 mM). Within
this range, moderate ROS exposure (0.105 µM and 1.00 µM) was predicted to
increase cytosolic calcium transient amplitude because of enhanced
RyR-mediated calcium release (Fig. 5C-D). However, at higher ROS
concentrations (100 µM), the model predicted depletion of calcium from
both the NSR and JSR, consistent with impaired SR calcium storage under
severe oxidative stress (Fig. 5E-F). The transition from enhanced calcium
release to SR calcium depletion is experimentally supported by
observations of reduced SR calcium content following radiation-induced
oxidative stress in ventricular myocytes (Sag et al., 2013).

Together, these results demonstrate that ROS-dependent modulation of RyR
and SERCA produces concentration-dependent effects on intracellular
calcium handling, with moderate ROS enhancing cytosolic calcium transients
and high ROS driving pathological SR calcium depletion.

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_Fig5.cpp` | Runs the model at 1 Hz pacing across 3 fixed cytosolic ROS ([O2.-]i) conditions - high (0.1 mM), mid (1e-3 mM), and low (1e-4 mM) - each restarting from the same original ICs. ROS is held constant for the full run (not integrated) and drives ROS-dependent scaling of ICaL, INaL, JRyR, and Jup. Produces the traces for **Fig. 5C-F**. |
| `Figure5Plot.m` | MATLAB script that reads the Fig. 5 simulation outputs and generates the panels, including the RyR/SERCA ROS-dependent scaling curves (Fig. 5B) and the resulting calcium transient/SR content traces (Fig. 5C-F). |

## How to run

```bash
g++ -O2 -o ZukowskiECMROS_Fig5 ZukowskiECMROS_Fig5.cpp
./ZukowskiECMROS_Fig5
```

This runs three conditions at CL = 1000 ms, each resetting to the
original ICs and clamping cytosolic ROS to a fixed value for the full
200-beat run (last 2 beats saved):

- `output_1Hz_ROSihigh.txt` (ROSi = 0.1 mM, i.e. 100 µM)
- `output_1Hz_ROSimid.txt` (ROSi = 1e-3 mM, i.e. 1.00 µM)
- `output_1Hz_ROSilow.txt` (ROSi = 1e-4 mM, i.e. 0.105 µM baseline-adjacent condition)

Run `Figure5Plot.m` in MATLAB from the same folder as the simulation
outputs to generate the figure panels: the RyR/SERCA ROS-dependent scaling
functions (5B), and the calcium transient and SR calcium content traces
across the low, mid, and high ROS conditions (5C-F).

## Notes

- ROS ([O2.-]i) is held fixed for the entire simulation in this code (the
  `ROSi += dROSi*dt` integration step is intentionally left out) so that
  each run isolates the effect of a specific, constant ROS level on RyR-
  and SERCA-mediated calcium handling, independent of the model's own ROS
  production dynamics.
- The fixed ROS value drives `GNaL_factor`, `pca_factor`, `Jrel_ROS`
  (JRyR scaling), and `Jup_ROS` (SERCA scaling) through sigmoidal/
  exponential functions fit to the experimental RyR (Oba et al. 2002) and
  SERCA (Xu et al. 1997) data described above.
- All three conditions start from the same baseline steady-state IC (same
  as Fig. 2A/3/4), isolating the effect of ROS level from any differences
  in starting condition.
