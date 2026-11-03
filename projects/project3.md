---
layout: default
title: Project 3
---

# Project 3: Stepper Motor Control

## 1. Introduction

This project focuses on designing and implementing a **Finite State Machine (FSM) controller for a stepper motor** using VHDL and the Basys3 FPGA development board.

The system uses a four-phase wave-drive sequence, where only one motor coil is energized at a time. The controller allows the motor to rotate in either direction using an external direction input, while an enable signal controls its operation.

The main objectives are to:

- Design a five-state FSM for stepper motor control.
- Implement clockwise and counterclockwise rotation sequences.
- Verify state transitions through behavioral simulation in Vivado.
- Integrate a clock divider to reduce the FPGA's 100 MHz clock to 500 Hz.
- Implement the controller on the Basys3 FPGA and interface it with a stepper motor through a ULN2003 driver.

## 2. Design

The system consists of two main components: a clock divider and a stepper motor FSM.

The **clock divider** converts the Basys3's 100 MHz oscillator into a 500 Hz signal that determines the stepping frequency.

The **FSM controller** receives the divided clock, direction (`dir`), enable (`en`), and reset signals. It generates a four-bit output (`q[3:0]`) corresponding to the motor coil activation sequence.

![Stepper Motor Controller Block Diagram](project3/images/controller_block_diagram.svg)

*Figure 1. Block diagram showing the clock divider, stepper motor FSM, ULN2003 driver, and motor.*

The FSM consists of five states:

| State | Output | Function |
|---|---|---|
| S0 | 0000 | Motor disabled |
| S1 | 0001 | Coil 1 activated |
| S2 | 0010 | Coil 2 activated |
| S3 | 0100 | Coil 3 activated |
| S4 | 1000 | Coil 4 activated |

When `en = 1`, the direction input determines the sequence:

- **Clockwise (`dir = 1`):** S1 → S2 → S3 → S4 → S1
- **Counterclockwise (`dir = 0`):** S4 → S3 → S2 → S1 → S4

When enable is LOW, the FSM returns to S0 on the next rising clock edge. The FPGA implementation also includes an active-HIGH reset input that immediately returns the FSM to S0.

## 3. Code

The design was developed using VHDL in Xilinx Vivado.

The FSM uses an enumerated state type containing S0 through S4. A clocked process determines the next state based on the enable and direction inputs.

A `CASE` statement implements the directional state transitions, while a `with state select` statement assigns the corresponding four-bit output.

The controller follows a **Moore FSM architecture**, where outputs depend on the current state.

For the hardware implementation, a top-level module named `Stepper_Controller` combines the clock divider and FSM.

The divider uses the following relationship:

**Half-period count = Input clock frequency / (2 × Output clock frequency)**

For 100 MHz and 500 Hz:

**Half-period count = 100,000 cycles**

The clock divider output, `slow_clk`, is connected directly to the FSM clock input.

### Source files

- **Top-level design:** [Stepper_Controller.vhd](project3/src/Stepper_Controller.vhd)
- **FSM design:** [stepper_motor_FSM.vhd](project3/src/stepper_motor_FSM.vhd)
- **Clock divider:** [clk_div.vhd](project3/src/clk_div.vhd)
- **FSM testbench:** [stepper_motor_FSM_tb.vhd](project3/src/stepper_motor_FSM_tb.vhd)
- **Clock-divider testbench:** [clk_div_tb.vhd](project3/src/clk_div_tb.vhd)
- **Constraints (XDC):** [stepper_m.xdc](project3/src/stepper_m.xdc)

## 4. Simulation

Behavioral simulation was performed in Vivado to verify the FSM state transitions before hardware integration.

The original FSM testbench generates a clock signal with a period of **10 µs** and applies different combinations of direction and enable inputs.

![FSM Simulation Waveform](project3/images/fsm_simulation.png)

*Figure 2. Behavioral simulation waveform showing the input signals, state transitions, and individual coil outputs.*

### Test scenarios and results

| Test | Expected behaviour | Observed result |
|---|---|---|
| Initial state | S0, output 0000 | Correct |
| Clockwise rotation | 0001 → 0010 → 0100 → 1000 | Correct |
| Counterclockwise rotation | 0100 → 0010 → 0001 → 1000 | Correct |
| Enable LOW | Return to S0 | Correct |
| Direction change | Reverse the state progression | Correct |
| Coil outputs | Only one output HIGH at a time | Correct |

The simulation demonstrated that state transitions occurred on the rising edge of the clock and followed the intended directional sequences.

Each motor coil output was activated individually, confirming correct wave-drive operation.

An inconsistency in the supplied state table was resolved by using the S1 → S4 transition for continuous counterclockwise rotation, as indicated by the state diagram.

The hardware version subsequently added a reset input; its updated reset testbench is included in the project files.

## 5. Hardware

### Elaborated design

The original FSM design was elaborated in Vivado to examine the RTL schematic.

![Elaborated FSM Schematic](project3/images/fsm_elaborated.png)

*Figure 3. Elaborated schematic of the original stepper motor FSM.*

The schematic displays the internal state register, combinational transition logic, multiplexers, and output decoding logic.

**Top-level controller elaboration:** [Insert screenshot showing the integrated clock divider and FSM.]

### Synthesized design

The complete controller must be synthesized to convert the VHDL design into FPGA logic resources.

[Insert synthesized schematic screenshot and discuss the resulting registers, counter logic, and output connections.]

### Implementation

The design uses the Basys3 master clock and assigns direction and enable controls to switches. The four motor-control outputs are assigned to PMOD header JA.

[Insert implementation results, timing summary, and relevant observations.]

### Resource utilization

| FPGA resource | Usage |
|---|---|
| LUTs | [Insert result] |
| Flip-flops | [Insert result] |
| I/O pins | [Insert result] |
| Clock buffers | [Insert result] |
| BRAM / DSP | [Insert result] |

### Hardware testing

The FPGA output signals are connected to a ULN2003 driver, which interfaces with the stepper motor.

The planned hardware control assignments are:

| Control | Basys3 input |
|---|---|
| Direction | SW0 |
| Enable | SW1 |
| Reset | Center button |
| Motor outputs | PMOD JA1–JA4 |

The expected motor behavior is clockwise rotation when `dir = 1`, counterclockwise rotation when `dir = 0`, and disabled coil outputs when `en = 0`.

[Insert photographs of the hardware setup and actual test results after programming the FPGA.]

## 6. Reflection

This project provided practical experience in designing and implementing a finite state machine using VHDL.

The simulation demonstrated how sequential logic can be used to control a step-by-step motor operation, with each state corresponding to a specific output pattern.

One important challenge was correctly implementing the state transitions for both rotation directions. Comparing the state diagram with the state table helped identify an inconsistency and ensure continuous operation in both directions.

Another important aspect was integrating the existing FSM with a clock divider for hardware implementation. This demonstrated how separate VHDL modules can be combined into a larger digital system using component instantiation, generic mapping, and port mapping.

The project reinforced my understanding of **Moore state machines, synchronous logic, clock division, state transition design, and FPGA interfacing**.

It also demonstrated the importance of simulation as a verification step before physical implementation, particularly when controlling external hardware.
