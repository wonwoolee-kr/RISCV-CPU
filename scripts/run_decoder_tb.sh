#!/usr/bin/env bash

set -e

mkdir -p build
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling Decoder TB..."

iverilog -g2012 \
    -o build/tb_decoder.vvp \
    rtl/common/rv32i_pkg.sv \
    rtl/core/decoder.sv \
    tb/unit/tb_decoder.sv

echo "[INFO] Running Decoder simulation..."

vvp build/tb_decoder.vvp | tee sim/log/tb_decoder.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_decoder.vcd"
echo "[INFO] Log : sim/log/tb_decoder.log"