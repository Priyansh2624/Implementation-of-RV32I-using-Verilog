# 32-bit Adder

A simple **32-bit combinational adder** implemented in Verilog HDL.

The design adds two 32-bit operands and produces a 32-bit result. It is intended as a basic arithmetic building block for larger RTL datapaths and processor designs.

## 📌 Description

The module accepts two 32-bit inputs:

* `a` — First operand
* `b` — Second operand

and produces:

* `y` — 32-bit sum

The addition is implemented using a continuous assignment:

```verilog
assign y = a + b;
```

Because this is a purely combinational circuit, there is no clock or reset.

## 🔌 Module Interface

| Signal |   Width | Direction | Description    |
| ------ | ------: | --------- | -------------- |
| `a`    | 32 bits | Input     | First operand  |
| `b`    | 32 bits | Input     | Second operand |
| `y`    | 32 bits | Output    | 32-bit sum     |

## ❓ Why Are There No Carry-In or Carry-Out Signals?

This design intentionally does **not** include `carry_in` or `carry_out`.

The purpose of this module is to implement a straightforward **32-bit addition operation** where only the lower 32 bits of the result are required.

In Verilog:

```verilog
assign y = a + b;
```

the addition can internally produce a 33-bit mathematical result, but `y` is only 32 bits wide. Therefore, any carry beyond bit 31 is discarded.

For example:

```text
  11111111111111111111111111111111
+ 00000000000000000000000000000001
----------------------------------
1 00000000000000000000000000000000
^
carry beyond 32 bits
```

The module therefore produces:

```text
y = 32'h00000000
```

The carry is not exposed because **the specification of this particular adder only requires the 32-bit result**.

### Why No Carry-In?

A `carry_in` is normally required when building an adder from smaller adder stages or when connecting it to another arithmetic unit.

For example, a 32-bit adder could be constructed from smaller blocks:

```text
4-bit Adder → 4-bit Adder → 4-bit Adder → ... → 4-bit Adder
                 │
                 └── Carry
```

In such a design, the carry from one block becomes the carry-in of the next block.

However, this module directly performs:

```text
y = a + b
```

and therefore does not require an external carry input.

### Why No Carry-Out?

A `carry_out` would be necessary if the design needed to:

* detect overflow beyond 32 bits,
* perform multi-word arithmetic,
* cascade multiple adders, or
* explicitly expose the 33rd bit of the addition.

This particular implementation only requires the **32-bit sum**, so the carry-out is intentionally omitted.

## 🧩 RTL Implementation

```verilog
`timescale 1ns/1ps

module adder(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] y
);

assign y = a + b;

endmodule
```

## ⚙️ Operation

The operation is simply:

```text
y = a + b
```

Conceptually:

```text
        a[31:0]
           │
           │
           ▼
      ┌───────────┐
      │  32-bit   │
      │   Adder    │
      └───────────┘
           ▲
           │
        b[31:0]
           │
           ▼
        y[31:0]
```

## 🧪 Example

For:

```text
a = 32'd10
b = 32'd20
```

the result is:

```text
y = 32'd30
```

For the maximum 32-bit value:

```text
a = 32'hFFFFFFFF
b = 32'h00000001
```

the mathematical result is:

```text
1_00000000
```

Since `y` is only 32 bits wide:

```text
y = 32'h00000000
```

The additional carry bit is discarded.

## 🎯 Design Characteristics

* **Combinational RTL**
* **32-bit operands**
* **32-bit output**
* **No clock**
* **No reset**
* **No carry-in**
* **No carry-out**
* Uses Verilog's built-in addition operator

## 🛠️ Tools

* Verilog HDL
* Icarus Verilog
* GTKWave (if waveform simulation is performed)

## 📚 Learning Objective

This project demonstrates how a basic arithmetic operation can be described at the **RTL level using Verilog HDL**.

It also illustrates an important design decision: the interface contains only the signals required by the specification. Since this module only needs to return a 32-bit sum, external carry-in and carry-out signals are not included.

This type of adder can serve as a basic building block for larger datapaths, including **ALUs and processor architectures**.

