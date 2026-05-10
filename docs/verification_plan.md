# Verification Plan

## 1. Verification Strategy

This project uses step-by-step verification.

1. Unit-level verification
2. Core-level directed test
3. Self-checking testbench
4. Golden model comparison
5. Waveform-based debug

## 2. Unit Test Targets

| Module | Test Items |
|---|---|
| ALU | ADD, SUB, AND, OR, XOR |
| Register File | read, write, x0 hardwired zero |
| Immediate Generator | I-type, S-type, B-type immediate |
| Decoder | opcode, funct3, funct7 decode |
| Control Unit | control signal generation |

## 3. Initial Pass Criteria

- ALU produces expected output for each operation.
- Register file writes and reads correctly.
- Register x0 always remains zero.
- Testbench prints PASS or FAIL automatically.