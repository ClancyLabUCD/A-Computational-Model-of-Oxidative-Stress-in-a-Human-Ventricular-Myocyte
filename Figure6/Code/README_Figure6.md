# Figure 6: ROS-Dependent INaL and ICaL Conductance Calibration

This folder contains the simulation code and plotting script used to
calibrate ROS-dependent late sodium current (INaL) and L-type calcium
current (ICaL) conductance scaling against experimental voltage-clamp
data.

## Overview

To incorporate experimentally observed ROS-dependent ion channel
remodeling into the Zukowski ECM-ROS model, INaL and ICaL conductance
scaling parameters were calibrated to experimental measurements obtained
under oxidative stress conditions. Calibration of INaL and ICaL was
necessary to constrain ROS-dependent conductance scaling within
physiologically observed ranges prior to whole-cell simulations.

Experimental measurements from Song et al. 2006 demonstrated
81.78 ± 24.98% increased late sodium current following exposure of guinea
pig ventricular myocytes to 200 µM H2O2 under a 300-ms voltage clamp
protocol (Song et al., 2006). To reproduce the experimental conditions in
silico, cytosolic ROS concentration was increased to maximal simulated
levels ([O2.-]i ≥ 100 µM), and INaL conductance (GNaL) scaling was
adjusted such that simulated increases in INaL area under the curve (AUC)
remained within the experimentally observed range at 1 Hz (Fig. 6A).
Representative steady-state traces at 1 Hz demonstrated a 103% AUC
increase of INaL under high ROS conditions relative to no-ROS conditions
(Fig. 6B).

Similarly, ROS-dependent enhancement of ICaL was calibrated using
experimental measurements from Xie et al. 2009, in which adult rabbit
ventricular myocytes exposed to 1 mM H2O2 exhibited 65.75 ± 30.63%
increased peak L-type calcium current during a 300-ms voltage clamp
protocol. Under maximal simulated ROS conditions, ICaL conductance (GCaL)
scaling was tuned such that simulated peak ICaL enhancement at 1 Hz
aligned with experimentally observed increases (Fig. 6C). Representative
steady-state ICaL traces at 1 Hz demonstrated a 45% increased peak
calcium current during ROS exposure compared to no-ROS conditions
(Fig. 6D).

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_Fig6.cpp` | Runs the model at 1 Hz pacing for 2 fixed cytosolic ROS ([O2.-]i) conditions - basal (1e-6 mM) and high (1.5e-3 mM) - each restarting from the same original ICs. ROS is held constant for the full run (not integrated) and drives ROS-dependent scaling of GNaL and GCaL. Produces the traces for **Fig. 6A-D**. |
| `Figure6Plot.m` | MATLAB script that reads the Fig. 6 simulation outputs and generates the panels, including INaL AUC comparison (6A-B) and ICaL peak current comparison (6C-D) between base and high ROS conditions. |

## How to run

```bash
g++ -O2 -o ZukowskiECMROS_Fig6 ZukowskiECMROS_Fig6.cpp
./ZukowskiECMROS_Fig6
```

This runs two conditions at CL = 1000 ms, each resetting to the original
ICs and clamping cytosolic ROS to a fixed value for a 10-beat run (last 5
beats saved):

- `output3_HZ_1Hz_base.txt` (ROSi = 1e-6 mM, no/minimal ROS condition)
- `output3_HZ_1Hz_high.txt` (ROSi = 1.5e-3 mM, high/maximal simulated ROS condition)

Each output file has 7 columns: time, v, cai, ICaL, INaL, ROSi, APD.

Run `Figure6Plot.m` in MATLAB from the same folder as the simulation
outputs to generate the figure panels: representative steady-state INaL
traces and AUC comparison (6A-B), and representative steady-state ICaL
traces and peak current comparison (6C-D), between the base and high ROS
conditions.

## Notes

- ROS ([O2.-]i) is held fixed for the entire simulation in this code (the
  `ROSi += dROSi*dt` integration step is intentionally left out) so that
  each run isolates the effect of a specific, constant ROS level on GNaL-
  and GCaL-mediated current, independent of the model's own ROS
  production dynamics.
- The fixed ROS value drives `GNaL_factor` (INaL scaling) and
  `pca_factor` (ICaL scaling) through sigmoidal functions calibrated
  against the experimental INaL (Song et al. 2006) and ICaL (Xie et al.
  2009) voltage-clamp data described above.
- Both conditions start from the same baseline steady-state IC (same as
  Fig. 2A/3/4/5), isolating the effect of ROS level from any differences
  in starting condition.
