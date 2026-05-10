# RV32I CPU Architecture

## 1. Project Goal

The goal of this project is to implement an RV32I-based CPU core and use it as a portfolio project for digital front-end design, RTL design, and SoC/IP design roles.

## 2. Initial Target

The first target is a single-cycle RV32I subset CPU.

Initial supported instructions:

- ADD
- SUB
- AND
- OR
- XOR
- ADDI
- LW
- SW
- BEQ

## 3. Single-Cycle Datapath

Basic datapath:

PC -> Instruction Memory -> Decoder -> Register File -> ALU -> Data Memory -> Writeback

## 4. Main Blocks

- PC
- Instruction Memory
- Decoder
- Control Unit
- Register File
- Immediate Generator
- ALU
- Branch Unit
- Data Memory
- Writeback Mux

## 5. Future Extension

- Full RV32I subset expansion
- 5-stage pipeline
- Forwarding, stall, and flush
- AXI-Lite peripheral integration