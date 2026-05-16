# PC Module

#rtl #systemverilog #riscv #fetch #programcounter

## 1. Purpose

#### Program Counter

`A sequential logic block that stores the address of the current instruction`

The Program Counter, or PC, holds the address of the instruction currently being fetched.

In the RV32I single-cycle CPU datapath, the PC provides the read address for the Instruction Memory. Under normal sequential execution, the PC is updated by adding 4 because each base RV32I instruction is 32 bits, or 4 bytes.

```text
PC = 0  → fetch instruction 0
PC = 4  → fetch instruction 1
PC = 8  → fetch instruction 2
```

This module stores the current PC value and updates it to `next_pc_i` on the rising edge of the clock when `pc_en_i` is asserted.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/pc.sv` | Program Counter RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Common parameters such as `XLEN` |
| `tb/unit/tb_fetch.sv` | Fetch stage self-checking testbench |
| `scripts/run_fetch_tb.sh` | Fetch stage simulation script |

---

## 3. Interface

```systemverilog
module pc
    import rv32i_pkg::*;
(
    input  logic              clk_i,
    input  logic              rst_ni,
    input  logic              pc_en_i,

    input  logic [XLEN-1:0]   next_pc_i,
    output logic [XLEN-1:0]   pc_o
);
```

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `clk_i` | 1-bit | Clock input |
| `rst_ni` | 1-bit | Active-low reset input |
| `pc_en_i` | 1-bit | PC update enable |
| `next_pc_i` | `XLEN` | Next PC value |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `pc_o` | `XLEN` | Current PC value |

---

## 4. RTL Implementation Notes

The PC is implemented as sequential logic using `always_ff`.

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        pc_o <= '0;
    end else begin
        if (pc_en_i) begin
            pc_o <= next_pc_i;
        end
    end
end
```

The PC stores state, so it must be updated on a clock edge.

Behavior:

```text
rst_ni = 0 → pc_o is reset to 0
pc_en_i = 1 → pc_o is updated to next_pc_i
pc_en_i = 0 → pc_o keeps its previous value
```

---

## 5. Why `pc_en_i` is Used

In a simple single-cycle CPU, the PC can be updated every cycle.

However, `pc_en_i` is included to make the design easier to extend later.

In a pipelined CPU, the PC may need to stop updating when a stall occurs.

Example:

```text
pc_en_i = 1 → normal PC update
pc_en_i = 0 → PC is held during stall
```

This makes the PC module reusable for both single-cycle and future pipelined designs.

---

## 6. PC + 4

For normal sequential instruction execution:

```text
next_pc = pc + 4
```

The reason is that RV32I base instructions are 32 bits wide.

```text
32 bits = 4 bytes
```

Therefore, the next sequential instruction is located at the current PC address plus 4.

---

## 7. Testbench Strategy

The PC is tested as part of the Fetch stage testbench.

The testbench verifies:

- Reset behavior
- Initial PC value
- PC update by 4
- Instruction fetch at PC values `0`, `4`, `8`, and `12`

The PC is connected with the Instruction Memory to verify the complete fetch path:

```text
PC → Instruction Memory → instruction
```

---

## 8. Simulation Result

Simulation command:

```bash
make fetch
```

Expected result:

```text
PASS: 5
FAIL: 0
FETCH STAGE TEST PASSED
```

---

## 9. Study Notes

### Q1. What is the role of the PC?

The PC stores the address of the current instruction.

It provides the instruction address to the Instruction Memory.

---

### Q2. Why does the PC usually increase by 4?

RV32I base instructions are 32 bits, or 4 bytes.

Therefore, the next sequential instruction is located at:

```text
PC + 4
```

---

### Q3. Why is the PC implemented with `always_ff`?

The PC stores state.

Since state should be updated at a clock edge, the PC is implemented using sequential logic with `always_ff`.

---

### Q4. Why is `pc_en_i` included?

`pc_en_i` allows the PC update to be stalled.

This is useful for future pipelined CPU design, where hazards may require the fetch stage to stop temporarily.

---

## 10. Future Improvements

Future improvements may include:

- Branch target PC update
- Jump target PC update
- Pipeline stall support
- Flush support for branch misprediction or control hazard handling