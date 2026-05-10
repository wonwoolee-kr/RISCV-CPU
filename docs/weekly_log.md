# Weekly Log

## Week 1 - ALU Module and Testbench

### Completed

- Set up the initial RISC-V CPU project structure.
- Configured Git and pushed the project to GitHub.
- Created `rv32i_pkg.sv` for common RISC-V CPU parameters and ALU operation codes.
- Implemented `alu.sv` using synthesizable SystemVerilog.
- Supported initial ALU operations:
  - ADD
  - SUB
  - AND
  - OR
  - XOR
- Implemented `zero_o` flag for detecting zero ALU result.
- Created a self-checking testbench `tb_alu.sv`.
- Verified ALU operations using Icarus Verilog.
- Generated waveform file:
  - `sim/wave/tb_alu.vcd`
- Created simulation script:
  - `scripts/run_alu_tb.sh`
- Added Makefile target:
  - `make alu`

### Test Result

ALU simulation passed.

Result summary:

- PASS: 7
- FAIL: 0
- Final result: ALU TEST PASSED

### Notes

The ALU is implemented as combinational logic using `always_comb`.

A default output value is assigned in the `always_comb` block to make sure `result_o` is always defined and to avoid unintended latch inference.

The `zero_o` flag will be useful later for branch instructions such as `BEQ`.

### Next Step

Implement and verify the register file.

Target features:

- 32 registers
- 32-bit data width
- Two read ports
- One write port
- Register `x0` hardwired to zero
