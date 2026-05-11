# Immediate Generator Module

#rtl #systemverilog #riscv #datapath #immediate

## 1. Purpose

#### Immediate Generator

`A combinational logic block that extracts and sign-extends immediate values from a 32-bit RISC-V instruction`

The Immediate Generator extracts immediate fields from a 32-bit RISC-V instruction and generates an `XLEN`-bit sign-extended immediate value.

In the RV32I single-cycle CPU datapath, the immediate value is used by instructions such as:

- `ADDI`
- `LW`
- `SW`
- `BEQ`

The immediate generator allows the CPU to use constants or offsets encoded inside the instruction.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/imm_gen.sv` | Immediate Generator RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Common parameters and immediate type encodings |
| `tb/unit/tb_imm_gen.sv` | Self-checking Immediate Generator testbench |
| `scripts/run_imm_gen_tb.sh` | Immediate Generator simulation script |
| `sim/log/tb_imm_gen.log` | Immediate Generator simulation log |
| `sim/wave/tb_imm_gen.vcd` | Immediate Generator waveform dump |

---

## 3. Interface

```systemverilog
module imm_gen
    import rv32i_pkg::*;
(
    input  logic [INST_WIDTH-1:0]    instr_i,
    input  logic [IMM_SEL_WIDTH-1:0] imm_sel_i,

    output logic [XLEN-1:0]          imm_o
);
```

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `instr_i` | `INST_WIDTH` | 32-bit RISC-V instruction input |
| `imm_sel_i` | `IMM_SEL_WIDTH` | Immediate type select signal |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `imm_o` | `XLEN` | Sign-extended immediate output |

---

## 4. Key Parameters

The Immediate Generator uses the following parameters defined in `rv32i_pkg.sv`.

```systemverilog
parameter int XLEN = 32;
parameter int INST_WIDTH = 32;
parameter int IMM_SEL_WIDTH = 3;
```

### `INST_WIDTH`

`INST_WIDTH` represents the width of a base RISC-V instruction.

For RV32I, a base instruction is 32-bit wide.

```text
INST_WIDTH = 32
```

The input instruction is therefore declared as:

```systemverilog
input logic [INST_WIDTH-1:0] instr_i
```

### `XLEN`

`XLEN` represents the integer register and datapath width.

For RV32I:

```text
XLEN = 32
```

The immediate output is sign-extended to `XLEN` because it will be used as an ALU operand or branch offset in the datapath.

### `IMM_SEL_WIDTH`

`IMM_SEL_WIDTH` is the width of the immediate type select signal.

Current immediate type encodings:

```systemverilog
localparam logic [IMM_SEL_WIDTH-1:0] IMM_I = 3'd0;
localparam logic [IMM_SEL_WIDTH-1:0] IMM_S = 3'd1;
localparam logic [IMM_SEL_WIDTH-1:0] IMM_B = 3'd2;
```

---

## 5. Supported Immediate Types

The current Immediate Generator supports:

| Type | Used By | Description |
|---|---|---|
| I-type | `ADDI`, `LW` | Immediate is stored in `instr[31:20]` |
| S-type | `SW` | Immediate is split between `instr[31:25]` and `instr[11:7]` |
| B-type | `BEQ` | Branch immediate, also called SB-type in Patterson & Hennessy |

---

## 6. I-type Immediate

I-type immediate is used by instructions such as `ADDI` and `LW`.

The immediate field is located at:

```text
instr[31:20]
```

RTL implementation:

```systemverilog
IMM_I: begin
    imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:20]};
end
```

The immediate is 12-bit wide and is sign-extended to `XLEN`.

If `instr_i[31]` is `1`, the immediate is treated as a negative value.

Example:

```text
12'hFFF → -1
sign-extended to 32-bit → 32'hFFFF_FFFF
```

---

## 7. S-type Immediate

S-type immediate is used by store instructions such as `SW`.

Unlike I-type immediate, the immediate field is split into two parts.

```text
imm[11:5] = instr[31:25]
imm[4:0]  = instr[11:7]
```

RTL implementation:

```systemverilog
IMM_S: begin
    imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
end
```

This reconstructs the 12-bit store offset and sign-extends it to `XLEN`.

---

## 8. B-type Immediate and SB-type Encoding

B-type immediate is used by branch instructions such as `BEQ`.

In Patterson & Hennessy, this format is often called `SB-type`.

In this project, the signal name `IMM_B` is used because `B-type` is a common naming convention in RISC-V RTL code.

The B-type immediate is arranged as follows.

```text
imm[12]   = instr[31]
imm[11]   = instr[7]
imm[10:5] = instr[30:25]
imm[4:1]  = instr[11:8]
imm[0]    = 1'b0
```

RTL implementation:

```systemverilog
IMM_B: begin
    imm_o = {{(XLEN-13){instr_i[31]}}, instr_i[31], instr_i[7],
             instr_i[30:25], instr_i[11:8], 1'b0};
end
```

The least significant bit `imm[0]` is always `0` because branch targets are aligned.

This means the branch offset is effectively shifted left by 1 bit.

---

## 9. Why B-type Uses an SB-like Encoding

B-type immediate may look unusual because the immediate bits are not stored in simple consecutive order.

However, this encoding is strategic.

The B-type branch immediate is designed to share a similar field layout with the S-type immediate.

Compare S-type and B-type:

### S-type

```text
imm[11:5] = instr[31:25]
imm[4:0]  = instr[11:7]
```

### B-type / SB-type

```text
imm[12]   = instr[31]
imm[10:5] = instr[30:25]
imm[4:1]  = instr[11:8]
imm[11]   = instr[7]
imm[0]    = 1'b0
```

### compare Type-S and Type-B

| instruction bit | Type-S | Type-B|
|---|---|---|
|inst[31]|imm[11]|imm[12]|
|inst[30:25]|imm[10:5]|imm[10:5]|
|inst[11:8]|imm[4:1]|imm[4:1]|
|inst[7]|imm[0]|imm[11]|

The important overlap is:

```text
instr[30:25] and instr[11:8]
```

These bit ranges are used in similar positions for both S-type and B-type immediate generation.

This helps reduce immediate-generation hardware complexity.

Instead of using a general-purpose shifter to shift a full immediate value left by 1, the instruction encoding already places the branch immediate bits close to their final positions.

The Immediate Generator only needs to concatenate selected instruction bits and append `1'b0` as the least significant bit.

Conceptually:

```text
No full dynamic shifter is needed.
Only wiring, concatenation, sign-extension, and small muxing are needed.
```

This can reduce hardware area and mux complexity in the decode/immediate generation path.

In other words, the SB-style encoding is not just a software convention.  
It is also helpful for hardware implementation because it allows branch immediate generation to reuse much of the S-type immediate wiring structure.

---

## 10. Sign Extension

Sign extension is required because immediate values can represent negative offsets or constants.

For example:

```text
12'hFFF = -1 in 12-bit signed representation
```

When sign-extended to 32-bit:

```text
32'hFFFF_FFFF
```

SystemVerilog sign extension is implemented using replication and concatenation.

Example:

```systemverilog
{{(XLEN-12){instr_i[31]}}, instr_i[31:20]}
```

This means:

```text
Repeat instr_i[31] for XLEN-12 bits
Then append the 12-bit immediate field
```

For RV32I:

```text
XLEN = 32
XLEN - 12 = 20
```

So the sign bit is repeated 20 times.

---

## 11. RTL Implementation Notes

The Immediate Generator is implemented as combinational logic.

```systemverilog
always_comb begin
    imm_o = '0;

    case (imm_sel_i)
        IMM_I: begin
            imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:20]};
        end

        IMM_S: begin
            imm_o = {{(XLEN-12){instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
        end

        IMM_B: begin
            imm_o = {{(XLEN-13){instr_i[31]}}, instr_i[31], instr_i[7],
                     instr_i[30:25], instr_i[11:8], 1'b0};
        end

        default: begin
            imm_o = '0;
        end
    endcase
end
```

The module uses `always_comb` because it does not store state.

The output immediate depends only on:

```text
instr_i
imm_sel_i
```

There is no clock input and no internal register.

---

## 12. Testbench Strategy

The Immediate Generator testbench is a self-checking testbench.

It verifies both positive and negative immediate values.

Tested cases:

- I-type positive immediate
- I-type negative immediate
- S-type positive immediate
- S-type negative immediate
- B-type positive immediate
- B-type negative immediate

The testbench uses helper functions to build instruction patterns.

Example:

```systemverilog
function automatic logic [31:0] make_i_type_instr(
    input logic [11:0] imm12
);
```

These helper functions make the testbench easier to read because the test can focus on immediate values instead of manually writing full 32-bit instructions.

---

## 13. Simulation Result

Simulation command:

```bash
make imm_gen
```

Expected result:

```text
PASS: 6
FAIL: 0
IMMEDIATE GENERATOR TEST PASSED
```

This confirms that the Immediate Generator correctly extracts and sign-extends I-type, S-type, and B-type immediate values.

---

## 14. Study Notes

### Q1. Why is the Immediate Generator needed?

RISC-V instructions store immediate values inside the instruction encoding.

However, these immediate fields are not always located in the same bit positions.

The Immediate Generator extracts the proper bits and sign-extends them to `XLEN` so they can be used in the datapath.

---

### Q2. Why is the Immediate Generator combinational logic?

The Immediate Generator does not store state.

Its output depends only on the current instruction and immediate select signal.

Therefore, it is implemented using `always_comb`.

---

### Q3. Why does the output use `XLEN` width?

The immediate output will be used as an ALU operand or branch offset.

Since the datapath and registers are `XLEN` wide, the immediate must also be extended to `XLEN`.

For RV32I, this means the immediate output is 32-bit wide.

---

### Q4. Why is sign extension needed?

Immediate values can be negative.

For example, branch offsets and store offsets may be negative.

Sign extension preserves the signed value when expanding the immediate from a smaller bit width to `XLEN`.

Without sign extension, negative immediates would be interpreted incorrectly.

---

### Q5. Why does B-type immediate have `1'b0` as the LSB?

Branch targets are aligned, so the least significant bit of the branch offset is always zero.

Therefore, B-type immediate generation appends `1'b0` as bit 0.

This effectively represents a branch offset shifted left by 1 bit.

---

### Q6. How does SB-type encoding help reduce hardware complexity?

SB-type encoding arranges branch immediate bits so that many bit positions overlap with S-type immediate wiring.

This reduces the need for additional shifting hardware.

Instead of generating an immediate and then passing it through a general shifter, the immediate bits are already placed close to their final output positions.

The hardware mainly performs:

```text
bit selection
concatenation
sign extension
small muxing
```

This can reduce area and simplify the immediate generation logic.

---

## 15. Future Improvements

Future immediate types to add:

- U-type
- J-type

These will be needed for instructions such as:

- `LUI`
- `AUIPC`
- `JAL`

The Immediate Generator will later be connected to:

- Decoder
- Control unit
- ALU operand mux
- Branch target calculation path