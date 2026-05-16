# Control Unit Module

#rtl #systemverilog #riscv #controlpath #datapath

## 1. Purpose

#### Control Unit

`A combinational logic block that generates datapath control signals from decoded instruction flags`

The Control Unit receives first-level decode results from the Decoder and generates control signals for the datapath.

In the Patterson & Hennessy single-cycle datapath, the Control block generates signals such as `RegWrite`, `ALUSrc`, `MemRead`, `MemWrite`, `Branch`, and `MemtoReg`.

In this project, `MemtoReg` is generalized as `wb_sel_o`, which selects the writeback source.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/control_unit.sv` | Control Unit RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Writeback select constants |
| `tb/unit/tb_control_unit.sv` | Self-checking Control Unit testbench |
| `scripts/run_control_unit_tb.sh` | Control Unit simulation script |
| `sim/log/tb_control_unit.log` | Control Unit simulation log |
| `sim/wave/tb_control_unit.vcd` | Control Unit waveform dump |

---

## 3. Interface

```systemverilog
module control_unit
    import rv32i_pkg::*;
(
    input  logic                         is_r_type_i,
    input  logic                         is_op_imm_i,
    input  logic                         is_load_i,
    input  logic                         is_store_i,
    input  logic                         is_branch_i,
    input  logic                         instr_valid_i,

    output logic                         reg_write_o,
    output logic                         alu_src_o,
    output logic                         mem_read_o,
    output logic                         mem_write_o,
    output logic                         branch_o,
    output logic [WB_SEL_WIDTH-1:0]      wb_sel_o
);
```

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `is_r_type_i` | 1-bit | Indicates R-type instruction |
| `is_op_imm_i` | 1-bit | Indicates OP-IMM instruction |
| `is_load_i` | 1-bit | Indicates load instruction |
| `is_store_i` | 1-bit | Indicates store instruction |
| `is_branch_i` | 1-bit | Indicates branch instruction |
| `instr_valid_i` | 1-bit | Indicates whether the instruction is valid |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `reg_write_o` | 1-bit | Register File write enable |
| `alu_src_o` | 1-bit | ALU operand B source select |
| `mem_read_o` | 1-bit | Data memory read enable |
| `mem_write_o` | 1-bit | Data memory write enable |
| `branch_o` | 1-bit | Branch instruction signal |
| `wb_sel_o` | `WB_SEL_WIDTH` | Writeback source select |

---

## 4. Decoder vs Control Unit

The Decoder and Control Unit have different responsibilities.

### Decoder

The Decoder identifies what the instruction is.

It generates:

```text
instruction category flags
register addresses
ALU operation
immediate type
instruction valid flag
```

### Control Unit

The Control Unit decides how the datapath should move data.

It generates:

```text
register write enable
ALU source select
memory read/write enable
branch signal
writeback source select
```

Example for `LW`:

```text
Decoder:
is_load = 1
imm_sel = IMM_I
alu_op  = ALU_ADD

Control Unit:
reg_write = 1
alu_src   = 1
mem_read  = 1
wb_sel    = WB_MEM
```

---

## 5. Control Signal Summary

| Instruction Type | RegWrite | ALUSrc | MemRead | MemWrite | Branch | WBSel |
|---|---:|---:|---:|---:|---:|---|
| R-type | 1 | 0 | 0 | 0 | 0 | `WB_ALU` |
| OP-IMM | 1 | 1 | 0 | 0 | 0 | `WB_ALU` |
| LOAD | 1 | 1 | 1 | 0 | 0 | `WB_MEM` |
| STORE | 0 | 1 | 0 | 1 | 0 | `WB_NONE` |
| BRANCH | 0 | 0 | 0 | 0 | 1 | `WB_NONE` |
| Invalid | 0 | 0 | 0 | 0 | 0 | `WB_NONE` |

---

## 6. `reg_write_o`

`reg_write_o` enables writing data back to the Register File.

Instructions that write to `rd`:

- R-type
- OP-IMM
- LOAD

Instructions that do not write to `rd`:

- STORE
- BRANCH
- Invalid instruction

Example:

```text
ADD  → write ALU result to rd
ADDI → write ALU result to rd
LW   → write memory read data to rd
SW   → no register write
BEQ  → no register write
```

---

## 7. `alu_src_o`

`alu_src_o` selects the second ALU operand.

```text
alu_src_o = 0 → ALU operand B = rs2_data
alu_src_o = 1 → ALU operand B = immediate
```

Instruction behavior:

| Instruction Type | ALU Operand B |
|---|---|
| R-type | `rs2_data` |
| OP-IMM | `imm` |
| LOAD | `imm` |
| STORE | `imm` |
| BRANCH | `rs2_data` |

For load and store instructions, the ALU computes the memory address:

```text
address = rs1_data + immediate
```

---

## 8. `mem_read_o` and `mem_write_o`

These signals control Data Memory access.

### `mem_read_o`

Used for load instructions.

```text
LW → mem_read_o = 1
```

### `mem_write_o`

Used for store instructions.

```text
SW → mem_write_o = 1
```

Other instruction types do not access Data Memory.

---

## 9. `branch_o`

`branch_o` indicates that the current instruction is a branch instruction.

For `BEQ`, the actual branch decision also requires the ALU zero flag.

```text
pc_src = branch_o & zero_o
```

The Control Unit only indicates that the instruction is a branch.  
The final branch taken decision is made by combining this signal with the ALU comparison result.

---

## 10. `wb_sel_o`

`wb_sel_o` selects the data source used for register writeback.

Writeback select values:

```systemverilog
localparam logic [WB_SEL_WIDTH-1:0] WB_ALU  = 2'd0;
localparam logic [WB_SEL_WIDTH-1:0] WB_MEM  = 2'd1;
localparam logic [WB_SEL_WIDTH-1:0] WB_NONE = 2'd3;
```

| `wb_sel_o` | Meaning |
|---|---|
| `WB_ALU` | Write back ALU result |
| `WB_MEM` | Write back Data Memory read data |
| `WB_NONE` | No writeback source is used |

Examples:

```text
ADD, SUB, ADDI → WB_ALU
LW             → WB_MEM
SW, BEQ         → WB_NONE
```

---

## 11. Invalid Instruction Handling

The Control Unit checks `instr_valid_i`.

If `instr_valid_i` is `0`, all side-effect control signals remain disabled.

```text
reg_write_o = 0
mem_write_o = 0
branch_o    = 0
wb_sel_o    = WB_NONE
```

This prevents unsupported or invalid instructions from accidentally modifying registers, memory, or PC flow.

---

## 12. RTL Implementation Notes

The Control Unit is implemented as combinational logic.

```systemverilog
always_comb begin
    reg_write_o = 1'b0;
    alu_src_o   = 1'b0;
    mem_read_o  = 1'b0;
    mem_write_o = 1'b0;
    branch_o    = 1'b0;
    wb_sel_o    = WB_NONE;

    if (instr_valid_i) begin
        if (is_r_type_i) begin
            reg_write_o = 1'b1;
            alu_src_o   = 1'b0;
            wb_sel_o    = WB_ALU;
        end
        ...
    end
end
```

Default assignments are used to prevent unintended latch inference.

The default state disables all side effects.

This is a safe default because invalid or unsupported instructions should not write registers, write memory, or update branch control.

---

## 13. Testbench Strategy

The Control Unit testbench is a self-checking testbench.

It applies instruction category flags and checks whether the generated control signals match the expected values.

Tested cases:

- R-type control
- OP-IMM control
- LOAD control
- STORE control
- BRANCH control
- Invalid instruction behavior
- Valid instruction with no type flag

The testbench checks all output control signals:

```text
reg_write_o
alu_src_o
mem_read_o
mem_write_o
branch_o
wb_sel_o
```

---

## 14. Simulation Result

Simulation command:

```bash
make control_unit
```

Expected result:

```text
PASS: 7
FAIL: 0
CONTROL UNIT TEST PASSED
```

---

## 15. Study Notes

### Q1. What is the role of the Control Unit?

The Control Unit generates datapath control signals based on decoded instruction information.

It decides whether the CPU should write to the register file, use an immediate operand, access memory, perform branch control, or select a writeback source.

---

### Q2. How is the Control Unit different from the Decoder?

The Decoder identifies what the instruction is.

The Control Unit decides how the datapath should behave for that instruction.

In this project, this separation improves readability, testability, and pipeline extensibility.

---

### Q3. Why does `LW` set both `reg_write_o` and `mem_read_o`?

`LW` reads data from memory and writes the loaded data into `rd`.

Therefore:

```text
mem_read_o  = 1
reg_write_o = 1
wb_sel_o    = WB_MEM
```

---

### Q4. Why does `SW` set `mem_write_o` but not `reg_write_o`?

`SW` stores register data into memory.

It does not write a result back to the Register File.

Therefore:

```text
mem_write_o = 1
reg_write_o = 0
```

---

### Q5. Why does `BEQ` not write to the Register File?

`BEQ` only changes the program flow depending on the comparison result.

It does not produce a register writeback result.

Therefore:

```text
reg_write_o = 0
branch_o    = 1
```

---

### Q6. Why is `instr_valid_i` used?

`instr_valid_i` prevents invalid instructions from generating side effects.

If an instruction is not supported, the Control Unit disables writes to registers and memory.

This is important for safe control-path behavior.

---

## 16. Future Improvements

Future improvements may include:

- Adding control signals for jump instructions
- Adding control signals for U-type instructions
- Adding exception or illegal instruction handling
- Adding assertions for invalid instruction behavior
- Connecting Control Unit outputs to the single-cycle core datapath