#!/usr/bin/env bash

set -e

mkdir -p build
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling Control Unit TB..."

iverilog -g2012 \
    -o build/tb_control_unit.vvp \
    rtl/common/rv32i_pkg.sv \
    rtl/core/control_unit.sv \
    tb/unit/tb_control_unit.sv

echo "[INFO] Running Control Unit simulation..."

vvp build/tb_control_unit.vvp | tee sim/log/tb_control_unit.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_control_unit.vcd"
echo "[INFO] Log : sim/log/tb_control_unit.log"