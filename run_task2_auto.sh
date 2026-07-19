#!/bin/bash
set -euo pipefail

BASE_DIR="$(pwd)"
CACHE_H="inc/cache.h"
CACHE_H_BAK="inc/cache.h.bak.task2"
RESULTS_DIR="results/task2_auto"
WARMUP_M=1
SIM_M=10

SINGLE_TRACES=(
  "401.bzip2-277B.champsimtrace.xz"
  "403.gcc-16B.champsimtrace.xz"
  "450.soplex-92B.champsimtrace.xz"
  "482.sphinx3-1522B.champsimtrace.xz"
)

MULTICORE_SEED=42

POLICIES=(
  "lru"
  "mru"
  "random"
  "srrip"
  "drrip"
  "ship"
  "htc"
)

# LLC configurations
LLC_CONFIGS=(
  "1MB_16way|1024|16"
  "2MB_16way|2048|16"
  "4MB_16way|4096|16"
  "8MB_16way|8192|16"
  "1MB_8way|2048|8"
  "2MB_8way|4096|8"
  "4MB_8way|8192|8"
  "8MB_8way|16384|8"
)

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

set_cache_h() {
  local sets="$1"
  local ways="$2"

  python3 - <<PY
from pathlib import Path
import re

path = Path("$CACHE_H")
text = path.read_text()

text, n1 = re.subn(r'(#define\s+LLC_SET\s+)NUM_CPUS\s*\*\s*\d+',
                   r'\g<1>NUM_CPUS*' + str($sets), text)
text, n2 = re.subn(r'(#define\s+LLC_WAY\s+)\d+',
                   r'\g<1>' + str($ways), text)

if n1 != 1 or n2 != 1:
    raise SystemExit(f"Failed to update LLC_SET/LLC_WAY in {path}")

path.write_text(text)
PY
}

build_policy() {
  local policy="$1"
  local cores="$2"
  ./build_champsim.sh bimodal no no no no "$policy" "$cores"
}

run_single_policy_config() {
  local policy="$1"
  local cfg_label="$2"
  local sets="$3"
  local ways="$4"

  set_cache_h "$sets" "$ways"
  build_policy "$policy" 1

  local bin="bimodal-no-no-no-no-${policy}-1core"
  local outdir="$RESULTS_DIR/$cfg_label/single/$policy"
  mkdir -p "$outdir"

  for trace in "${SINGLE_TRACES[@]}"; do
    echo "[single] cfg=$cfg_label policy=$policy trace=$trace"
    ./run_champsim.sh "$bin" "$WARMUP_M" "$SIM_M" "$trace"
    cp "results_${SIM_M}M/${trace}-${bin}.txt" "$outdir/" 2>/dev/null || true
  done
}

run_multi_policy_config() {
  local policy="$1"
  local cfg_label="$2"
  local sets="$3"
  local ways="$4"
  local selected_file="$5"

  mapfile -t TRACES < "$selected_file"
  if [[ "${#TRACES[@]}" -ne 4 ]]; then
    echo "[ERROR] Multicore selector did not return 4 traces."
    exit 1
  fi

  set_cache_h "$sets" "$ways"
  build_policy "$policy" 4

  local bin="bimodal-no-no-no-no-${policy}-4core"
  local outdir="$RESULTS_DIR/$cfg_label/multi/$policy"
  mkdir -p "$outdir"

  echo "[multi] cfg=$cfg_label policy=$policy traces=${TRACES[*]}"
  ./run_4core.sh "$bin" "$WARMUP_M" "$SIM_M" 0 "${TRACES[0]}" "${TRACES[1]}" "${TRACES[2]}" "${TRACES[3]}"
  cp "results_${SIM_M}M"/*"${bin}"*.txt "$outdir/" 2>/dev/null || true
}

main() {
  backup_cache_h

  local selected_file="$RESULTS_DIR/multicore_selected_traces_seed_${MULTICORE_SEED}.txt"
  python3 select_random_traces_task1.py "$MULTICORE_SEED" > "$selected_file"

  echo "Selected multicore traces saved to: $selected_file"
  cat "$selected_file"

  # Single-core experiments for every LLC config and policy
  for cfg in "${LLC_CONFIGS[@]}"; do
    IFS='|' read -r label sets ways <<< "$cfg"
    echo "========================================"
    echo "Single-core config: $label (sets=$sets ways=$ways)"
    echo "========================================"

    for policy in "${POLICIES[@]}"; do
      run_single_policy_config "$policy" "$label" "$sets" "$ways"
    done
  done

  # Multicore experiments for every LLC config and policy
  for cfg in "${LLC_CONFIGS[@]}"; do
    IFS='|' read -r label sets ways <<< "$cfg"
    echo "========================================"
    echo "Multicore config: $label (sets=$sets ways=$ways)"
    echo "========================================"

    for policy in "${POLICIES[@]}"; do
      run_multi_policy_config "$policy" "$label" "$sets" "$ways" "$selected_file"
    done
  done

  echo "All Task 2 runs completed."
  echo "Results stored in: $RESULTS_DIR"
}

main "$@"
