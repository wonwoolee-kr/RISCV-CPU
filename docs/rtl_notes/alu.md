# ALU Module

#rtl #systemverilog #riscv #datapath

## 1. Purpose

#### ALU (Arithmetic Logic Unit)

`One of the fundamental computation blocks of the RV32I CPU core`

The ALU is a combinational logic block in the CPU datapath that performs arithmetic and logical operations. It receives two operands and an ALU control signal as inputs, and produces the operation result and a zero flag.

This ALU will later be connected to the register file, immediate generator, branch unit, and data memory path, forming part of the datapath of the RV32I single-cycle CPU.

Current Supported Operations:

- ADD
- SUB
- AND
- OR
- XOR


---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/alu.sv` | ALU RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Common parameters and ALU operation codes |
| `tb/unit/tb_alu.sv` | Self-checking ALU testbench |
| `scripts/run_alu_tb.sh` | ALU simulation script |
| `sim/log/tb_alu.log` | ALU simulation log |
| `sim/wave/tb_alu.vcd` | ALU waveform dump |

---

## 3. Interface

```systemverilog
module alu
    import rv32i_pkg::*;
(
    input logic  [XLEN-1:0]         a_i,
    input logic  [XLEN-1:0]         b_i,
    input logic  [ALU_OP_WIDTH-1:0] alu_op_i,

    output logic [XLEN-1:0]         result_o,
    output logic                    zero_o
);

endmodule
```

### Input port
| Signal | Width | Description |
|---|---|---|
| `a_i` | `XLEN` | First ALU operand |
| `b_i` | `XLEN` | Second ALU operand |
| `alu_op_i` | `ALU_OP_WIDTH` | ALU operation select signal |

### Output Ports

| Signal | Width | Description |
|---|---|---|
| `result_o` | `XLEN` | ALU operation result |
| `zero_o` | 1-bit | High when `result_o` is zero |


## 4. Key Parameter

The ALU uses common parameters and operation codes defined in `rtl/common/rv32i_pkg.sv`.

```systemverilog
parameter int XLEN = 32;
parameter int ALU_OP_WIDTH = 4;
```

### `XLEN`
`XLEN` is a RISC-V term that represents the width of the integer register.

For RV32I:

```text
XLEN =32
```

Therefore, the ALU operands and result are 32-bit width.

In this project:

```systemverilog
input   logic [XLEN-1:0] a_i;
input   logic [XLEN-1:0] b_i;
output  logic [XLEN-1:0] result_o;
```

means:
```systemverilog
input   logic [31:0] a_i;
input   logic [31:0] b_i;
output  logic [31:0] result_o;
```

Using `XLEN` instead of directly writing `32` makes the design easier to read and easier to extend later.

### `ALU_OP_WIDTH`

`ALU_OP_WIDTH` is the width of the internal ALU operation control signal.

In this project:

```systemverilog
parameter int ALU_OP_WIDTH =4;
```

Current ALU operation codes are:

```systemverilog
localparam logic [ALU_OP_WIDTH-1:0] ALU_ADD = 4'd0;
localparam logic [ALU_OP_WIDTH-1:0] ALU_SUB = 4'd1;
localparam logic [ALU_OP_WIDTH-1:0] ALU_AND = 4'd2;
localparam logic [ALU_OP_WIDTH-1:0] ALU_OR  = 4'd3;
localparam logic [ALU_OP_WIDTH-1:0] ALU_XOR = 4'd4;
```

The ALU currently supports 5 operations, but the operation signal is defined as 4-bit to leave room for future operations such as:

- SLL
- SRL
- SRA
- SLT
- SLTU

---

## 5. `alu_op_i` and RISC-V Instruction Fields

`alu_op_i` is not exactly the same as the RISC-V `funct3` field.

RISC-V instructions contain fields such as:
| Field | Description |
|---|---|
| `opcode` | Main instruction type |
| `funct3` | Sub-operation field |
| `funct7` | Additional operation field |
| `rs1` | Source register 1 |
| `rs2` | Source register 2 |
| `rd` | Destination register |

For example, `ADD` and `SUB` can share the same `funct3` value, but they are distinguished using `funct7`.

The ALU itself does not need to know the full instruction format.

Instead, the decoder/control unit will later interpret:

```text
opcode + funct3 + funct7
```

and generate an internal ALU control signal such as:

```text
ALU_ADD
ALU_SUB
ALU_AND
ALU_OR
ALU_XOR
```

Therefore:

```text
RISC-V instruction fields → decoder/control unit → alu_op_i → ALU operation
```

This separation makes the ALU simpler and keeps instruction decoding logic outside the ALU.

---

## 6. RTL Implementation Notes

The ALU is implemented as combinational logic.

```systemverilog
always_comb begin
    result_o = '0;

    case (alu_op_i)
        ALU_ADD : result_o = a_i + b_i;
        ALU_SUB : result_o = a_i - b_i;
        ALU_AND : result_o = a_i & b_i;
        ALU_OR  : result_o = a_i | b_i;
        ALU_XOR : result_o = a_i ^ b_i;
        default : result_o = '0;
    endcase
end
```

### Why `always_comb`?

The ALU does not store any state.

It only calculates an output from the current input values.

```text
a_i, b_i, alu_op_i change
→ result_o changes
```

There is no clock in the ALU module.

Therefore, `always_comb` is appropriate.

If a circuit stores data on a clock edge, `always_ff` should be used.  
If a circuit simply computes outputs from current inputs, `always_comb` should be used.

In this ALU:

```text
No clock
No internal state
No register update
```

So it is combinational logic.

---

## 7. Default Assignment

At the beginning of the `always_comb` block:

```systemverilog
result_o = '0;
```

This gives `result_o` a default value.

The reason is to make sure that `result_o` is assigned in every possible case.

If an output is not assigned for every possible input condition in combinational logic, synthesis tools may infer an unintended latch.

A latch means the circuit tries to remember the previous value.  
That is not what we want in this ALU.

Therefore, the default assignment helps prevent unintended latch inference.

---

## 8. Meaning of `'0`

In SystemVerilog:

```systemverilog
result_o = '0;
```

means:

```text
Fill all bits of result_o with zero.
```

If `result_o` is 32-bit:

```systemverilog
result_o = '0;
```

means:

```systemverilog
result_o = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
```

If `result_o` later becomes 64-bit, `'0` automatically becomes 64-bit zero.

This is why `'0` is useful when the signal width is parameterized by `XLEN`.

The following are all possible ways to assign zero:

```systemverilog
result_o = 0;
result_o = 32'd0;
result_o = '0;
```

In this project, `'0` is used because it clearly means:

```text
Set all bits of the destination signal to zero.
```

---

## 9. Zero Flag

The zero flag is implemented using continuous assignment.

```systemverilog
assign zero_o = (result_o == '0);
```

This means:

```text
If result_o is zero, zero_o becomes 1.
Otherwise, zero_o becomes 0.
```

The zero flag is useful for branch instructions.

For example, `BEQ` means branch if equal.

One way to check equality is:

```text
rs1 - rs2
```

If the subtraction result is zero:

```text
rs1 == rs2
```

Therefore, the zero flag can be used later by the branch unit.

Example:

```text
ALU_SUB result is zero
→ zero_o = 1
→ BEQ branch condition is true
```

---

## 10. Testbench Strategy

The ALU testbench is a self-checking testbench.

This means the testbench automatically compares the actual output with the expected output.

It does not rely only on manual waveform inspection.

Example test:

```systemverilog
check_result(32'd10, 32'd20, ALU_ADD, 32'd30, "ADD 10 + 20");
```

This means:

```text
a_i = 10
b_i = 20
alu_op_i = ALU_ADD
expected result = 30
```

The testbench checks whether `result_o` is equal to the expected value.

If the result is correct, it prints:

```text
[PASS]
```

If the result is wrong, it prints:

```text
[FAIL]
```

The current testbench verifies:

- ADD
- SUB
- AND
- OR
- XOR
- zero flag

---

## 11. Simulation Result

Simulation command:

```bash
make alu
```

Expected result:

```text
PASS: 7
FAIL: 0
ALU TEST PASSED
```

Current result:

```text
[PASS] ADD 10 + 20
[PASS] SUB 20 - 10
[PASS] AND
[PASS] OR
[PASS] XOR
[PASS] ZERO flag input
[PASS] ZERO flag
ALU TEST PASSED
```

This confirms that the current ALU implementation works correctly for the supported operations.

---

## 12. Interview Questions and Study Notes

### Q1. Why is the ALU implemented with `always_comb`?

The ALU is implemented with `always_comb` because it is combinational logic.

It does not store any state and does not update values on a clock edge.

The output depends only on the current inputs:

```text
result_o = function(a_i, b_i, alu_op_i)
```

Therefore, `always_comb` is more appropriate than `always_ff`.

---

### Q2. Why is there no clock input in the ALU?

The ALU itself only performs calculation.

It does not need to remember previous values.

Clock signals are needed when a circuit stores state, such as:

- Register file
- Program counter
- Pipeline register
- FSM state register

The ALU only computes a result from current inputs, so it does not need a clock.

---

### Q3. Why do we assign a default value to `result_o`?

A default value is assigned to prevent unintended latch inference.

In combinational logic, every output must be assigned in every possible input condition.

If some path does not assign `result_o`, the synthesis tool may infer a latch to hold the previous value.

To avoid that, the ALU sets:

```systemverilog
result_o = '0;
```

at the beginning of the `always_comb` block.

---

### Q4. What is the meaning of `'0`?

`'0` means all bits of the destination signal are filled with zero.

For example:

```systemverilog
logic [31:0] a;
logic [63:0] b;

a = '0;  // 32-bit zero
b = '0;  // 64-bit zero
```

It is useful when signal widths are parameterized.

In this project, `result_o` has width `XLEN`, so `'0` automatically matches the width of `result_o`.

---

### Q5. What is the purpose of `zero_o`?

`zero_o` tells whether the ALU result is zero.

It can be used for branch instructions such as `BEQ`.

For example, if the CPU subtracts two register values and the result is zero, then the two values are equal.

```text
rs1 - rs2 = 0
→ rs1 == rs2
→ BEQ condition is true
```

---

### Q6. Is `alu_op_i` the same as RISC-V `funct3`?

No.

`funct3` is an instruction field inside the RISC-V instruction format.

`alu_op_i` is an internal control signal used by the ALU.

The decoder/control unit will later translate instruction fields such as:

```text
opcode
funct3
funct7
```

into internal ALU operation codes such as:

```text
ALU_ADD
ALU_SUB
ALU_AND
ALU_OR
ALU_XOR
```

This keeps the ALU independent from instruction decoding details.

---

### Q7. Why use `XLEN` instead of directly writing `32`?

`XLEN` improves readability and maintainability.

Instead of writing:

```systemverilog
input logic [31:0] a_i;
```

we write:

```systemverilog
input logic [XLEN-1:0] a_i;
```

This makes it clear that the signal width is related to the RISC-V integer register width.

For RV32I, `XLEN = 32`.

If the project later studies RV64I, `XLEN` would be 64.

---

### Q8. What hardware structure does the `case` statement represent?

The `case` statement selects one operation result based on `alu_op_i`.

In hardware, this is similar to a multiplexer selecting between multiple operation results.

Conceptually:

```text
alu_op_i = ALU_ADD → select add result
alu_op_i = ALU_SUB → select sub result
alu_op_i = ALU_AND → select and result
```

So the `case` statement represents operation selection logic inside the ALU.

---

## 13. Future Improvements

The current ALU supports only a small subset of operations.

Future operations to add:

- SLL
- SRL
- SRA
- SLT
- SLTU

These operations are needed to support more RV32I instructions.

The ALU will later be connected with:

- Register file
- Immediate generator
- Decoder
- Control unit
- Branch unit
- Datapath muxes