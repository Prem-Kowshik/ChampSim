#!/bin/bash
set -euo pipefail

mkdir -p results/task2c_multicore

SEED=42
mapfile -t TRACES < <(python3 select_random_traces_task1.py "$SEED")

printf '%s\n' "${TRACES[@]}" | tee results/task2c_multicore/selected_traces_seed_${SEED}.txt

POLICIES=(
  lru
  mru
  random
  srrip
  drrip
  ship
  htc
)

for POLICY in "${POLICIES[@]}"; do
  echo "========================================"
  echo "Building $POLICY"
  echo "========================================"

  ./build_champsim.sh bimodal no no no no "$POLICY" 4

  BINARY="bimodal-no-no-no-no-${POLICY}-4core"
  OUTDIR="results/task2c_multicore/${POLICY}"
  mkdir -p "$OUTDIR"

  echo "========================================"
  echo "Running $POLICY"
  echo "========================================"

  ./run_4core.sh \
    "$BINARY" \
    1 \
    10 \
    0 \
    "${TRACES[0]}" \
    "${TRACES[1]}" \
    "${TRACES[2]}" \
    "${TRACES[3]}"

  if compgen -G "results_10M/*${BINARY}*.txt" > /dev/null; then
    cp results_10M/*"${BINARY}"*.txt "$OUTDIR"/
  fi
done

echo "Done."