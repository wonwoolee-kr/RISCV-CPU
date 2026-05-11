#!/usr/bin/env bash

set -e                                              #error 발생시 즉시 중지

mkdir -p build
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling Immediate Generator TB..."

iverilog -g2012 \
    -o build/tb_imm_gen.vvp \
    rtl/common/rv32i_pkg.sv \
    rtl/core/imm_gen.sv \
    tb/unit/tb_imm_gen.sv

echo "[INFO] Running Immediate Generator simulation..."

vvp build/tb_imm_gen.vvp | tee sim/log/tb_imm_gen.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_imm_gen.vcd"
echo "[INFO] Log : sim/log/tb_imm_gen.log"