#!/bin/bash

set -e

TRACE_DIR="dpc3_traces"
SEED=42

TRACES=(
401.bzip2-277B.champsimtrace.xz
403.gcc-16B.champsimtrace.xz
434.zeusmp-10B.champsimtrace.xz
437.leslie3d-273B.champsimtrace.xz
450.soplex-92B.champsimtrace.xz
456.hmmer-327B.champsimtrace.xz
462.libquantum-1343B.champsimtrace.xz
482.sphinx3-1522B.champsimtrace.xz
605.mcf_s-1644B.champsimtrace.xz
605.mcf_s-665B.champsimtrace.xz
619.lbm_s-3766B.champsimtrace.xz
620.omnetpp_s-874B.champsimtrace.xz
621.wrf_s-8100B.champsimtrace.xz
623.xalancbmk_s-700B.champsimtrace.xz
628.pop2_s-17B.champsimtrace.xz
)

mkdir -p results/task1_multicore

python3 - << EOF > results/task1_multicore/selected_traces.txt
import random
random.seed($SEED)

traces = [
"401.bzip2-277B.champsimtrace.xz",
"403.gcc-16B.champsimtrace.xz",
"434.zeusmp-10B.champsimtrace.xz",
"437.leslie3d-273B.champsimtrace.xz",
"450.soplex-92B.champsimtrace.xz",
"456.hmmer-327B.champsimtrace.xz",
"462.libquantum-1343B.champsimtrace.xz",
"482.sphinx3-1522B.champsimtrace.xz",
"605.mcf_s-1644B.champsimtrace.xz",
"605.mcf_s-665B.champsimtrace.xz",
"619.lbm_s-3766B.champsimtrace.xz",
"620.omnetpp_s-874B.champsimtrace.xz",
"621.wrf_s-8100B.champsimtrace.xz",
"623.xalancbmk_s-700B.champsimtrace.xz",
"628.pop2_s-17B.champsimtrace.xz"
]

selected=random.sample(traces,4)

for t in selected:
    print(t)
EOF

mapfile -t SELECTED < results/task1_multicore/selected_traces.txt

echo "Selected traces:"
printf "%s\n" "${SELECTED[@]}"

PREDICTORS=(
bimodal
gshare
hashed_perceptron
perceptron
)

for predictor in "${PREDICTORS[@]}"
do

echo "======================================"
echo "Running $predictor"
echo "======================================"

./build_champsim.sh $predictor no no no no lru 4

./run_4core.sh \
${predictor}-no-no-no-no-lru-4core \
1 \
10 \
0 \
${SELECTED[0]} \
${SELECTED[1]} \
${SELECTED[2]} \
${SELECTED[3]}

mkdir -p results/task1_multicore/$predictor

cp results_10M/*${predictor}* results/task1_multicore/$predictor/ 2>/dev/null || true

done

echo ""
echo "=================================="
echo "Task 1 Multicore Finished"
echo "=================================="