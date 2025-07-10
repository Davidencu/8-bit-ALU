# 8-bit-ALU

## Short project description

ALU (Arithmetic Logic Unit) is a hardware device capable of performing arithmetic (addition, subtraction, multiplication, division, exponentiation, etc.) and logical (XOR, AND, OR, etc.) operations, depending on certain inputs.

This ALU is designed to perform 4 basic aritmetic operations using logic gates and basic hardware components (multiplexers, encoders, decoders, counters, registers, etc.):

1. Addition
2. Subtraction
3. Multiplication
4. Division

## Algorithms chosen

The ALU uses booth radix 2 algorithm (for multiplication) combined with the SRT radix 2 algorithm (for division). These algorithms were chosen because both are based on single left or right shifts, easy to implement using control bits and flip-flops, which optimizes the hardware architecture.

## How it works?

This system receives two operands on 8 bits and a 2-bit operation encoding in the following way:

  + 00 -> addition
  + 01 -> subtraction
  + 10 -> multiplication
  + 11 -> division

The output is the result on 16 bits, shown on the outbus line.

When doing division, the most significant 8 bits of the result represent the remainder and the other bits represent the quotient.

## How to run?

First, make sure you have ModelSim installed on your computer.

In order to test this module, you have to open the `ALU_tb.v` file in the `ALU_verilog_implementation` directory and enter the values of the two operands at the lines 176 and 177, as well as the desired operation at line 178.

Then run the following command in the Transcript window to compile the ALU:

```
do run_ALU_tb.txt
```

Make sure you are in the `8-bit-ALU/ALU_verilog_implementation` directory before running any command!!

Now, run the following commands in order:

```
vsim -voptargs=+acc work.ALU_tb
add wave -position end sim:/ALU_tb/*
run -all
```
Now, you should be able to see the time diagram of all signals inside the circuit. If this diagram seems too complicated to read, the correct result is displayed at the outbus line and from 3500 ps to end of the simulation the outbus line should display the correct result.





