# RV32I Instruction Subset

## Phase 1 Instruction Subset

|   Type   |       Instructions        |           Purpose         |
|---|---|---|
|  R-type  |   ADD, SUB, AND, OR, XOR  |       ALU operation       |
|  I-type  |           ADDI            |    Immediate operation    |
|  Load    |            LW             |        Memory read        |
|  Store   |            SW             |        Memory write       |
|  Branch  |            BEQ            |        PC control         |

## Phase 2 Extension

| Type | Instructions |
|---|---|
| R-type | SLL, SRL, SRA, SLT, SLTU |
| I-type | ANDI, ORI, XORI, SLTI, SLTIU |
| Branch | BNE, BLT, BGE, BLTU, BGEU |
| Jump | JAL, JALR |
| Upper Immediate | LUI, AUIPC |

## Notes

The initial goal is not full ISA coverage.
The priority is correct datapath, control path, synthesizable RTL, and verification.