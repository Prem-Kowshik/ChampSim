#!/bin/bash
set -euo pipefail

# Task 2 multicore runner (direct binary invocation)
# Modes:
#   policy -> replacement-policy comparison at baseline LLC
#   size   -> LRU only, LLC size sweep
#   assoc  -> LRU only, associativity sweep
#   all    -> all of the above

MODE="${1:-policy}"
SEED="${2:-42}"

CACHE_H="inc/cache.h"
CACHE_H_BAK="inc/cache.h.bak.task2multi"
RESULTS_DIR="results/task2_multicore"
TRACE_SCRIPT="select_random_traces_task1.py"

WARMUP=1000000
SIM=10000000

mkdir -p "$RESULTS_DIR"

backup_cache_h() {
  if [[ ! -f "$CACHE_H_BAK" ]]; then
    cp "$CACHE_H" "$CACHE_H_BAK"
  fi
}

restore_cache_h() {
  if [[ -f "$CACHE_H_BAK" ]]; then
    cp "$CACHE_H_BAK" "$CACHE_H"
  fi
}

trap restore_cache_h EXIT

set_cache() {
  local sets="$1"
  local ways="$2"

  python3 - "$CACHE_H" "$sets" "$ways" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
sets = sys.argv[2]
ways = sys.argv[3]

text = path.read_text()
text2, n1 = re.subn(r'(^\s*#define\s+LLC_SET\s+).*$',
                    rf'\g<1>NUM_CPUS*{sets}', text, flags=re.M)
text2, n2 = re.subn(r'(^\s*#define\s+LLC_WAY\s+).*$',
                    rf'\g<1>{ways}', text2, flags=re.M)

if n1 != 1 or n2 != 1:
    raise SystemExit(f"Failed to update LLC_SET/LLC_WAY in {path} (n1={n1}, n2={n2})")

path.write_text(text2)
PY
}

build_4core() {
  local policy="$1"
  ./build_champsim.sh bimodal no no no no "$policy" 4
}

select_traces() {
  if [[ ! -x "./$TRACE_SCRIPT" ]]; then
    chmod +x "./$TRACE_SCRIPT" 2>/dev/null || true
  fi

  mapfile -t TRACES < <(python3 "./$TRACE_SCRIPT" "$SEED")
  if [[ "${#TRACES[@]}" -ne 4 ]]; then
    echo "[ERROR] Trace selector did not return 4 traces."
    exit 1
  fi

  printf '%s\n' "${TRACES[@]}" | tee "$RESULTS_DIR/selected_traces_seed_${SEED}.txt"
}

run_case() {
  local label="$1"
  local policy="$2"
  local sets="$3"
  local ways="$4"

  set_cache "$sets" "$ways"
  build_4core "$policy"

  local bin="bimodal-no-no-no-no-${policy}-4core"
  local outdir="$RESULTS_DIR/$label/$policy"
  mkdir -p "$outdir"

  echo "=================================================="
  echo "Running label=$label policy=$policy sets=$sets ways=$ways"
  echo "Traces: ${TRACES[*]}"
  echo "=================================================="

  ./bin/"$bin" \
    -warmup_instructions "$WARMUP" \
    -simulation_instructions "$SIM" \
    -traces \
    "dpc3_traces/${TRACES[0]}" \
    "dpc3_traces/${TRACES[1]}" \
    "dpc3_traces/${TRACES[2]}" \
    "dpc3_traces/${TRACES[3]}" \
    &> "$outdir/output.log"
}

main() {
  backup_cache_h
  select_traces

  if [[ "$MODE" == "policy" || "$MODE" == "all" ]]; then
    for p in lru mru random srrip drrip ship htc; do
      run_case "baseline_4MB_16way" "$p" 4096 16
    done
  fi

  if [[ "$MODE" == "size" || "$MODE" == "all" ]]; then
    for cfg in \
      "1MB_16way 1024 16" \
      "2MB_16way 2048 16" \
      "4MB_16way 4096 16" \
      "8MB_16way 8192 16"
    do
      read -r label sets ways <<< "$cfg"
      run_case "size_sweep/$label" "lru" "$sets" "$ways"
    done
  fi

  if [[ "$MODE" == "assoc" || "$MODE" == "all" ]]; then
    for cfg in \
      "4MB_16way 4096 16" \
      "4MB_8way 4096 8"
    do
      read -r label sets ways <<< "$cfg"
      run_case "assoc_sweep/$label" "lru" "$sets" "$ways"
    done
  fi

  echo "Done. Results in: $RESULTS_DIR"
}

main "$@"
