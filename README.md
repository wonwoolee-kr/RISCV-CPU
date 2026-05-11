# RV32I CPU Design Portfolio

This project implements an RV32I-based educational CPU core using synthesizable SystemVerilog.

The goal is not only to implement a working CPU, but also to build a digital design portfolio that demonstrates:

- RTL design
- Datapath and control path design
- Self-checking testbench
- Waveform-based debugging
- Synthesis and timing report analysis
- 5-stage pipeline design
- Hazard detection, forwarding, stall, and flush
- AXI-Lite peripheral integration

## Project Roadmap

1. RV32I single-cycle CPU
2. Unit-level testbench for ALU and register file
3. Instruction-level self-checking testbench
4. Waveform analysis
5. Synthesis and timing report analysis
6. 5-stage pipeline CPU
7. Hazard handling
8. AXI-Lite memory-mapped peripheral integration

## Documentation

### Project Documents

- [Architecture](docs/architecture.md)
- [Instruction Subset](docs/instruction_subset.md)
- [Verification Plan](docs/verification_plan.md)
- [Weekly Log](docs/weekly_log.md)

### RTL Design Notes

- [ALU Module](docs/rtl_notes/alu.md)
- [Register File Module](docs/rtl_notes/regfile.md)
- [Immediate Generator Module](docs/rtl_notes/imm_gen.md)
- [SystemVerilog Syntax Notes](docs/rtl_notes/systemverilog_syntax.md)



## Current Status

Week 1:

- Project structure setup completed
- Git/GitHub setup completed
- SystemVerilog language server configuration added
- ALU module implemented and verified
- Register file module implemented and verified
- Basic unit-level self-checking testbenches created

Implemented modules:

|       Module      |              RTL              |           Testbench           |        Status         |
|---|---|---|---|
|        ALU        |       `rtl/core/alu.sv`       |       `tb/unit/tb_alu.sv`     |        Passed         |
|    Register File  |     `rtl/core/regfile.sv`     |     `tb/unit/tb_regfile.sv`   |        Passed         |
| Immediate Generator | `rtl/core/imm_gen.sv` | `tb/unit/tb_imm_gen.sv` | Passed |