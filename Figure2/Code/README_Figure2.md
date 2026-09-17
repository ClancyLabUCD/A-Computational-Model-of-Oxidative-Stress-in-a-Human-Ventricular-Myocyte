# Figure 2: Mitochondrial Calcium Uptake Validation

This folder contains the simulation code, experimental comparison data, and
plotting script used to validate model-predicted mitochondrial calcium
uptake against Andrienko et al. (2009).

## Overview

To validate model-predicted mitochondrial calcium uptake, simulations were
performed under conditions matching Andrienko et al. (2009), in which
steady-state mitochondrial calcium ([Ca2+]m) was measured as a function of
fixed cytosolic calcium in single rat ventricular myocytes in the presence
of 10 mM Na+. Steady-state [Ca2+]m dependence on [Ca2+]i was extracted from
Figure 3C of Andrienko et al. (2009). In silico, cytosolic calcium was
fixed at values spanning the experimentally tested range (39.5, 156.9,
168.8, 300.1, 427.7, 553.4, 603.9, and 700 µM), intracellular sodium was
held constant at 10 mM, and steady-state peak [Ca2+]m was extracted from
the final beat of a 5-beat simulation at 1 Hz. Simulated values were
compared against Andrienko et al. (2009) as the primary validation
dataset, with data from Table 1 of Collins et al. (2001) included as an
independent comparison from a separate experimental preparation.

## Files

| File | Description |
|---|---|
| `ZukowskiECMROS_1Hz.cpp` | Full Zukowski ECM-ROS model at 1 Hz pacing, Produces **Figure 2A** (representative time-course traces). |
| `main2_HZ_1Hz_Ca1.cpp` | Iterates the model across the 8 fixed cytosolic Ca2+ conditions listed above, resetting all state variables between runs. Produces **Figure 2B** (steady-state [Ca2+]m vs. [Ca2+]i). |
| `ExpDataAndrienko.txt` | Digitized steady-state [Ca2+]m vs. [Ca2+]i data from Figure 3C of Andrienko et al. (2009). Primary validation dataset. |
| `ExpDataCollins.txt` | Digitized data from Table 1 of Collins et al. (2001). Independent comparison dataset from a separate experimental preparation. |
| `Figure2Plot.m` | MATLAB script that reads the simulation outputs and both experimental data files and generates Figure 2A and 2B. |

## How to run

### 1. Compile and run the simulations

Both `.cpp` files are self-contained (standard library only, no external
dependencies) and can be compiled with any C++ compiler, e.g.:

```bash
g++ -O2 -o ZukowskiECMROS_1Hz ZukowskiECMROS_1Hz.cpp
./ZukowskiECMROS_1Hz

g++ -O2 -o main2_HZ_1Hz_Ca1 main2_HZ_1Hz_Ca1.cpp
./main2_HZ_1Hz_Ca1
```

- `ZukowskiECMROS_1Hz.cpp` writes a single output file for Figure 2A.
- `main2_HZ_1Hz_Ca1.cpp` iterates over the 8 fixed cytosolic Ca2+ conditions
  (39.5, 156.9, 168.8, 300.1, 427.7, 553.4, 603.9, and 700 µM) with
  intracellular sodium held at 10 mM, resetting all state variables and
  timers between runs. It writes one output file per condition, labeled
  `Output_Ca1.txt` through `Output_Ca8.txt`, in the same order as the
  condition list above. Steady-state peak [Ca2+]m for each condition is
  taken from the final beat (of 5 simulated beats) in each file.

### 2. Plot the results

Run `Figure2Plot.m` in MATLAB from the same folder as the simulation
outputs and the experimental data files. The script reads
`Output_Ca1.txt`–`Output_Ca8.txt` together with `ExpDataAndrienko.txt` and
`ExpDataCollins.txt` to reproduce Figure 2A and Figure 2B, overlaying
simulated steady-state [Ca2+]m against both experimental datasets.

## Notes

- Andrienko et al. (2009) is the primary validation dataset; Collins et
  al. (2001) is included as an independent comparison and was originally
  collected in a different experimental preparation.
- Simulations are run at 1 Hz pacing with intracellular sodium fixed at
  10 mM to match the experimental conditions in Andrienko et al. (2009).
