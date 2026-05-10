#!/usr/bin/env bash

set -e                      #error 발생시 중단

mkdir -p build              #shell script 실행하는 터미널상 위치에 따라 폴더가 추가 생성가능
mkdir -p sim/wave
mkdir -p sim/log

echo "[INFO] Compiling ALU TB..."

iverilog -g2012 -o build/tb_alu.vvp rtl/common/rv32i_pkg.sv rtl/core/alu.sv tb/unit/tb_alu.sv

echo "[INFO] Running ALU simulation..."

vvp build/tb_alu.vvp | tee sim/log/tb_alu.log

echo "[INFO] Done"
echo "[INFO] Waveform : sim/wave/tb_alu.vcd"
echo "[INFO] Log : sim/log/tb_alu.log"
