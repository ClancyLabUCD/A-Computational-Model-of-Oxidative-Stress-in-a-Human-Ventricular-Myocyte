# BaselineCode

This folder contains the baseline Zukowski ECM-ROS model — the core
single-cell cardiac electrophysiology, mitochondrial, and ROS model
that the rest of this repository's figures build on — implemented in
both C++ and MATLAB, as a reference starting point for other users of
this code.

Both versions run the same configuration: **1 Hz pacing (CL = 1000 ms),
ETC_Leak = 0.4**, starting from a steady-state initial condition, and
report the same core outputs (membrane voltage, cytosolic and
mitochondrial calcium, ROS, and key currents).

## Folder structure

```
BaselineCode/
├── C++/
│   ├── ZukowskiECMROS.cpp
│   ├── ZukowskiECMROS_Plot.m
│   └── SteadyStateInitialConditions/
│       ├── SSIC_500CL_ETCLEAK0p4.txt
│       ├── SSIC_750CL_ETCLEAK0p4.txt
│       ├── SSIC_1000CL_ETCLEAK0p4.txt
│       └── SSIC_2000CL_ETCLEAK0p4.txt
└── MATLAB/
    ├── ZukowskiECMROS.m
    └── run_ZukowskiECMROS_and_plot.m
```

## Files

| File / folder | Description |
|---|---|
| `C++/ZukowskiECMROS.cpp` | C++ implementation of the baseline model at 1 Hz pacing, ETC_Leak = 0.4. |
| `C++/ZukowskiECMROS_Plot.m` | MATLAB script that loads the C++ output file and generates a summary plot (voltage, cytosolic calcium, ICaL, INaL, ROSi, mitochondrial calcium, and mitochondrial membrane potential). |
| `C++/SteadyStateInitialConditions/` | Steady-state initial conditions for the model at ETC_Leak = 0.4, provided for four pacing rates: 500, 750, 1000, and 2000 ms cycle length. Each file lists one state variable per line in `name = value;` format. |
| `MATLAB/ZukowskiECMROS.m` | MATLAB implementation of the same baseline model (function `zukowskiECMROS()`), at 1 Hz pacing, ETC_Leak = 0.4. |
| `MATLAB/run_ZukowskiECMROS_and_plot.m` | MATLAB script that runs `zukowskiECMROS()` and generates the same summary plot as `ZukowskiECMROS_Plot.m`, in a single step. |

## How to run

### C++

1. Compile and run `ZukowskiECMROS.cpp` (e.g. `g++ -O2 -o baseline ZukowskiECMROS.cpp && ./baseline`). The included initial condition already corresponds to the 1000 ms pacing / ETC_Leak = 0.4 steady state, so the code can be run as-is.
2. Run `ZukowskiECMROS_Plot.m` in MATLAB from the same folder as the generated output file to produce the summary plot.

**To use a different pacing rate**, open the corresponding file in
`SteadyStateInitialConditions/` and copy its contents directly over the
initial condition block near the top of `ZukowskiECMROS.cpp` - the
format (`name = value;`, one state variable per line) is written to be
pasted in as-is, with no reformatting needed. You will also need to
update the `CL` (pacing cycle length) setting elsewhere in the file to
match the IC you've selected.

### MATLAB

Run `run_ZukowskiECMROS_and_plot.m` - this calls `zukowskiECMROS()` to
run the simulation and then generates the summary plot in a single
step. (`ZukowskiECMROS.m` can also be run or called on its own if you
only need the raw output file, without the plot.)

**To use a different pacing rate**, copy the contents of the relevant
file from `C++/SteadyStateInitialConditions/` into the initial
condition block of `ZukowskiECMROS.m`, with **one change required**:
rename the state variable `j` to `j_gate` (MATLAB reserves `j` as the
imaginary unit, so the model uses `j_gate` throughout instead). No other
renaming is needed - every other variable name is identical between the
C++ and MATLAB versions. As with the C++ version, update `CL` to match
the pacing rate of the IC you've selected.

## Notes

- The C++ and MATLAB versions produce output files with **different
  column layouts** - the C++ output has 8 columns (`t, v, cai, ICaL,
  INaL, ROSi, Cam, Psi`), while the MATLAB version's output has 33
  columns (matching the fuller DOX-model-style output used elsewhere in
  this repository: `t, v, cai, cass, cansr, cajsr, Jrel, Jup, INa, INaL,
  Ito, ICaL, ICaNa, ICaK, IKr, IKs, IK1, INaCa_i, INaCa_ss, INaCa, INaK,
  IKb, INab, IpCa, ICab, APD, ROSi, ROSm, H2O2, GSH, Psi, NADHm, Cam`).
  `ZukowskiECMROS_Plot.m` and `run_ZukowskiECMROS_and_plot.m` already
  account for this and index into the correct columns for their
  respective output format - if you write your own analysis script,
  make sure to check which version's output you're reading.
- Cytosolic calcium (`cai`), cytosolic ROS (`ROSi`), and mitochondrial
  calcium (`Cam`) are output in mM in both versions' raw output files;
  both plotting scripts convert these to µM (multiply by 1000) for
  display.
- The steady-state initial conditions in `SteadyStateInitialConditions/`
  are specific to ETC_Leak = 0.4. Using them with a different ETC_Leak
  value (or other changed parameters) will not represent a true steady
  state for that configuration.
