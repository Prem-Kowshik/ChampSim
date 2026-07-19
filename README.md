# ChampSim Lab Assignment Repository

This repository contains the ChampSim source, automation scripts, raw logs, summary tables, and the graph outputs for the combined Lab 9, 10, and 11 assignment.

## What was changed

### 1) Branch predictors
Files:
- `branch/modified_bullseye.cc`
- `branch/adaptive_threshold_modified_bullseye.cc`

What changed:
- Added a Bullseye-inspired branch predictor variant.
- Added an adaptive-threshold variant that adjusts the H2P classification threshold based on recent prediction behavior.
- Kept the implementation compatible with the existing ChampSim branch-predictor structure.

### 2) LLC replacement policies
Files:
- `replacement/mru.llc_repl`
- `replacement/random.llc_repl`
- `replacement/htc.llc_repl`

What changed:
- Implemented MRU and Random as separate `.llc_repl` files, as required by the assignment.
- Added the bonus HTC (hard-to-cache) replacement policy.
- Left the provided policies (`lru`, `srrip`, `drrip`, `ship`) unchanged.

### 3) Cache-configuration sweeps
File:
- `inc/cache.h`

What changed:
- LLC size and associativity were varied for the Task 2 experiments.
- The automation script restores the original cache header after each sweep so the repository stays clean.

### 4) Experiment automation
Files:
- `select_random_traces_task1.py`
- `run_task1_singlecore.sh`
- `run_task1_multicore.sh`
- `run_task2_auto.sh`

What these scripts do:
- Select reproducible multicore trace sets.
- Run all Task 1 predictor experiments.
- Run Task 2 cache size / associativity / replacement-policy sweeps.
- Save logs in structured folders so the results are easy to review.

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

### Task 2
The automated sweep can be launched with:
```bash
chmod +x run_task2_auto.sh
./run_task2_auto.sh
```

## Output folders

- `results/` — raw simulator logs
- `graphs/task 1/` — Task 1 graph outputs
- `graphs/task2/` — Task 2 graph outputs


## File map

| File | Purpose |
|---|---|
| `branch/modified_bullseye.cc` | Bullseye-inspired predictor |
| `branch/adaptive_threshold_modified_bullseye.cc` | Adaptive-threshold Bullseye predictor |
| `replacement/mru.llc_repl` | MRU LLC replacement |
| `replacement/random.llc_repl` | Random LLC replacement |
| `replacement/htc.llc_repl` | Bonus HTC replacement |
| `inc/cache.h` | LLC configuration sweeps |
| `select_random_traces_task1.py` | Random trace generator |
| `run_task1_singlecore.sh` | Task 1 single-core automation |
| `run_task1_multicore.sh` | Task 1 multicore automation |
| `run_task2_auto.sh` | Task 2 automation |
