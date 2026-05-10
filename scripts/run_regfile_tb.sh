#!/usr/bin/env bash

set -e

mkdir -p build
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling Register File TB..."

iverilog -g2012 \
    -o build/tb_regfile.vvp \
    rtl/common/rv32i_pkg.sv \
    rtl/core/regfile.sv \
    tb/unit/tb_regfile.sv

echo "[INFO] Running Register File simulation..."

vvp build/tb_regfile.vvp | tee sim/log/tb_regfile.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_regfile.vcd"
echo "[INFO] Log : sim/log/tb_regfile.log"
