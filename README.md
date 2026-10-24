# RV32I RISC-V Processor

A Verilog RTL implementation of a basic **32-bit RISC-V processor based on the RV32I instruction set architecture (ISA)**. The project covers the design and integration of the processor datapath, control unit, ALU, instruction/data memories, immediate generation, and verification using simulation.

## Project Overview

This project implements a simplified RV32I processor using synthesizable Verilog/SystemVerilog RTL.

The processor follows the basic instruction execution flow:

```text
        ┌─────────────┐
        │ Program     │
        │ Counter     │
        └──────┬──────┘
               │
               ▼
        ┌─────────────┐
        │ Instruction │
        │   Memory    │
        └──────┬──────┘
               │
               ▼
        ┌─────────────┐
        │ Instruction │
        │   Decode    │
        └──────┬──────┘
               │
       ┌───────┴────────┐
       ▼                ▼
 ┌───────────┐    ┌─────────────┐
 │ Register  │    │ Immediate   │
 │   File    │    │ Generator   │
 └─────┬─────┘    └──────┬──────┘
       │                 │
       └────────┬────────┘
                ▼
         ┌────────────┐
         │    ALU     │
         └─────┬──────┘
               │
        ┌──────┴───────┐
        ▼              ▼
   ┌─────────┐   ┌─────────────┐
   │   Data  │   │ Write Back  │
   │  Memory  │   │ / Register  │
   └─────────┘   │    File     │
                 └─────────────┘
```

## Features

* 32-bit RISC-V architecture
* RV32I instruction set
* Verilog RTL implementation
* Program Counter (PC)
* Instruction Memory
* Register File
* Immediate Generator
* ALU
* ALU Decoder
* Control Unit
* Data Memory
* Multiplexers for datapath selection
* Core-level integration
* System-level integration
* `$readmemh` support for loading programs
* Simulation and functional verification
* GTKWave waveform analysis
* Automated register/output checks in testbenches

## Project Structure

```text
RV32I/
│
├── pc/
│   └── pc_reg.v
│
├── imem/
│   ├── imem.v
│   └── program.hex
│
├── dmem/
│   └── dmem.v
│
├── mux/
│   └── mux.v
│
├── alu/
│   └── alu.v
│
├── alu_decoder/
│   └── alu_decoder.v
│
├── imm_gen/
│   └── imm_gen.v
│
├── control_unit/
│   └── control_unit.v
│
├── rv32i_core/
│   └── rv32i_core.v
│
├── rv32i_top/
│   └── rv32i_top.v
│
├── programs/
│   ├── arith.hex
│   ├── array_sum.hex
│   ├── gcd.hex
│   ├── fibonacci.hex
│   └── memcpy.hex
│
├── testbench/
│   └── tb_rv32i.v
│
└── README.md
```

> The exact folder names may vary depending on the final project organization.

## Main Modules

### 1. Program Counter

The PC stores the address of the current instruction.

For normal sequential execution:

```text
PC_next = PC + 4
```

For control-flow instructions, the PC can instead be updated with a branch or jump target.

---

### 2. Instruction Memory

Instruction memory stores the program instructions.

Since RV32I instructions are 32 bits and memory is byte-addressed, the word index is obtained using:

```verilog
mem[addr[31:2]]
```

The lower two address bits are ignored because each instruction occupies 4 bytes.

Example:

```text
Byte Address     Word Index
0x00000000  →       0
0x00000004  →       1
0x00000008  →       2
0x0000000C  →       3
```

Programs can be loaded using:

```verilog
$readmemh("program.hex", mem);
```

---

### 3. Register File

RV32I contains:

* 32 general-purpose registers
* Each register is 32 bits wide
* `x0` is hardwired to zero

Important registers include:

```text
x0  = zero
x1  = ra
x2  = sp
...
x31
```

The register file provides source operands to the ALU and receives results during write-back.

---

### 4. Immediate Generator

The immediate generator extracts and sign-extends immediate values according to the instruction format.

Supported formats include:

```text
I-type
S-type
B-type
U-type
J-type
```

Examples of instructions using immediates:

```text
ADDI
LW
SW
BEQ
JAL
LUI
AUIPC
```

---

### 5. ALU

The Arithmetic Logic Unit performs operations required by the processor.

Typical operations include:

```text
ADD
SUB
AND
OR
XOR
SLT
SLTU
SLL
SRL
SRA
```

The ALU receives its operation control from the ALU decoder.

---

### 6. ALU Decoder

The ALU decoder determines the required ALU operation based on fields such as:

```text
opcode
funct3
funct7
ALUOp
```

For example:

```text
ADD  → ALU performs addition
SUB  → ALU performs subtraction
AND  → ALU performs bitwise AND
OR   → ALU performs bitwise OR
```

---

### 7. Control Unit

The control unit generates the control signals required to control the datapath.

Typical signals include:

```text
RegWrite
MemRead
MemWrite
MemToReg
ALUSrc
Branch
Jump
ALUOp
```

The control unit uses the instruction opcode to determine how the instruction should be executed.

---

### 8. Data Memory

Data memory is used by load and store instructions.

Examples:

```text
LW
SW
```

For a store:

```text
Register → ALU → Data Memory
```

For a load:

```text
Data Memory → Write Back → Register
```

---

## Processor Datapath

The integrated processor connects the individual modules into a complete datapath.

The general execution sequence is:

```text
Fetch
  ↓
Decode
  ↓
Register Read
  ↓
Execute
  ↓
Memory Access
  ↓
Write Back
```

The core integrates these components:

```text
PC
 │
 ▼
Instruction Memory
 │
 ▼
Control Unit ───────┐
 │                  │
 ▼                  ▼
Register File    Immediate Generator
 │                  │
 └────────┬─────────┘
          ▼
         ALU
          │
     ┌────┴────┐
     ▼         ▼
 Data Memory   Branch/Jump Logic
     │
     ▼
 Write Back
     │
     ▼
Register File
```

## Instruction Support

The project is based on the **RV32I base integer ISA**.

The implementation is intended to support the major RV32I instruction categories:

### Register-Immediate

```text
ADDI
SLTI
SLTIU
XORI
ORI
ANDI
SLLI
SRLI
SRAI
```

### Register-Register

```text
ADD
SUB
SLL
SLT
SLTU
XOR
SRL
SRA
OR
AND
```

### Load / Store

```text
LW
SW
```

### Branch

```text
BEQ
BNE
BLT
BGE
BLTU
BGEU
```

### Jump

```text
JAL
JALR
```

### Upper Immediate

```text
LUI
AUIPC
```

## Simulation

The design can be simulated using **Icarus Verilog**.

Example compilation:

```bash
iverilog -g2012 \
  -Ialu \
  -Ialu_decoder \
  -Icontrol_unit \
  -Iimm_gen \
  -o rv32i_sim \
  rv32i_top.v \
  rv32i_core.v \
  ...
```

Run the simulation:

```bash
vvp rv32i_sim
```

If waveform dumping is enabled:

```bash
gtkwave dump.vcd
```

## Program Loading

Programs are stored as hexadecimal machine-code files.

For example:

```text
program.hex
```

The instruction memory loads the program using:

```verilog
$readmemh("program.hex", mem);
```

The program counter then fetches instructions sequentially.

## Verification

A dedicated testbench is used to verify processor functionality.

The verification flow checks:

* Instruction execution
* Register values
* ALU operations
* Immediate generation
* Memory operations
* Branches
* Jumps
* Program counter updates
* Final program results

The testbench can compare actual register values against expected values.

Example output:

```text
PASS: x1 = expected value
PASS: x2 = expected value
PASS: x3 = expected value
...
```

A timeout mechanism is also used to prevent simulations from running indefinitely.

## Test Programs

Several programs can be used to verify the processor.

### Arithmetic

Tests basic arithmetic and logical instructions.

```text
ADD
SUB
AND
OR
XOR
Immediate operations
```

### Array Sum

Tests:

* Load instructions
* Address calculation
* Arithmetic
* Looping
* Branch instructions

### GCD

Tests:

* Arithmetic
* Conditional branches
* Loops
* Register operations

### Fibonacci

Tests:

* Repeated arithmetic
* Branches
* Register updates
* Loop execution

### Memcpy

Tests:

* Load/store operations
* Address calculation
* Memory access
* Looping

## Example Simulation Flow

```bash
# Compile
iverilog -g2012 -o rv32i_sim \
    rv32i_top.v \
    rv32i_core.v \
    ...

# Run
vvp rv32i_sim

# View waveform
gtkwave dump.vcd
```

## Tools Used

* **Verilog/SystemVerilog** — RTL design
* **Icarus Verilog** — RTL simulation
* **GTKWave** — waveform analysis
* **RISC-V ISA** — processor architecture
* **Hex machine-code programs** — processor testing

## Project Goals

The main objectives of this project are:

1. Understand the RV32I instruction set architecture.
2. Design individual processor RTL components.
3. Integrate the components into a functional processor core.
4. Implement instruction and data memory.
5. Develop a working control/datapath architecture.
6. Verify processor functionality using simulation.
7. Execute real RISC-V test programs on the implemented processor.

## Future Improvements

Possible extensions include:

* Pipeline implementation
* Hazard detection
* Forwarding unit
* Branch prediction
* CSR support
* Interrupt handling
* UART peripheral
* FPGA implementation
* Synthesis and timing analysis
* ASIC physical-design flow

## Author

**Priyansh Sarkar**

B.Tech — Electronics (VLSI Design and Technology)

Project: **RV32I RISC-V Processor RTL Implementation**

