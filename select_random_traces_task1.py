#!/usr/bin/env python3
from __future__ import annotations
import random
import sys

TRACES = [
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
    "628.pop2_s-17B.champsimtrace.xz",
]

def main() -> None:
    if len(sys.argv) > 1:
        try:
            random.seed(int(sys.argv[1]))
        except ValueError:
            random.seed(sys.argv[1])

    chosen = random.sample(TRACES, 4)
    for t in chosen:
        print(t)

if __name__ == "__main__":
    main()
