#!/usr/bin/env bash

set -e

mkdir -p build
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling Fetch Stage TB..."

iverilog -g2012 \
    -o build/tb_fetch.vvp \
    rtl/common/rv32i_pkg.sv \
    rtl/core/pc.sv \
    rtl/core/instr_mem.sv \
    tb/unit/tb_fetch.sv

echo "[INFO] Running Fetch Stage simulation..."

vvp build/tb_fetch.vvp | tee sim/log/tb_fetch.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_fetch.vcd"
echo "[INFO] Log : sim/log/tb_fetch.log"