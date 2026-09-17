# Figure 3: Steady-State Mitochondrial Flux Coupling

This folder contains the simulation code and plotting script used to
characterize steady-state mitochondrial flux behavior in the Zukowski
ECM-ROS model at 1 Hz pacing.

## Overview

Within the Zukowski ECM-ROS model, cytosolic calcium ([Ca2+]i) serves as
the primary input linking excitation-contraction coupling to
mitochondrial calcium handling and metabolism. Cytosolic calcium enters
the mitochondria through the mitochondrial calcium uniporter (JMCU) and is
extruded through the mitochondrial Na+/Ca2+ exchanger (JNCX) and
mitochondrial permeability transition pore (JmPTP). Mitochondrial calcium
additionally regulates metabolic flux through activation of the
aspartate-glutamate carrier (JAGC) and pyruvate dehydrogenase complex
(JPDH), coupling beat-to-beat dynamics to NADH production and electron
transport chain (JETC) activity (Fig. 3A). To characterize the
steady-state behavior of the Zukowski ECM-ROS integrated model and allow
verification and reproducibility for future users, simulations were
performed at a pacing cycle length of 1000 ms. Representative steady-state
traces of all predicted mitochondrial fluxes are shown in Fig. 3B-J. Each
predicted flux exhibits stable beat-to-beat oscillations synchronized with
the cytosolic calcium transient, confirming physiologically consistent
coupling between whole-cell electrophysiology and mitochondrial
energetics.

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_1Hz.cpp` | Full Zukowski ECM-ROS model run at 1 Hz (CL = 1000 ms) pacing to steady state. Outputs the time-course traces used for Fig. 3B-J. |
| `Figure3Plot.m` | MATLAB script that reads the simulation output and generates Fig. 3B-J, the representative steady-state mitochondrial flux traces. |

## How to run

### 1. Compile and run the simulation

`ZukowskiECMROS_1Hz.cpp` is self-contained (standard library only, no
external dependencies) and can be compiled with any C++ compiler, e.g.:

```bash
g++ -O2 -o ZukowskiECMROS_1Hz ZukowskiECMROS_1Hz.cpp
./ZukowskiECMROS_1Hz
```

This runs the model at 1 Hz pacing and writes the steady-state time-course
output used to generate Fig. 3B-J.

### 2. Plot the results

Run `Figure3Plot.m` in MATLAB from the same folder as the simulation
output. The script reads the saved traces and plots the representative
steady-state beat for each mitochondrial flux (JMCU, JNCX, JmPTP, JAGC,
JPDH, JETC, and the remaining fluxes shown in Fig. 3B-J), aligned to the
cytosolic calcium transient.

## Notes

- The purpose of this figure is verification and reproducibility: it
  confirms that all predicted mitochondrial fluxes reach stable,
  physiologically consistent beat-to-beat oscillations synchronized with
  the cytosolic calcium transient.
