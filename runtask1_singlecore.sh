#!/bin/bash
set -euo pipefail

TRACE_DIR="dpc3_traces"
WARMUP=1
SIM=10

TRACES=(
  "401.bzip2-277B.champsimtrace.xz"
  "403.gcc-16B.champsimtrace.xz"
  "450.soplex-92B.champsimtrace.xz"
  "605.mcf_s-1644B.champsimtrace.xz"
)

PREDICTORS=(
  "bimodal"
  "gshare"
  "hashed_perceptron"
  "perceptron"
  "modified_bullseye"
  "adaptive_threshold_modified_bullseye"
)

mkdir -p results/task1_singlecore

for predictor in "${PREDICTORS[@]}"; do
    echo "=================================================="
    echo "Building predictor: ${predictor}"
    echo "=================================================="

    ./build_champsim.sh "${predictor}" no no no no lru 1

    binary="${predictor}-no-no-no-no-lru-1core"
    outdir="results/task1_singlecore/${predictor}"
    mkdir -p "${outdir}"

    for trace in "${TRACES[@]}"; do
        if [[ ! -f "${TRACE_DIR}/${trace}" ]]; then
            echo "[ERROR] Missing trace: ${TRACE_DIR}/${trace}"
            exit 1
        fi

        echo "Running ${predictor} on ${trace}"
        ./run_champsim.sh "${binary}" "${WARMUP}" "${SIM}" "${trace}"

        # Copy the generated output file into a tidy folder
        result_file="results_${SIM}M/${trace}-${binary}.txt"
        if [[ -f "${result_file}" ]]; then
            cp "${result_file}" "${outdir}/"
        else
            echo "[WARN] Expected result file not found: ${result_file}"
        fi
    done
done

echo "=================================================="
echo "Task 1 single-core runs completed."
echo "Logs are saved in results/task1_singlecore/"
echo "=================================================="