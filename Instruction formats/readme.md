# RV32I Instruction Formats

## Overview

The RISC-V **RV32I base integer ISA** uses fixed-length **32-bit instructions**.

RV32I has six basic instruction formats:

| Format     | Purpose                           | Examples                  |
| ---------- | --------------------------------- | ------------------------- |
| **R-type** | Register-to-register operations   | `ADD`, `SUB`, `AND`, `OR` |
| **I-type** | Immediate operations, loads, JALR | `ADDI`, `LW`, `JALR`      |
| **S-type** | Store operations                  | `SW`, `SH`, `SB`          |
| **B-type** | Conditional branches              | `BEQ`, `BNE`, `BLT`       |
| **U-type** | Upper-immediate operations        | `LUI`, `AUIPC`            |
| **J-type** | Unconditional jump                | `JAL`                     |

All standard RV32I instructions are **32 bits wide**.

---

# 1. R-Type

R-type instructions perform operations between two registers.

### Format

```text
31       25 24   20 19   15 14  12 11    7 6     0
+----------+-------+-------+------+--------+-------+
|  funct7  |  rs2  |  rs1  |funct3|   rd   |opcode |
+----------+-------+-------+------+--------+-------+
    7          5       5      3       5       7
```

### Fields

| Bits      | Field    | Description            |
| --------- | -------- | ---------------------- |
| `[31:25]` | `funct7` | Operation extension    |
| `[24:20]` | `rs2`    | Second source register |
| `[19:15]` | `rs1`    | First source register  |
| `[14:12]` | `funct3` | Operation/function     |
| `[11:7]`  | `rd`     | Destination register   |
| `[6:0]`   | `opcode` | Instruction type       |

### Examples

```assembly
ADD x5, x1, x2
SUB x5, x1, x2
AND x5, x1, x2
OR  x5, x1, x2
XOR x5, x1, x2
```

For:

```assembly
ADD x5, x1, x2
```

the operation is:

```text
x5 = x1 + x2
```

---

# 2. I-Type

I-type is used for:

* Immediate arithmetic/logical instructions
* Load instructions
* `JALR`

### Format

```text
31                 20 19   15 14  12 11    7 6     0
+--------------------+-------+------+--------+-------+
|     immediate      |  rs1  |funct3|   rd   |opcode |
+--------------------+-------+------+--------+-------+
          12             5       3       5       7
```

### Fields

| Bits      | Field     |
| --------- | --------- |
| `[31:20]` | Immediate |
| `[19:15]` | `rs1`     |
| `[14:12]` | `funct3`  |
| `[11:7]`  | `rd`      |
| `[6:0]`   | `opcode`  |

The immediate is normally **12 bits** and is sign-extended to XLEN.

### Examples

```assembly
ADDI x5, x1, 10
ANDI x5, x1, 15
LW   x5, 0(x1)
JALR x0, 0(x1)
```

For:

```assembly
ADDI x5, x1, 10
```

```text
x5 = x1 + 10
```

---

# 3. S-Type

S-type is used for **store instructions**.

Examples:

```assembly
SW x5, 0(x1)
SH x5, 4(x1)
SB x5, 8(x1)
```

### Format

```text
31       25 24   20 19   15 14  12 11     7 6     0
+----------+-------+-------+------+---------+-------+
| imm[11:5]|  rs2  |  rs1  |funct3| imm[4:0]|opcode |
+----------+-------+-------+------+---------+-------+
```

The immediate is split into two parts.

```text
imm[11:5] = instruction[31:25]
imm[4:0]  = instruction[11:7]
```

Therefore:

```text
immediate = {instruction[31:25], instruction[11:7]}
```

### Why is there no `rd`?

A store does not write a result to a register.

For:

```assembly
SW x5, 8(x1)
```

the operation is:

```text
Memory[x1 + 8] = x5
```

---

# 4. B-Type

B-type is used for **conditional branches**.

Examples:

```assembly
BEQ x1, x2, label
BNE x1, x2, label
BLT x1, x2, label
BGE x1, x2, label
```

### Format

```text
31  30       25 24   20 19   15 14  12 11  8 7 6     0
+---+-----------+-------+-------+------+-----+-+-------+
|12 | 10:5      |  rs2  |  rs1  |funct3|4:1  |11|opcode|
+---+-----------+-------+-------+------+-----+-+-------+
```

The immediate is scattered across the instruction.

```text
imm[12]   = instruction[31]
imm[10:5] = instruction[30:25]
imm[4:1]  = instruction[11:8]
imm[11]   = instruction[7]
imm[0]    = 0
```

So:

```text
branch_offset =
{instruction[31],
 instruction[7],
 instruction[30:25],
 instruction[11:8],
 1'b0}
```

### Example

```assembly
BEQ x1, x2, label
```

Conceptually:

```text
if (x1 == x2)
    PC = PC + branch_offset;
else
    PC = PC + 4;
```

The least-significant immediate bit is always `0`, giving branch targets **2-byte alignment**.

---

# 5. U-Type

U-type instructions contain a **20-bit upper immediate**.

The two main U-type instructions are:

```assembly
LUI
AUIPC
```

### Format

```text
31                         12 11    7 6     0
+----------------------------+--------+-------+
|       immediate[31:12]     |   rd   |opcode |
+----------------------------+--------+-------+
             20                  5       7
```

### LUI

```assembly
LUI x5, 0x12345
```

Conceptually:

```text
x5 = 0x12345000
```

The immediate occupies bits `[31:12]`.

---

### AUIPC

```assembly
AUIPC x5, 0x12345
```

Conceptually:

```text
x5 = PC + 0x12345000
```

`AUIPC` means:

> Add Upper Immediate to PC.

---

# 6. J-Type

J-type is used by the `JAL` instruction.

### Format

```text
31  30        21 20 19       12 11    7 6     0
+---+------------+---+-----------+--------+-------+
|20 |   10:1     |11 |   19:12   |   rd   |opcode |
+---+------------+---+-----------+--------+-------+
```

The immediate is reconstructed as:

```text
imm[20]    = instruction[31]
imm[10:1]  = instruction[30:21]
imm[11]    = instruction[20]
imm[19:12] = instruction[19:12]
imm[0]     = 0
```

Therefore:

```text
jump_offset =
{instruction[31],
 instruction[19:12],
 instruction[20],
 instruction[30:21],
 1'b0}
```

### Example

```assembly
JAL x1, label
```

Conceptually:

```text
x1 = PC + 4
PC = PC + jump_offset
```

The value stored in `x1` is the **return address**.

---

# 7. Format Summary

```text
R-Type

31       25 24   20 19   15 14  12 11    7 6     0
+----------+-------+-------+------+--------+-------+
|  funct7  |  rs2  |  rs1  |funct3|   rd   |opcode |
+----------+-------+-------+------+--------+-------+


I-Type

31                 20 19   15 14  12 11    7 6     0
+--------------------+-------+------+--------+-------+
|     immediate      |  rs1  |funct3|   rd   |opcode |
+--------------------+-------+------+--------+-------+


S-Type

31       25 24   20 19   15 14  12 11     7 6     0
+----------+-------+-------+------+---------+-------+
| imm[11:5]|  rs2  |  rs1  |funct3| imm[4:0]|opcode |
+----------+-------+-------+------+---------+-------+


B-Type

31  30       25 24   20 19   15 14  12 11  8 7 6   0
+---+-----------+-------+-------+------+-----+-+-----+
|12 |  10:5     |  rs2  |  rs1  |funct3| 4:1 |11|opcode
+---+-----------+-------+-------+------+-----+-+-----+


U-Type

31                         12 11    7 6     0
+----------------------------+--------+-------+
|       immediate[31:12]     |   rd   |opcode |
+----------------------------+--------+-------+


J-Type

31  30       21 20 19       12 11    7 6     0
+---+-----------+---+-----------+--------+-------+
|20 |   10:1    |11 |   19:12   |   rd   |opcode |
+---+-----------+---+-----------+--------+-------+
```

---

# 8. Instruction Format vs Instruction Type

Do not confuse **instruction format** with the specific instruction.

For example:

```text
ADD
```

is an instruction, while:

```text
R-type
```

is its instruction format.

Similarly:

```text
ADDI → I-type
LW   → I-type
SW   → S-type
BEQ  → B-type
LUI  → U-type
JAL  → J-type
```

---

# 9. Why Are Immediate Bits Split?

You may notice that S-type, B-type and J-type immediates are not stored in consecutive bits.

For example, B-type stores the immediate as:

```text
31 | 30:25 | 11:8 | 7
```

instead of:

```text
31:20
```

This is intentional.

RISC-V keeps important fields such as:

```text
rs1
rs2
rd
opcode
funct3
```

in consistent bit positions across instruction formats.

This simplifies the **hardware decoder**.

Instead of having to move the register fields around depending on the instruction, the processor can consistently use:

```text
rs1 = instruction[19:15]
rs2 = instruction[24:20]
rd  = instruction[11:7]
```

This makes the instruction decoder simpler and faster.

---

# 10. Immediate Generator

In an RV32I processor, the immediate generator extracts and reconstructs the immediate according to the instruction format.

Conceptually:

```text
                 Instruction
                      |
                      v
               +-------------+
               | Imm. Gen.   |
               +-------------+
                /  /  |  \  \
               /  /   |   \  \
              v  v    v    v  v
             I   S    B    U   J
```

For example:

```text
I-type:
imm = instruction[31:20]

S-type:
imm = {instruction[31:25],
       instruction[11:7]}

B-type:
imm = {instruction[31],
       instruction[7],
       instruction[30:25],
       instruction[11:8],
       1'b0}
```

The immediate is then usually **sign-extended to 32 bits**.

---

# 11. Opcode Reference

Common RV32I opcodes:

| Instruction   | Format | Opcode    |
| ------------- | ------ | --------- |
| R-type ALU    | R      | `0110011` |
| Immediate ALU | I      | `0010011` |
| Load          | I      | `0000011` |
| Store         | S      | `0100011` |
| Branch        | B      | `1100011` |
| JAL           | J      | `1101111` |
| JALR          | I      | `1100111` |
| LUI           | U      | `0110111` |
| AUIPC         | U      | `0010111` |

---


B → split immediate | rs2 | rs1 | funct3 | split immediate | opcode
U → imm[31:12] | rd | opcode
J → split immediate | rd | opcode
```

