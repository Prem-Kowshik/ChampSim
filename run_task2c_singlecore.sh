#!/usr/bin/env bash
set -euo pipefail


ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHAMPSIM_ROOT="${CHAMPSIM_ROOT:-$ROOT_DIR}"
RUN_SINGLE="${RUN_SINGLE:-$CHAMPSIM_ROOT/run_champsim.sh}"
RESULT_ROOT="${RESULT_ROOT:-$CHAMPSIM_ROOT/results}"
OUT_ROOT="$RESULT_ROOT/task2_singlecore"

EXPERIMENT_TAG="${EXPERIMENT_TAG:-task2c}"
BRANCH="${BRANCH:-bimodal}"
POLICIES=("lru" "srrip" "drrip" "ship" "mru" "random" "hct")
WARMUP="${WARMUP:-1000000}"
SIM="${SIM:-10000000}"

TRACES=(
  "401.bzip2-277B.champsimtrace.xz"
  "403.gcc-16B.champsimtrace.xz"
  "434.zeusmp-10B.champsimtrace.xz"
  "437.leslie3d-273B.champsimtrace.xz"
)

mkdir -p "$OUT_ROOT/$EXPERIMENT_TAG"

if [[ ! -x "$RUN_SINGLE" ]]; then
  echo "ERROR: $RUN_SINGLE not found or not executable" >&2
  exit 1
fi

MANIFEST="$OUT_ROOT/$EXPERIMENT_TAG/manifest.csv"
echo "policy,trace,binary,log_file" > "$MANIFEST"

for policy in "${POLICIES[@]}"; do
  binary="${BRANCH}-no-no-no-no-${policy}-1core"
  if [[ ! -x "$binary" ]]; then
    echo "WARN: missing binary: $binary" >&2
    continue
  fi

  outdir="$OUT_ROOT/$EXPERIMENT_TAG/$policy"
  mkdir -p "$outdir"

  for trace in "${TRACES[@]}"; do
    logfile="$outdir/${trace%.xz}.log"
    echo "[single 2c] tag=$EXPERIMENT_TAG policy=$policy trace=$trace"
    (
      cd "$CHAMPSIM_ROOT"
      "$RUN_SINGLE" "$binary" "$WARMUP" "$SIM" "$trace"
    ) | tee "$logfile"
    echo "$policy,$trace,$binary,$logfile" >> "$MANIFEST"
  done
done

echo "Done. Logs stored in: $OUT_ROOT/$EXPERIMENT_TAG"
echo "Manifest: $MANIFEST"
