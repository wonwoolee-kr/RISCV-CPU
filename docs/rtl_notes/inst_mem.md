# Instruction Memory Module

#rtl #systemverilog #riscv #fetch #memory

## 1. Purpose

#### Instruction Memory

`A read-only memory block that provides instructions based on the current PC address`

The Instruction Memory stores program instructions and outputs the instruction located at the current PC address.

In the RV32I single-cycle CPU datapath, the PC provides the address, and the Instruction Memory returns a 32-bit instruction.

```text
PC → Instruction Memory → instr
```

For this educational CPU project, the Instruction Memory is modeled as a simple word-addressed memory array initialized from a hex file.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/instr_mem.sv` | Instruction Memory RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Common parameters such as `XLEN` and `INST_WIDTH` |
| `sim/hex/fetch_test.hex` | Test program loaded into Instruction Memory |
| `tb/unit/tb_fetch.sv` | Fetch stage self-checking testbench |
| `scripts/run_fetch_tb.sh` | Fetch stage simulation script |

---

## 3. Interface

```systemverilog
module instr_mem
    import rv32i_pkg::*;
#(
    parameter int    IMEM_DEPTH = 256,
    parameter string HEX_FILE   = ""
)
(
    input  logic [XLEN-1:0]       addr_i,
    output logic [INST_WIDTH-1:0] instr_o
);
```

### Parameters

| Parameter | Description |
|---|---|
| `IMEM_DEPTH` | Number of instruction words |
| `HEX_FILE` | Hex file used to initialize instruction memory |

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `addr_i` | `XLEN` | Byte address from PC |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `instr_o` | `INST_WIDTH` | 32-bit instruction output |

---

## 4. Memory Organization

The Instruction Memory is declared as a word array.

```systemverilog
logic [INST_WIDTH-1:0] mem [0:IMEM_DEPTH-1];
```

This means:

```text
IMEM_DEPTH entries × INST_WIDTH bits
```

For example, if `IMEM_DEPTH = 256` and `INST_WIDTH = 32`:

```text
256 instruction words × 32 bits
```

---

## 5. Byte Address vs Word Address

The PC is a byte address.

However, the Instruction Memory array is indexed by instruction word.

RV32I base instructions are 4 bytes wide, so the PC normally increases by 4.

```text
PC = 0  → mem[0]
PC = 4  → mem[1]
PC = 8  → mem[2]
PC = 12 → mem[3]
```

Therefore, the lower two address bits are ignored when generating the word address.

```systemverilog
assign word_addr = addr_i[IMEM_ADDR_WIDTH+1:2];
```

This effectively divides the byte address by 4.

---

## 6. Hex File Initialization

The memory is initialized using `$readmemh`.

```systemverilog
initial begin
    for (i = 0; i < IMEM_DEPTH; i = i + 1) begin
        mem[i] = '0;
    end

    if (HEX_FILE != "") begin
        $readmemh(HEX_FILE, mem);
    end
end
```

The memory is first cleared to zero.

Then, if `HEX_FILE` is not empty, the memory contents are loaded from the hex file.

Example hex file:

```text
00500093  // addi x1, x0, 5
00700113  // addi x2, x0, 7
002081b3  // add  x3, x1, x2
00000013  // addi x0, x0, 0  // nop
```

The comments are ignored by `$readmemh`.

---

## 7. RTL Implementation Notes

Instruction Memory is modeled as combinational read memory.

```systemverilog
assign instr_o = mem[word_addr];
```

When `addr_i` changes, `word_addr` changes, and the corresponding instruction is output.

This simple model is useful for an educational single-cycle CPU.

In a real processor, instruction fetch may involve SRAM, cache, bus interfaces, and wait states.  
For this project stage, a simple memory array is enough to verify the fetch path.

---

## 8. Test Program

The current fetch test program is:

```assembly
addi x1, x0, 5
addi x2, x0, 7
add  x3, x1, x2
addi x0, x0, 0
```

The corresponding hex file is:

```text
00500093
00700113
002081b3
00000013
```

The last instruction is a NOP.

```assembly
addi x0, x0, 0
```

Because register `x0` is always zero, writing zero to `x0` has no architectural effect.

---

## 9. Testbench Strategy

The Fetch stage testbench connects:

```text
PC
Instruction Memory
PC + 4 logic
```

The testbench verifies that the PC fetches the correct instruction at each address.

Expected sequence:

| PC | Expected Instruction |
|---:|---|
| `0x00000000` | `0x00500093` |
| `0x00000004` | `0x00700113` |
| `0x00000008` | `0x002081b3` |
| `0x0000000c` | `0x00000013` |

---

## 10. Simulation Result

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

## 11. Study Notes

### Q1. What is the role of Instruction Memory?

Instruction Memory stores program instructions and outputs the instruction at the address provided by the PC.

---

### Q2. Why is `addr_i[IMEM_ADDR_WIDTH+1:2]` used?

The PC is a byte address, but the memory array is word-addressed.

Since each instruction is 4 bytes, the lower two bits are ignored.

This converts the byte address into an instruction word index.

---

### Q3. Why is `$readmemh` used?

`$readmemh` loads memory contents from a hex file during simulation.

This makes it easy to test instruction fetch using a small program.

---

### Q4. Is this Instruction Memory synthesizable?

The simple memory array and combinational read structure can represent synthesizable memory-like behavior depending on the target tool and FPGA/ASIC flow.

However, `$readmemh` and the `HEX_FILE` string parameter are mainly for simulation and FPGA-style initialization.

For ASIC-style design, memory initialization and memory macros are usually handled differently.

---

## 12. Future Improvements

Future improvements may include:

- Supporting larger instruction memory
- Adding instruction memory bounds checking in simulation
- Connecting Instruction Memory to the full single-cycle core
- Replacing simple memory model with bus or SRAM interface later