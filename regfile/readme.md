# RV32I Register File

## Overview

This module implements the **32 × 32-bit integer register file** required by the RISC-V RV32I architecture.

The register file contains **32 general-purpose registers (`x0`–`x31`)**, with each register storing a 32-bit value.

It provides:

* Two simultaneous read ports
* One write port
* Synchronous register writes
* Combinational register reads
* Hardwired zero register (`x0`)

## Architecture

```text
                 ┌─────────────────────┐
 rs1 ───────────►│                     │
                 │                     ├────► read_data1
 rs2 ───────────►│    Register File    │
                 │      32 × 32       ├────► read_data2
                 │                     │
 rd  ───────────►│                     │
 write_data ────►│                     │
 RegWrite ──────►│                     │
 clk ───────────►│                     │
                 └─────────────────────┘
```

The register file allows the processor to read two source registers and write one destination register in the same clock cycle.

## Register Organization

| Register  | ABI Name | Description         |
| --------- | -------- | ------------------- |
| `x0`      | `zero`   | Always reads as `0` |
| `x1`      | `ra`     | Return address      |
| `x2`      | `sp`     | Stack pointer       |
| `x3`      | `gp`     | Global pointer      |
| `x4`      | `tp`     | Thread pointer      |
| `x5–x7`   | `t0–t2`  | Temporaries         |
| `x8–x9`   | `s0–s1`  | Saved registers     |
| `x10–x17` | `a0–a7`  | Function arguments  |
| `x18–x27` | `s2–s11` | Saved registers     |
| `x28–x31` | `t3–t6`  | Temporaries         |

## Interface

Typical module interface:

```verilog
module regfile (
    input  wire        clk,
    input  wire        reset,
    input  wire        RegWrite,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
```

### Inputs

* `clk` — Clock signal.
* `reset` — Resets the register file.
* `RegWrite` — Enables writing to the destination register.
* `rs1` — Address of the first source register.
* `rs2` — Address of the second source register.
* `rd` — Address of the destination register.
* `write_data` — Data to be written to `rd`.

### Outputs

* `read_data1` — Contents of register `rs1`.
* `read_data2` — Contents of register `rs2`.

## Read Operation

The two read ports operate combinationally.

For example:

```text
rs1 = x5
rs2 = x10
```

produces:

```text
read_data1 = contents of x5
read_data2 = contents of x10
```

No clock edge is required to read the registers.

## Write Operation

Register writes occur on the active clock edge when `RegWrite` is asserted.

```text
RegWrite = 1
rd       = x5
write_data = 100
```

On the next active clock edge:

```text
x5 = 100
```

If:

```text
RegWrite = 0
```

the register file does not perform a write.

## Zero Register

RISC-V requires `x0` to always contain zero.

Therefore:

```text
x0 = 0
```

Reading `x0` always produces:

```text
read_data = 32'b0
```

Writes to `x0` must have no effect.

For example:

```text
rd = x0
write_data = 12345
RegWrite = 1
```

must still leave:

```text
x0 = 0
```

This is an important behavior to verify in the testbench.

## Reset Behavior

During reset, the register file can be initialized to zero:

```text
x0 = 0
x1 = 0
x2 = 0
...
x31 = 0
```

After reset, the register file is ready for normal processor operation.

## Verification

The register file should be tested independently before integrating it into the RV32I core.

The testbench should verify:

### 1. Reset

Check that registers are initialized correctly.

### 2. Register Write

Write different values to different registers and verify that the values are stored correctly.

### 3. Dual Read

Verify that both read ports can access different registers simultaneously.

### 4. `x0` Behavior

Attempt to write to `x0` and verify that it remains zero.

### 5. Multiple Writes

Perform writes to several registers on consecutive clock cycles and verify that previously written values are preserved.

### Example

```text
Write:
    x5  ← 100
    x10 ← 200
    x15 ← 300

Read:
    x5  → 100
    x10 → 200
    x15 → 300

Attempt:
    x0 ← 999

Expected:
    x0 = 0


## Role in the RV32I Processor

The register file is a central component of the processor datapath.

```text
             Instruction
                  │
             ┌────┴────┐
             │  Decode │
             └────┬────┘
                  │
          ┌───────┴────────┐
          │                │
         rs1              rs2
          │                │
          ▼                ▼
      ┌────────────────────────┐
      │      Register File     │
      │        32 × 32         │
      └───────────┬────────────┘
                  │
            read_data1/2
                  │
                  ▼
                 ALU
                  │
                  ▼
             Write Back
                  │
                  ▼
                  rd
```

The register file therefore connects the **instruction decode stage, execution stage, and write-back stage** of the RV32I processor.

## Tools

* Verilog
* Icarus Verilog
* GTKWave
* RISC-V RV32I ISA

