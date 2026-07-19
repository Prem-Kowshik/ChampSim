#!/usr/bin/env bash
set -euo pipefail


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAMPSIM_ROOT="${CHAMPSIM_ROOT:-$ROOT_DIR}"
RUN_MULTI="${RUN_MULTI:-$CHAMPSIM_ROOT/run_4core.sh}"
TRACE_SELECTOR="${TRACE_SELECTOR:-$CHAMPSIM_ROOT/select_random_traces_task1.py}"
RESULT_ROOT="${RESULT_ROOT:-$CHAMPSIM_ROOT/results}"
OUT_ROOT="$RESULT_ROOT/task2_multicore"

EXPERIMENT_TAG="${EXPERIMENT_TAG:-task2c}"
BRANCH="${BRANCH:-bimodal}"
POLICIES=("lru" "srrip" "drrip" "ship" "mru" "random" "hct")
WARMUP="${WARMUP:-1000000}"
SIM="${SIM:-10000000}"
N_MIX="${N_MIX:-0}"
TRACE_SEED="${TRACE_SEED:-1}"

mkdir -p "$OUT_ROOT/$EXPERIMENT_TAG"

if [[ ! -x "$RUN_MULTI" ]]; then
  echo "ERROR: $RUN_MULTI not found or not executable" >&2
  exit 1
fi
if [[ ! -f "$TRACE_SELECTOR" ]]; then
  echo "ERROR: trace selector not found: $TRACE_SELECTOR" >&2
  exit 1
fi

mapfile -t TRACES < <(python3 "$TRACE_SELECTOR" "$TRACE_SEED")
if [[ "${#TRACES[@]}" -ne 4 ]]; then
  echo "ERROR: selector did not return 4 traces" >&2
  exit 1
fi

printf "%s
" "${TRACES[@]}" > "$OUT_ROOT/$EXPERIMENT_TAG/selected_traces_seed_${TRACE_SEED}.txt"

MANIFEST="$OUT_ROOT/$EXPERIMENT_TAG/manifest.csv"
echo "policy,seed,binary,log_file,trace0,trace1,trace2,trace3" > "$MANIFEST"

for policy in "${POLICIES[@]}"; do
  binary="$CHAMPSIM_ROOT/bin/${BRANCH}-no-no-no-no-${policy}-4core"
  if [[ ! -x "$binary" ]]; then
    echo "WARN: missing binary: $binary" >&2
    continue
  fi

  outdir="$OUT_ROOT/$EXPERIMENT_TAG/$policy"
  mkdir -p "$outdir"
  logfile="$outdir/seed_${TRACE_SEED}.log"

  echo "[multi 2c] tag=$EXPERIMENT_TAG policy=$policy seed=$TRACE_SEED traces=${TRACES[*]}"
  (
    cd "$CHAMPSIM_ROOT"
    "$RUN_MULTI" "$binary" "$WARMUP" "$SIM" "$N_MIX" "${TRACES[0]}" "${TRACES[1]}" "${TRACES[2]}" "${TRACES[3]}"
  ) | tee "$logfile"

  echo "$policy,$TRACE_SEED,$binary,$logfile,${TRACES[0]},${TRACES[1]},${TRACES[2]},${TRACES[3]}" >> "$MANIFEST"
done

echo "Done. Logs stored in: $OUT_ROOT/$EXPERIMENT_TAG"
echo "Selected traces: $OUT_ROOT/$EXPERIMENT_TAG/selected_traces_seed_${TRACE_SEED}.txt"
echo "Manifest: $MANIFEST"
