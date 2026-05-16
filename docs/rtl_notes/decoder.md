# Decoder Module

#rtl #systemverilog #riscv #decoder #controlpath

## 1. Purpose

#### Decoder

`A combinational logic block that extracts instruction fields and performs first-level instruction decoding`

The Decoder receives a 32-bit RISC-V instruction and extracts key instruction fields such as `opcode`, `rd`, `funct3`, `rs1`, `rs2`, and `funct7`.

It then generates first-level decode outputs used by other datapath and control-path blocks.

The Decoder does not execute the instruction.  
Instead, it identifies what type of instruction it is and provides the information required by the Register File, Immediate Generator, ALU, and Control Unit.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/decoder.sv` | Decoder RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Opcode, funct3, funct7, ALU operation, and immediate type constants |
| `tb/unit/tb_decoder.sv` | Self-checking Decoder testbench |
| `scripts/run_decoder_tb.sh` | Decoder simulation script |
| `sim/log/tb_decoder.log` | Decoder simulation log |
| `sim/wave/tb_decoder.vcd` | Decoder waveform dump |

---

## 3. Interface

```systemverilog
module decoder
    import rv32i_pkg::*;
(
    input  logic [INST_WIDTH-1:0]        instr_i,

    output logic [REG_ADDR_WIDTH-1:0]    rs1_addr_o,
    output logic [REG_ADDR_WIDTH-1:0]    rs2_addr_o,
    output logic [REG_ADDR_WIDTH-1:0]    rd_addr_o,

    output logic [ALU_OP_WIDTH-1:0]      alu_op_o,
    output logic [IMM_SEL_WIDTH-1:0]     imm_sel_o,

    output logic                         is_r_type_o,
    output logic                         is_op_imm_o,
    output logic                         is_load_o,
    output logic                         is_store_o,
    output logic                         is_branch_o,

    output logic                         instr_valid_o
);
```

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `instr_i` | `INST_WIDTH` | 32-bit RISC-V instruction input |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `rs1_addr_o` | `REG_ADDR_WIDTH` | Source register 1 address |
| `rs2_addr_o` | `REG_ADDR_WIDTH` | Source register 2 address |
| `rd_addr_o` | `REG_ADDR_WIDTH` | Destination register address |
| `alu_op_o` | `ALU_OP_WIDTH` | ALU operation control signal |
| `imm_sel_o` | `IMM_SEL_WIDTH` | Immediate type select signal |
| `is_r_type_o` | 1-bit | R-type instruction flag |
| `is_op_imm_o` | 1-bit | OP-IMM instruction flag |
| `is_load_o` | 1-bit | Load instruction flag |
| `is_store_o` | 1-bit | Store instruction flag |
| `is_branch_o` | 1-bit | Branch instruction flag |
| `instr_valid_o` | 1-bit | Indicates whether the instruction is supported by the current decoder |

---

## 4. Instruction Field Extraction

A base RISC-V instruction is 32 bits wide.

The Decoder extracts fields using simple bit slicing.

```systemverilog
assign opcode  = instr_i[6:0];
assign rd_raw  = instr_i[11:7];
assign funct3  = instr_i[14:12];
assign rs1_raw = instr_i[19:15];
assign rs2_raw = instr_i[24:20];
assign funct7  = instr_i[31:25];
```

The instruction field layout is:

```text
instr[31:25] = funct7
instr[24:20] = rs2
instr[19:15] = rs1
instr[14:12] = funct3
instr[11:7]  = rd
instr[6:0]   = opcode
```

This part is mainly wiring logic.  
It does not perform computation. It simply connects specific instruction bit ranges to internal decode signals.

---

## 5. Supported Instruction Subset

The current Decoder supports the following initial RV32I subset.

| Instruction | Type | Opcode | ALU Operation | Immediate Type |
|---|---|---|---|---|
| `ADD` | R-type | `OPCODE_OP` | `ALU_ADD` | `IMM_NONE` |
| `SUB` | R-type | `OPCODE_OP` | `ALU_SUB` | `IMM_NONE` |
| `AND` | R-type | `OPCODE_OP` | `ALU_AND` | `IMM_NONE` |
| `OR` | R-type | `OPCODE_OP` | `ALU_OR` | `IMM_NONE` |
| `XOR` | R-type | `OPCODE_OP` | `ALU_XOR` | `IMM_NONE` |
| `ADDI` | I-type OP-IMM | `OPCODE_OP_IMM` | `ALU_ADD` | `IMM_I` |
| `LW` | Load | `OPCODE_LOAD` | `ALU_ADD` | `IMM_I` |
| `SW` | Store | `OPCODE_STORE` | `ALU_ADD` | `IMM_S` |
| `BEQ` | Branch | `OPCODE_BRANCH` | `ALU_SUB` | `IMM_B` |

---

## 6. Opcode Meaning

The opcode identifies the major instruction category.

```systemverilog
localparam logic [OPCODE_WIDTH-1:0] OPCODE_OP     = 7'b0110011;
localparam logic [OPCODE_WIDTH-1:0] OPCODE_OP_IMM = 7'b0010011;
localparam logic [OPCODE_WIDTH-1:0] OPCODE_LOAD   = 7'b0000011;
localparam logic [OPCODE_WIDTH-1:0] OPCODE_STORE  = 7'b0100011;
localparam logic [OPCODE_WIDTH-1:0] OPCODE_BRANCH = 7'b1100011;
```

### `OPCODE_OP`

`OPCODE_OP` means register-register integer ALU operation.

Examples:

```assembly
add x3, x1, x2
sub x3, x1, x2
and x3, x1, x2
```

These instructions use `rs1` and `rs2` as ALU operands.

### `OPCODE_OP_IMM`

`OPCODE_OP_IMM` means register-immediate integer ALU operation.

Example:

```assembly
addi x3, x1, 10
```

This instruction uses `rs1` and an immediate value as ALU operands.

---

## 7. R-type Decode

R-type instructions use two source registers and one destination register.

Example:

```assembly
add x3, x1, x2
```

Expected decode behavior:

```text
rs1_addr_o = x1
rs2_addr_o = x2
rd_addr_o  = x3
imm_sel_o  = IMM_NONE
alu_op_o   = ALU_ADD
is_r_type_o = 1
instr_valid_o = 1
```

For R-type instructions, `funct3` and `funct7` are used to determine the exact ALU operation.

For example, `ADD` and `SUB` share the same `funct3` value but use different `funct7` values.

```text
ADD: funct3 = 000, funct7 = 0000000
SUB: funct3 = 000, funct7 = 0100000
```

---

## 8. I-type OP-IMM Decode

OP-IMM instructions use one source register and one immediate operand.

Example:

```assembly
addi x3, x1, 10
```

Expected decode behavior:

```text
rs1_addr_o = x1
rs2_addr_o = 0
rd_addr_o  = x3
imm_sel_o  = IMM_I
alu_op_o   = ALU_ADD
is_op_imm_o = 1
instr_valid_o = 1
```

`rs2_addr_o` is set to zero because OP-IMM instructions do not use `rs2` as an operand.

---

## 9. Load Decode

Load instructions use `rs1` as a base address register and an I-type immediate as an offset.

Example:

```assembly
lw x3, 0(x1)
```

Expected decode behavior:

```text
rs1_addr_o = x1
rs2_addr_o = 0
rd_addr_o  = x3
imm_sel_o  = IMM_I
alu_op_o   = ALU_ADD
is_load_o  = 1
instr_valid_o = 1
```

The ALU operation is `ADD` because the memory address is calculated as:

```text
address = rs1_data + immediate
```

---

## 10. Store Decode

Store instructions use `rs1` as a base address register and `rs2` as store data.

Example:

```assembly
sw x3, 8(x1)
```

Expected decode behavior:

```text
rs1_addr_o = x1
rs2_addr_o = x3
rd_addr_o  = 0
imm_sel_o  = IMM_S
alu_op_o   = ALU_ADD
is_store_o = 1
instr_valid_o = 1
```

`rd_addr_o` is set to zero because store instructions do not write back to the register file.

---

## 11. Branch Decode

Branch instructions compare two register operands and use a B-type immediate as a branch offset.

Example:

```assembly
beq x1, x2, label
```

Expected decode behavior:

```text
rs1_addr_o = x1
rs2_addr_o = x2
rd_addr_o  = 0
imm_sel_o  = IMM_B
alu_op_o   = ALU_SUB
is_branch_o = 1
instr_valid_o = 1
```

For `BEQ`, the ALU can subtract the two operands.

```text
rs1_data - rs2_data = 0
→ rs1_data == rs2_data
→ BEQ condition is true
```

Therefore, `ALU_SUB` is selected for branch comparison.

---

## 12. `IMM_NONE`

`IMM_NONE` means that the current instruction does not use an immediate operand.

It is mainly used for R-type instructions.

```systemverilog
localparam logic [IMM_SEL_WIDTH-1:0] IMM_NONE = 3'd7;
```

For example:

```assembly
add x3, x1, x2
```

This instruction uses `rs1` and `rs2`, not an immediate.

Therefore:

```text
imm_sel_o = IMM_NONE
```

In the full datapath, this means the ALU second operand should come from `rs2_data`, not from the Immediate Generator.

---

## 13. `instr_valid_o`

`instr_valid_o` indicates whether the current instruction is supported by this Decoder.

If the opcode or funct combination is not supported, `instr_valid_o` remains `0`.

This is useful because later modules such as the Control Unit can disable side effects for invalid instructions.

For example, when `instr_valid_o = 0`:

```text
reg_write_o = 0
mem_write_o = 0
branch_o    = 0
```

This prevents unsupported instructions from accidentally modifying architectural state.

---

## 14. Testbench Strategy

The Decoder testbench is a self-checking testbench.

It builds instruction patterns using helper functions and checks whether the Decoder outputs match the expected values.

Main helper functions:

| Function | Purpose |
|---|---|
| `make_r_type_instr` | Builds R-type instruction patterns |
| `make_i_type_instr` | Builds I-type instruction patterns |
| `make_s_type_instr` | Builds S-type instruction patterns |
| `make_b_type_instr` | Builds B-type instruction patterns |

The testbench checks:

- Field extraction
- Opcode decoding
- `funct3` / `funct7` decoding
- ALU operation output
- Immediate type output
- Instruction category flags
- Invalid instruction handling

---

## 15. Simulation Result

Simulation command:

```bash
make decoder
```

Expected result:

```text
PASS: 10
FAIL: 0
DECODER TEST PASSED
```

---

## 16. Study Notes

### Q1. What is the role of the Decoder?

The Decoder extracts instruction fields and performs first-level instruction decoding.

It identifies the instruction category and generates outputs such as register addresses, ALU operation, immediate type, and valid flag.

---

### Q2. Is the Decoder the same as the Control Unit?

Not exactly.

The Decoder identifies what the instruction is.

The Control Unit decides how the datapath should move data for that instruction.

In this project, the Decoder and Control Unit are separated for clarity and easier verification.

---

### Q3. Why does the Decoder generate `alu_op_o`?

The ALU needs a compact internal control signal such as `ALU_ADD` or `ALU_SUB`.

The Decoder translates instruction fields such as `opcode`, `funct3`, and `funct7` into this internal ALU operation signal.

---

### Q4. Why does the Decoder generate `imm_sel_o`?

The Immediate Generator needs to know which immediate format should be extracted.

For example:

```text
ADDI, LW → IMM_I
SW       → IMM_S
BEQ      → IMM_B
R-type   → IMM_NONE
```

---

### Q5. Why is `instr_valid_o` useful?

`instr_valid_o` prevents unsupported instructions from causing unwanted side effects.

If an instruction is invalid, later control logic can disable register writes, memory writes, and branch updates.

---

## 17. Future Improvements

Future improvements may include:

- Supporting more RV32I instructions
- Adding U-type and J-type decode
- Adding illegal instruction handling
- Adding assertions for invalid instruction behavior
- Connecting Decoder outputs to the Control Unit and single-cycle datapath