#!/bin/bash
set -euo pipefail

TRACE_DIR="dpc3_traces"
WARMUP=1
SIM=10
MIX=0
SEED=${1:-42}

PREDICTORS=(
  "bimodal"
  "gshare"
  "hashed_perceptron"
  "perceptron"
  "modified_bullseye"
  "adaptive_threshold_modified_bullseye"
)

mkdir -p results/task1_multicore

if [[ ! -x ./select_random_traces_task1.py ]]; then
  echo "[ERROR] Please make select_random_traces_task1.py executable:"
  echo "        chmod +x select_random_traces_task1.py"
  exit 1
fi

mapfile -t SELECTED < <(python3 ./select_random_traces_task1.py "${SEED}")

if [[ ${#SELECTED[@]} -ne 4 ]]; then
  echo "[ERROR] Trace selector did not return exactly 4 traces."
  exit 1
fi

{
  echo "Seed: ${SEED}"
  echo "Selected traces:"
  printf '%s
' "${SELECTED[@]}"
} | tee results/task1_multicore/selected_traces_seed_${SEED}.txt

for trace in "${SELECTED[@]}"; do
  if [[ ! -f "${TRACE_DIR}/${trace}" ]]; then
    echo "[ERROR] Missing trace: ${TRACE_DIR}/${trace}"
    exit 1
  fi
done

for predictor in "${PREDICTORS[@]}"; do
  echo "=================================================="
  echo "Building predictor: ${predictor}"
  echo "=================================================="

  ./build_champsim.sh "${predictor}" no no no no lru 4

  binary="${predictor}-no-no-no-no-lru-4core"
  outdir="results/task1_multicore/${predictor}"
  mkdir -p "${outdir}"

  echo "Running ${predictor} with:"
  printf '  %s
' "${SELECTED[@]}"

  ./run_4core.sh     "${binary}"     "${WARMUP}"     "${SIM}"     "${MIX}"     "${SELECTED[0]}"     "${SELECTED[1]}"     "${SELECTED[2]}"     "${SELECTED[3]}"

  if compgen -G "results_${SIM}M/*${binary}*.txt" > /dev/null; then
    cp results_${SIM}M/*"${binary}"*.txt "${outdir}/" 2>/dev/null || true
  fi
done

echo "=================================================="
echo "Task 1 multicore runs completed."
echo "Logs are saved in results/task1_multicore/"
echo "=================================================="
