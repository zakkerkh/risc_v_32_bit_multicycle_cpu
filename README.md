# Multi-Cycle RISC-V CPU in Verilog

A 32-bit multi-cycle processor written in Verilog. It runs a subset of the RISC-V RV32I instruction set, plus `mul`. The design follows the classic multi-cycle datapath: one shared memory for instructions and data, one ALU, and a finite-state machine that drives the control signals.

## Supported instructions

| Type   | Instructions                 | Opcode    |
|--------|------------------------------|-----------|
| R-type | `add`, `sub`, `and`, `or`, `mul` | `0110011` |
| Load   | `lw`                         | `0000011` |
| Store  | `sw`                         | `0100011` |
| Branch | `beq`                        | `1100011` |

## Project structure

```
.
├── top.v             Top-level module: wires the datapath together and exposes debug outputs
├── ctrl/
│   ├── main_ctrl.v   Control unit: FSM that sets the control signals for each cycle
│   └── alu_ctrl.v    ALU control: picks the ALU operation from aluOp, funct3 and funct7
└── modules/
    ├── alu.v         32-bit ALU (ADD, SUB, AND, OR, MUL) with a zero flag
    ├── reg_file.v    32 x 32-bit register file; x0 is always 0
    ├── mem.v         Unified instruction/data memory, 1024 words, word-addressed
    ├── instr_reg.v   Instruction register; splits out opcode, rs1, rs2 and rd
    ├── imm_gen.v     Immediate generator for I-type (load), S-type and B-type
    └── pc.v          Program counter with reset and write enable
```

## How it works

Each instruction takes several clock cycles. The control FSM in `main_ctrl.v` moves through these states:

| Instruction | States                                              | Cycles |
|-------------|-----------------------------------------------------|--------|
| `lw`        | FETCH → FETCH_W → DECODE → MEM → MEM_A1 → MEM_A_W → MEM_A2 | 7 |
| `sw`        | FETCH → FETCH_W → DECODE → MEM → MEM_B              | 5      |
| R-type      | FETCH → FETCH_W → DECODE → R_1 → R_2                | 5      |
| `beq`       | FETCH → FETCH_W → DECODE → BRANCH                   | 4      |

- **FETCH / FETCH_W**: read the instruction at the PC and compute PC + 4 (parked in the ALU output register, not written yet). Memory reads are synchronous, so FETCH_W waits a cycle before loading the instruction register.
- **DECODE**: retire PC + 4 into the PC register, while the ALU simultaneously computes the branch target (PC + immediate) from the still-current PC, in case the instruction turns out to be a branch. Computing PC + 4 in FETCH but writing it in DECODE keeps the branch target relative to the branch instruction's own address, per RV32I.
- **MEM**: compute the memory address, `rs1 + immediate`.
- **MEM_A1 / MEM_A_W / MEM_A2**: read memory, wait for the data, then write it to `rd`.
- **MEM_B**: write `rs2` to memory.
- **R_1 / R_2**: run the ALU on `rs1` and `rs2`, then write the result to `rd`.
- **BRANCH**: subtract `rs2` from `rs1` and take the branch if the result is zero.

## Debug outputs

`top.v` exposes these signals so you can watch the CPU in simulation or on hardware:

| Signal               | Meaning                          |
|----------------------|----------------------------------|
| `pc_debug`           | Current program counter          |
| `alu_out_debug`      | ALU output                       |
| `reg_file_A_debug`   | Register file read port A        |
| `mem_data_out_debug` | Memory read data                 |
| `regWrite_debug`     | High when a register is written  |

## Simulating

The repo doesn't include a testbench yet. To run a program:

1. Load machine code into memory. For example, add this to `mem.v`, where `program.hex` holds one 32-bit instruction per line in hex:
   ```verilog
   initial $readmemh("program.hex", memory);
   ```
2. Write a testbench that drives `clk` and holds `reset` high for at least one clock edge. The control FSM has no defined state until it is reset.
3. Compile and run with a simulator such as [Icarus Verilog](https://steveicarus.github.io/iverilog/):
   ```sh
   iverilog -o cpu_sim top.v modules/*.v ctrl/*.v your_testbench.v
   vvp cpu_sim
   ```

## Limitations

- Only the instructions listed above are supported. Other opcodes send the FSM back to FETCH.
- Instructions and data share one 4 KB memory.
- Only word accesses; no byte or halfword loads and stores.
- `reg_file`, `instr_reg` and `mem` have no reset; their contents are undefined (X) until written. Only `x0` and the control FSM state are guaranteed defined after reset.
