# ChampSim Lab Assignment Repository

This repository contains the ChampSim source, scripts, raw logs, tables, graph outputs, and the written report for the combined Lab 9, 10, and 11 assignment.

## Overview

The work in this repository covers:

- Task 1: Branch prediction study
- Task 2: LLC size, associativity, and replacement-policy study
- Bonus implementation: Bullseye-inspired branch prediction and hard-to-cache replacement policy

The figures and tables are stored separately in the repository under the `graphs/` directory.

## What was changed

### 1) Branch prediction implementation
Files:
- `branch/modified_bullseye.cc`
- `branch/adaptive_threshold_modified_bullseye.cc`

Changes made:
- Added a Bullseye-inspired branch predictor built on top of the existing hashed perceptron style.
- Added an adaptive-threshold Bullseye variant.
- Kept the implementation aligned with the existing ChampSim branch predictor structure.

### 2) LLC replacement policies
Files:
- `replacement/mru.llc_repl`
- `replacement/random.llc_repl`
- `replacement/htc.llc_repl`

Changes made:
- Implemented MRU and Random as separate `.llc_repl` files, as required by the assignment.
- Added the bonus hard-to-cache (HTC) replacement policy.
- Left the provided replacement policies unchanged (`lru`, `srrip`, `drrip`, `ship`).

### 3) LLC configuration sweeps
File:
- `inc/cache.h`

Changes made:
- LLC size and associativity were varied for the Task 2 studies.
- The scripts restore the original cache configuration after runs, so the repository remains easy to reuse.

### 4) Experiment automation
Files:
- `select_random_traces_task1.py`
- `run_task1_singlecore.sh`
- `run_task1_multicore.sh`
- `run_task2_auto.sh`
- `run_task2_multicore.sh`
- `run_task2_multicore_direct.sh`

What these scripts do:
- Select reproducible multicore trace sets.
- Run all Task 1 single-core experiments.
- Run multicore Task 1 experiments.
- Run Task 2 single-core and multicore sweeps.
- Save logs in structured folders for easier analysis.

### 5) Graph generation
Files:
- `make_task1_graphs.py`
- `make_task1_final_graphs.py`
- `make_task2_graphs.py`
- `make_task2_final_graphs.py`
- `make_task2_multicore_graphs.py`

What these scripts do:
- Build Task 1 and Task 2 plots from the collected logs/tables.
- Use consistent scaling and readable styling.
- Export graphs and supporting tables into the `graphs/` directory.

### 6) Report and documentation
Files:
- `final_lab_report.docx`
- `README.md`

What was added:
- A final text-only report with methodology, implementation notes, and conclusions.
- A repository README that maps each change to the file where it was made.

## How to reproduce

### Task 1 single-core
The wrapper expects instruction counts in millions.

Example:
```bash
./build_champsim.sh bimodal no no no no lru 1
./run_champsim.sh bimodal-no-no-no-no-lru-1core 1 10 401.bzip2-277B.champsimtrace.xz
```

### Task 1 multicore
Use the trace selector to pick 4 traces, then run the multicore script.

Example:
```bash
python3 select_random_traces_task1.py 42
./run_task1_multicore.sh 42
```

### Task 2 single-core
The main automation script can run the LLC size sweep, associativity sweep, and replacement-policy comparison.

Example:
```bash
chmod +x run_task2_auto.sh
./run_task2_auto.sh
```

### Task 2 multicore
The multicore runs use the direct binary invocation script because it avoids the wrapper assertion path.

Example:
```bash
chmod +x run_task2_multicore_direct.sh
./run_task2_multicore_direct.sh policy
```

Other modes:
```bash
./run_task2_multicore_direct.sh size
./run_task2_multicore_direct.sh assoc
./run_task2_multicore_direct.sh all
```

## Output folders

- `results/` — raw simulator logs
- `graphs/task 1/` — Task 1 graph outputs and tables
- `graphs/task2/` — Task 2 graph outputs and tables
- `graphs/task2/multicore/` — multicore Task 2 graph outputs and tables

## Notes

- The multicore experiments use a reproducible random trace selection seed so the same trace set can be regenerated.
- For the Task 2 multicore study, the direct binary invocation is used instead of the wrapper script to avoid the assertion seen in the wrapper path.
- If you rerun experiments, keep the same multicore seed for consistency.

## File map

| File | Purpose |
|---|---|
| `branch/modified_bullseye.cc` | Bullseye-inspired branch predictor |
| `branch/adaptive_threshold_modified_bullseye.cc` | Adaptive-threshold Bullseye predictor |
| `replacement/mru.llc_repl` | MRU LLC replacement |
| `replacement/random.llc_repl` | Random LLC replacement |
| `replacement/htc.llc_repl` | Bonus HTC replacement |
| `inc/cache.h` | LLC size and associativity sweeps |
| `select_random_traces_task1.py` | Random trace generator |
| `run_task1_singlecore.sh` | Task 1 single-core automation |
| `run_task1_multicore.sh` | Task 1 multicore automation |
| `run_task2_auto.sh` | Task 2 single-core automation |
| `run_task2_multicore.sh` | Task 2 multicore wrapper-based script |
| `run_task2_multicore_direct.sh` | Task 2 multicore direct-run script |
| `make_task1_graphs.py` | Task 1 graph generation |
| `make_task2_graphs.py` | Task 2 graph generation |
| `make_task2_multicore_graphs.py` | Task 2 multicore graph generation |
| `final_lab_report.docx` | Final written report |
