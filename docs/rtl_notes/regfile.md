# Register File Module

#rtl #systemverilog #riscv #datapath

## 1. Purpose

#### Register File

`A storage block that provides source operands and stores writeback results in the RV32I CPU core`

The register file stores the integer registers used by the CPU. In the RV32I datapath, instructions read source operands from the register file and write operation results back to it.

This module provides two read ports and one write port, which are required for typical RISC-V instructions that read `rs1` and `rs2` and write the result to `rd`.

---

## 2. Related Files

| File | Description |
|---|---|
| `rtl/core/regfile.sv` | Register file RTL implementation |
| `rtl/common/rv32i_pkg.sv` | Common parameters such as `XLEN`, `REG_COUNT`, and `REG_ADDR_WIDTH` |
| `tb/unit/tb_regfile.sv` | Self-checking register file testbench |
| `scripts/run_regfile_tb.sh` | Register file simulation script |
| `sim/log/tb_regfile.log` | Register file simulation log |
| `sim/wave/tb_regfile.vcd` | Register file waveform dump |

---

## 3. RISC-V Register File Overview

RV32I has 32 integer registers.

```text
x0 ~ x31
```

Each register is 32-bit wide.

Because there are 32 registers, the register address width is 5 bits.

```text
2^5 = 32
```

Therefore, the register file uses the following parameters:

```systemverilog
parameter int REG_COUNT = 32;
parameter int REG_ADDR_WIDTH = 5;
parameter int XLEN = 32;
```

The instruction fields related to the register file are:

| Field | Meaning |
|---|---|
| `rs1` | Source register 1 |
| `rs2` | Source register 2 |
| `rd` | Destination register |

---

## 4. Interface

```systemverilog
module regfile
    import rv32i_pkg::*;
(
    input  logic                         clk_i,
    input  logic                         rst_ni,

    input  logic                         we_i,
    input  logic [REG_ADDR_WIDTH-1:0]    waddr_i,
    input  logic [XLEN-1:0]              wdata_i,

    input  logic [REG_ADDR_WIDTH-1:0]    raddr1_i,
    input  logic [REG_ADDR_WIDTH-1:0]    raddr2_i,

    output logic [XLEN-1:0]              rdata1_o,
    output logic [XLEN-1:0]              rdata2_o
);
```

### Input Ports

| Signal | Width | Description |
|---|---:|---|
| `clk_i` | 1-bit | Clock input |
| `rst_ni` | 1-bit | Active-low reset input |
| `we_i` | 1-bit | Write enable |
| `waddr_i` | `REG_ADDR_WIDTH` | Write address |
| `wdata_i` | `XLEN` | Write data |
| `raddr1_i` | `REG_ADDR_WIDTH` | Read address 1 |
| `raddr2_i` | `REG_ADDR_WIDTH` | Read address 2 |

### Output Ports

| Signal | Width | Description |
|---|---:|---|
| `rdata1_o` | `XLEN` | Read data from port 1 |
| `rdata2_o` | `XLEN` | Read data from port 2 |

---

## 5. RTL Implementation Notes

The internal register array is declared as:

```systemverilog
logic [XLEN-1:0] rf [0:REG_COUNT-1];
```

This represents:

```text
32 registers × 32-bit data width
```

The register file uses:

- Synchronous write
- Combinational read
- Active-low reset
- Hardwired-zero behavior for `x0`

---

## 6. Synchronous Write

The write operation is performed on the rising edge of the clock.

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        for (i = 0; i < REG_COUNT; i = i + 1) begin
            rf[i] <= '0;
        end
    end else begin
        if (we_i && (waddr_i != '0)) begin
            rf[waddr_i] <= wdata_i;
        end
    end
end
```

A write occurs only when:

```text
we_i = 1
waddr_i != 0
```

The condition `waddr_i != '0` prevents writes to register `x0`.

---

## 7. Combinational Read

The read ports are implemented using continuous assignment.

```systemverilog
assign rdata1_o = (raddr1_i == '0) ? '0 : rf[raddr1_i];
assign rdata2_o = (raddr2_i == '0) ? '0 : rf[raddr2_i];
```

This means the read data changes when the read address changes, without waiting for a clock edge.

This behavior is useful in a single-cycle CPU because register operands need to be available during the same cycle.

---

## 8. x0 Hardwired-Zero Handling

In RISC-V, register `x0` must always read as zero.

This design handles `x0` in two ways.

First, writes to `x0` are ignored.

```systemverilog
if (we_i && (waddr_i != '0)) begin
    rf[waddr_i] <= wdata_i;
end
```

Second, reads from `x0` always return zero.

```systemverilog
assign rdata1_o = (raddr1_i == '0) ? '0 : rf[raddr1_i];
assign rdata2_o = (raddr2_i == '0) ? '0 : rf[raddr2_i];
```

This guarantees that `x0` behaves as a hardwired-zero register.

---

## 9. Testbench Strategy

The register file testbench is a self-checking testbench.

It verifies the following behaviors:

- Reset behavior
- Normal write and read
- Two read ports
- Write-disabled behavior
- Overwrite behavior
- Writes to `x0` are ignored
- Reads from `x0` always return zero

The testbench automatically prints `[PASS]` or `[FAIL]` by comparing actual outputs with expected values.

---

## 10. Simulation Result

Simulation command:

```bash
make regfile
```

Expected result:

```text
PASS: 6
FAIL: 0
REGISTER FILE TEST PASSED
```

This confirms that the register file correctly supports basic RV32I register read/write behavior.

---

## 11. Study Notes

### Q1. Why is the register address width 5 bits?

RV32I has 32 integer registers.

To select one register out of 32, 5 bits are required.

```text
2^5 = 32
```

Therefore, `rs1`, `rs2`, and `rd` are 5-bit register address fields.

---

### Q2. Why does the register file have two read ports and one write port?

Many RISC-V instructions use two source operands and one destination register.

For example:

```assembly
add x3, x1, x2
```

This instruction reads `x1` and `x2`, then writes the result to `x3`.

Therefore, the register file needs:

```text
2 read ports → rs1, rs2
1 write port → rd
```

---

### Q3. Why is write synchronous?

The register file stores architectural state.

State updates should occur at a well-defined clock edge, so the write operation is implemented with `always_ff`.

This makes the register update timing clear and avoids unintended combinational feedback.

---

### Q4. Why is read combinational?

In this simple single-cycle CPU design, the register operands need to be available in the same cycle after the instruction is decoded.

Therefore, read data is generated directly from the read address without waiting for a clock edge.

---
### Q3, Q4 Conclusion
The register file uses synchronous write and combinational read.

This structure is widely used in simple CPU datapaths because it provides both stable state updates and fast operand access.

The write operation is synchronized to the clock edge, which helps maintain consistent architectural state. On the other hand, the read operation is combinational, so the source operand values can be available immediately after the read addresses change.

In this project, this structure is suitable for the RV32I single-cycle CPU datapath because the CPU needs to read `rs1` and `rs2` operands and use them in the ALU within the same instruction cycle.

#### Summary Comprasion
|Feature |Write Operation|Read Operation|
|---|---|---|
|Logic Type|Synchronous (always_ff)|Combinational (assign)|
|Trigger|Clock Edge (Rising Edge)|Address Change (Immediate)|
|Primary Goal|Data Stability & Consistency|High-Speed Data Throughput|
|Hardware|D Flip-Flops|Multiplexers (MUX)|
---

### Q5. How is `x0` implemented?

`x0` is protected in two ways.

Writes to `x0` are ignored by checking:

```systemverilog
waddr_i != '0
```

Reads from `x0` always return zero using a conditional assignment.

This ensures that `x0` always behaves as a hardwired-zero register.

---

### Q6. Is resetting all registers always necessary?

Not always.

In this project, all registers are reset to zero to make simulation and debugging easier.

However, in a real hardware design, resetting every register file entry may increase area and reset routing complexity.

So the reset strategy should depend on the design requirements.

---

## 12. Future Improvements

Future improvements may include:

- Testing same-cycle read-after-write behavior
- Adding assertions for `x0`
- Removing full reset for a more realistic implementation
- Connecting the register file to the decoder and ALU in the single-cycle datapath