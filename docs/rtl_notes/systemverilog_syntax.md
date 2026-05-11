# SystemVerilog Syntax Notes

#systemverilog #rtl #verification #riscv

## 1. Purpose

This document summarizes the SystemVerilog syntax and RTL coding concepts used in the RV32I CPU project.

The goal is not to cover every SystemVerilog feature, but to organize the syntax that is directly used in this project.

Current focus:

- Synthesizable RTL style
- Basic testbench syntax
- Package and parameter usage
- Combinational and sequential logic
- Common mistakes during RTL coding

---

## 2. `` `timescale ``

Example:

```systemverilog
`timescale 1ns/1ps
```

This directive defines the simulation time unit and time precision.

```text
time unit      = 1ns
time precision = 1ps
```

If the testbench contains:

```systemverilog
#1;
```

then `#1` means 1ns.

If the simulation output says:

```text
$finish called at 6000 (1ps)
```

it means the simulation ended at 6000ps, which is 6ns.

---

## 3. `logic`

Example:

```systemverilog
logic [31:0] data;
```

`logic` is a SystemVerilog data type used to represent digital signals.

In older Verilog, designers often had to choose between `wire` and `reg`.  
SystemVerilog `logic` reduces this confusion in many RTL designs.

Examples from this project:

```systemverilog
input  logic [XLEN-1:0] a_i;
output logic [XLEN-1:0] result_o;
```

In this project, most internal and port signals are declared using `logic`.

---

## 4. `parameter` and `localparam`

### `parameter`

A `parameter` is a **configurable** constant.

Example:

```systemverilog
parameter int XLEN = 32;
```

In this project, `XLEN` represents the RISC-V integer register width.

For RV32I:

```text
XLEN = 32
```

Other examples:

```systemverilog
parameter int ALU_OP_WIDTH  = 4;
parameter int REG_COUNT     = 32;
parameter int REG_ADDR_WIDTH = 5;
```

Using parameters makes the RTL easier to understand and maintain.

---

### `localparam`

A `localparam` is a constant that should ***not be overridden*** from outside the module or package.

Example:

```systemverilog
localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
```

In this project, ALU operation codes are defined as `localparam` because they are internal design constants.

Example:

```systemverilog
localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
localparam logic [ALU_OP_WIDTH-1:0] ALU_SUB = 4'd1;
localparam logic [ALU_OP_WIDTH-1:0] ALU_AND = 4'd2;
localparam logic [ALU_OP_WIDTH-1:0] ALU_OR  = 4'd3;
localparam logic [ALU_OP_WIDTH-1:0] ALU_XOR = 4'd4;
```

---

## 5. `package`

A `package` is used to collect definitions that are shared by multiple modules.

Example:

```systemverilog
package rv32i_pkg;

    parameter int XLEN = 32;
    parameter int ALU_OP_WIDTH = 4;

endpackage
```

In this project, `rv32i_pkg.sv` contains common definitions such as:

- `XLEN`
- `ALU_OP_WIDTH`
- `REG_COUNT`
- `REG_ADDR_WIDTH`
- `ALU operation codes`

Using a package avoids duplicating the same constants in multiple files.

---

## 6. `import`

Example:

```systemverilog
module alu
    import rv32i_pkg::*;
(
    input logic [XLEN-1:0] a_i
);
```

This means the module can use names defined in `rv32i_pkg`.

The `*` means all visible definitions from the package are imported.

Examples of imported names:

```text
XLEN
ALU_OP_WIDTH
REG_COUNT
REG_ADDR_WIDTH
ALU_ADD
ALU_SUB
```

The package file must be compiled before the module that imports it.

Correct compile order:

```bash
iverilog -g2012 \
    rtl/common/rv32i_pkg.sv \
    rtl/core/alu.sv \
    tb/unit/tb_alu.sv
```

---

## 7. Module Port Declaration

A module defines its interface using input and output ports.

Example:

```systemverilog
module alu
    import rv32i_pkg::*;
(
    input  logic [XLEN-1:0]         a_i,
    input  logic [XLEN-1:0]         b_i,
    input  logic [ALU_OP_WIDTH-1:0] alu_op_i,

    output logic [XLEN-1:0]         result_o,
    output logic                    zero_o
);
```

Inside the port list, ports are separated by commas.

---

## 8. Naming Convention

This project uses suffixes to make signal directions clear.

| Suffix | Meaning |
|---|---|
| `_i` | input |
| `_o` | output |
| `_n` | active-low signal |
| `_ni` | active-low input |

Examples:

```systemverilog
clk_i
rst_ni
result_o
zero_o
```

`rst_ni` means:

```text
reset, active-low, input
```

This naming style improves readability, especially when modules become larger.

---

## 9. `always_comb`

`always_comb` is used for combinational logic.

Example:

```systemverilog
always_comb begin
    result_o = '0;

    case (alu_op_i)
        ALU_ADD : result_o = a_i + b_i;
        ALU_SUB : result_o = a_i - b_i;
        default : result_o = '0;
    endcase
end
```

Use `always_comb` when the output depends only on current inputs.

Examples:

- ALU operation
- Decoder logic
- Immediate generation
- Mux selection logic

In this project, the ALU uses `always_comb` because it has no clock and no internal state.

---

## 10. `always_ff`

`always_ff` is used for sequential logic.

Example:

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        q <= '0;
    end else begin
        q <= d;
    end
end
```

Use `always_ff` when a signal is updated on a clock edge.

Examples:

- Register file write
- Program counter
- Pipeline registers
- FSM state registers

In this project, the register file write logic uses `always_ff` because the register file stores state.

---

## 11. Blocking and Non-blocking Assignment

### Blocking assignment: `=`

Blocking assignment is usually used in combinational logic.

Example:

```systemverilog
always_comb begin
    result_o = a_i + b_i;
end
```

### Non-blocking assignment: `<=`

Non-blocking assignment is usually used in clocked sequential logic.

Example:

```systemverilog
always_ff @(posedge clk_i) begin
    q <= d;
end
```

General rule:

```text
Combinational logic → use =
Sequential logic    → use <=
```

This convention helps avoid simulation and synthesis mismatches.

---

## 12. Default Assignment

In combinational logic, outputs should be assigned in every possible condition.

Example:

```systemverilog
always_comb begin
    result_o = '0;

    case (alu_op_i)
        ALU_ADD : result_o = a_i + b_i;
        ALU_SUB : result_o = a_i - b_i;
        default : result_o = '0;
    endcase
end
```

The line:

```systemverilog
result_o = '0;
```

is a default assignment.

It helps prevent unintended latch inference.

If an output is not assigned in some branch of combinational logic, the synthesis tool may infer a latch to preserve the previous value.

---

## 13. `'0` and `'1`

### `'0`

```systemverilog
result_o = '0;
```

`'0` means all bits of the destination signal are filled with zero.

Example:

```systemverilog
logic [31:0] a;
logic [7:0]  b;

a = '0;  // 32-bit zero
b = '0;  // 8-bit zero
```

This is useful when the signal width is parameterized.

---

### `'1`

```systemverilog
mask = '1;
```

`'1` means all bits of the destination signal are filled with one.

Example:

```systemverilog
logic [7:0] mask;

mask = '1;  // 8'b1111_1111
```

This is different from:

```systemverilog
mask = 1;   // 8'b0000_0001
```

---

## 14. `case` Statement

A `case` statement selects behavior based on a signal value.

Example:

```systemverilog
case (alu_op_i)
    ALU_ADD : result_o = a_i + b_i;
    ALU_SUB : result_o = a_i - b_i;
    ALU_AND : result_o = a_i & b_i;
    default : result_o = '0;
endcase
```

In hardware, this usually becomes selection logic or mux-like logic.

The `default` branch is useful because it defines behavior for unexpected values.

---

## 15. Continuous Assignment: `assign`

`assign` describes continuous combinational logic.

Example:

```systemverilog
assign zero_o = (result_o == '0);
```

Whenever `result_o` changes, `zero_o` is updated.

Another example:

```systemverilog
assign rdata1_o = (raddr1_i == '0) ? '0 : rf[raddr1_i];
```

This means the read data changes when the read address changes.

---

## 16. Ternary Operator

The ternary operator is a compact conditional expression.

Example:

```systemverilog
assign rdata1_o = (raddr1_i == '0) ? '0 : rf[raddr1_i];
```

Meaning:

```text
if raddr1_i == 0:
    rdata1_o = 0
else:
    rdata1_o = rf[raddr1_i]
```

This is useful for simple mux-like logic.

In the register file, it is used to make reads from `x0` always return zero.

---

## 17. `task (automatic)`

A `task` groups repeated testbench actions.

Example:

```systemverilog
task automatic check_result;
    input logic [31:0] expected;
    begin
        ...
    end
endtask
```

In this project, tasks are used in testbenches to avoid repeated code.

Examples:

- `check_result`
- `write_reg`
- `check_read`

`automatic` gives the task automatic storage, which is safer when the task is called multiple times.

---

## 18. System Tasks in Testbench

### `$display`

Prints a message during simulation.

```systemverilog
$display("ALU TEST PASSED");
```

### `$finish`

Ends the simulation.

```systemverilog
$finish;
```

### `$dumpfile`

Specifies the waveform dump file.

```systemverilog
$dumpfile("sim/wave/tb_alu.vcd");
```

### `$dumpvars`

Selects which signals to dump.

```systemverilog
$dumpvars(0, tb_alu);
```

<u>`$dumpvars(0, tb_alu)` dumps signals under the `tb_alu` hierarchy.</u>

---

## 19. `==` vs `===`

### `==`

`==` is logical equality.

If either side contains `X` or `Z`, the result may become unknown.

### `===`

`===` is case equality.

It compares `0`, `1`, `X`, and `Z` exactly.

In testbenches, `===` is often preferred because it can detect unexpected `X` or `Z` values.

Example:

```systemverilog
if (result === expected) begin
    $display("[PASS]");
end else begin
    $display("[FAIL]");
end
```

---

## 20. Active-Low Reset

Example:

```systemverilog
input logic rst_ni;
```

`rst_ni` means reset input, active-low.

The reset is asserted when the signal is 0.

Example:

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        q <= '0;
    end else begin
        q <= d;
    end
end
```

Meaning:

```text
if rst_ni == 0:
    reset the register
else:
    update normally on clock edge
```
### Why use Active-Low Reset?

Active-low reset is commonly used in digital hardware design because many reset circuits, board-level reset sources, and power-on reset circuits are naturally active-low.

In an active-low reset scheme, the reset is asserted when the signal is `0` and deasserted when the signal is `1`.

```text
rst_ni = 0 → reset active
rst_ni = 1 → normal operation
```

There are several practical reasons why active-low reset is commonly used.

#### 1. Power-on reset behavior

When a system powers up, the supply voltage does not immediately reach its target voltage. It gradually rises from 0V to the operating voltage.

During this unstable power-up period, an active-low reset signal can naturally start from `0`, keeping the system in reset until the voltage and reset circuitry become stable.

This is useful because the digital logic should not begin normal operation before the power supply and clock are stable.

#### 2. Easy combination of multiple reset sources

Active-low reset signals are also convenient when multiple reset sources need to be combined.

With open-drain or open-collector style reset circuits, multiple devices can share one reset line. If any device pulls the reset line low, the entire system enters reset.

This is often conceptually described as a Wired-OR structure(Although technically it is Wired-AND configuration), although the physical behavior is that multiple devices can pull the shared line down to `0`.

Conceptually:

```text
Any reset source pulls reset low
→ shared reset line becomes 0
→ system reset is asserted
```

This makes board-level reset distribution simple and economical.

#### 3. Asynchronous reset assertion and reset release

In RTL, active-low asynchronous reset is often written as:

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        q <= '0;
    end else begin
        q <= d;
    end
end
```

The `negedge rst_ni` in the sensitivity list means that reset assertion is asynchronous.  
In other words, when `rst_ni` goes from `1` to `0`, the register is reset immediately without waiting for a clock edge.

However, reset release is more delicate.

If reset is released from `0` to `1` at an arbitrary time relative to the clock, flip-flops may experience timing problems such as metastability or recovery/removal violations.

For this reason, practical designs often use the following strategy:

```text
Asynchronous reset assertion
Synchronous reset deassertion
```

This means reset can be asserted immediately, but reset release should be synchronized to the clock domain using a reset synchronizer.

A common interview-level summary is:

```text
Reset assertion can be asynchronous for immediate recovery,
but reset deassertion should be synchronized to avoid metastability and timing issues.
```

In this project, `rst_ni` is used as an active-low asynchronous reset for simplicity.  
In a larger SoC or multi-clock design, reset synchronization should be considered for each clock domain.

---

## 21. Common Mistakes

### Mistake 1. Using semicolons in the module port list

Wrong:

```systemverilog
module example (
    input logic clk_i;
    input logic rst_ni;
);
```

Correct:

```systemverilog
module example (
    input logic clk_i,
    input logic rst_ni
);
```

Inside the port list, use commas.

---

### Mistake 2. Forgetting compile order

If a module imports a package, the package must be compiled first.

Correct:

```bash
iverilog -g2012 \
    rtl/common/rv32i_pkg.sv \
    rtl/core/alu.sv \
    tb/unit/tb_alu.sv
```

Wrong:

```bash
iverilog -g2012 \
    rtl/core/alu.sv \
    rtl/common/rv32i_pkg.sv
```

The compiler may not know what `rv32i_pkg` is.

---

### Mistake 3. Confusing `funct3` with `alu_op_i`

`funct3` is a field inside a RISC-V instruction.

`alu_op_i` is an internal ALU control signal.

The decoder/control unit will later translate instruction fields into internal control signals.

---

### Mistake 4. Forgetting x0 behavior

In RISC-V, register `x0` must always read as zero.

Therefore, a register file should:

- Ignore writes to `x0`
- Return zero when reading `x0`

---

### Mistake 5. Forgetting default assignment in combinational logic

In combinational logic, every output should be assigned in every possible condition.

Without default assignment, unintended latch inference may occur.

---

## 22. Current Project Usage Summary

| Concept | Used In |
|---|---|
| `package` | `rv32i_pkg.sv` |
| `parameter` | `XLEN`, `REG_COUNT`, `REG_ADDR_WIDTH` |
| `localparam` | ALU operation codes |
| `always_comb` | `alu.sv` |
| `always_ff` | `regfile.sv` |
| `assign` | `zero_o`, register file read ports |
| `task automatic` | ALU and register file testbenches |
| `$display` | Test result messages |
| `$dumpfile`, `$dumpvars` | Waveform generation |
| `===` | Self-checking testbench comparison |

---

## 23. Study Summary

Important points learned so far:

- `XLEN` represents the RISC-V integer register width.
- `package` is useful for shared constants.
- `always_comb` is used for combinational logic.
- `always_ff` is used for sequential logic.
- Blocking assignment `=` is mainly used in combinational logic.
- Non-blocking assignment `<=` is mainly used in sequential logic.
- Default assignment helps prevent unintended latch inference.
- Register file write is synchronous.
- Register file read is combinational.
- RISC-V register `x0` must always read as zero.
- Self-checking testbenches are better than manual waveform-only checking.