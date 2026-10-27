****Below is a filled-in version based on your actual Project 1 design, VHDL, simulation, Basys3 implementation, and the switch-order issue you encountered.

---
layout: default
title: MiniProject 1
---

# Project 1: Car Seat Belt Warning System

## 1. Introduction

The purpose of this project was to design and implement a car seat belt warning system using VHDL and an FPGA. The system monitors several vehicle-related input conditions and determines whether a warning light should be turned on.

The design uses four digital inputs:

- D – Door closed
- K – Key inserted
- P – Seat pressure / person seated
- S – Seat belt fastened

Each input represents the output of a sensor or switch. A logic `1` means the corresponding condition is active, while a logic `0` means it is inactive.

The warning light turns ON under two main conditions:

1. The key is inserted while the door is open.
2. The key is inserted, a person is seated, and the seat belt is not fastened.

The main objectives of the project were to:

- Translate the system requirements into Boolean logic.
- Implement the logic using VHDL.
- Verify the design using simulation.
- Synthesize and implement the design using Vivado.
- Program the design onto a Basys3 FPGA board.
- Verify that the physical FPGA behaves according to the expected logic.

---

## 2. Design

The system consists of four digital input signals and one output warning signal.

The input definitions are:

| Signal | Meaning when logic = 1 |
|---|---|
| D | Door is closed |
| K | Key is inserted |
| P | Person is seated |
| S | Seat belt is fastened |

The output is:

| Signal | Meaning |
|---|---|
| L | Warning light |

The warning light must turn on when either of the following conditions is true:

### Door warning

The door warning is active when:

- The key is inserted, and
- The door is open.

Since `D = 1` means that the door is closed, an open door is represented by `NOT D`.

Therefore:

```text
Door warning = NOT(D) AND K
```

### Seat-belt warning

The seat-belt warning is active when:

- The key is inserted,
- A person is seated, and
- The seat belt is not fastened.

Since `S = 1` means the seat belt is fastened, an unfastened seat belt is represented by `NOT S`.

Therefore:

```text
Seat-belt warning = K AND P AND NOT(S)
```

The final warning-light expression is:

```text
L = (NOT(D) AND K) OR (K AND P AND NOT(S))
```

### Block Diagram

```text
               +-----------------------+
Door D ------->|                       |
Key K -------->|                       |
Seat P ------->|  Warning Logic        |------> Warning Light L
Belt S ------->|                       |
               +-----------------------+

Door warning:
NOT(D) AND K

Seat-belt warning:
K AND P AND NOT(S)

Final output:
Door warning OR Seat-belt warning
```

The two conditions are combined using an OR operation. Therefore, the warning light turns on whenever either warning condition is active.

---

## 3. Code

The FPGA design was written in VHDL using a behavioural architecture.

### Entity Declaration

The entity defines four input signals and one output signal:

```vhdl
entity car_warnlight is
port (
    door_closed      : in STD_LOGIC;
    key_in           : in STD_LOGIC;
    seat_pressure    : in STD_LOGIC;
    seat_belt_closed : in STD_LOGIC;
    light_en         : out STD_LOGIC
);
end car_warnlight;
```

The four inputs correspond to the four sensor conditions, while `light_en` controls the warning LED.

### Warning Logic

The main logic is implemented using a concurrent signal assignment:

```vhdl
light_en <= (NOT(door_closed) AND key_in)
            OR
            (key_in AND seat_pressure AND NOT(seat_belt_closed));
```

The first part:

```vhdl
NOT(door_closed) AND key_in
```

detects the condition where the door is open and the key is inserted.

The second part:

```vhdl
key_in AND seat_pressure AND NOT(seat_belt_closed)
```

detects the condition where the key is inserted, a person is seated, and the seat belt is not fastened.

The OR operation combines both warning conditions.

### Testbench

The testbench uses a 4-bit counter to automatically test all possible combinations of the four inputs.

```vhdl
Signal count : STD_LOGIC_VECTOR(3 downto 0) := X"0";
Signal D, K, P, S, L : STD_LOGIC;
```

The counter bits are assigned to the four input signals:

```vhdl
D <= count(3);
K <= count(2);
P <= count(1);
S <= count(0);
```

The counter increases after each test:

```vhdl
count <= count + 1;
wait for 50 ns;
```

Because there are four binary inputs, there are:

```text
2^4 = 16
```

possible input combinations. The testbench therefore checks all 16 combinations from `0000` to `1111`.

### Constraints File

The four Basys3 switches were assigned as:

```text
SW0 = D
SW1 = K
SW2 = P
SW3 = S
```

The relevant XDC assignments were:

```tcl
set_property PACKAGE_PIN V17 [get_ports door_closed]
set_property IOSTANDARD LVCMOS33 [get_ports door_closed]

set_property PACKAGE_PIN V16 [get_ports key_in]
set_property IOSTANDARD LVCMOS33 [get_ports key_in]

set_property PACKAGE_PIN W16 [get_ports seat_pressure]
set_property IOSTANDARD LVCMOS33 [get_ports seat_pressure]

set_property PACKAGE_PIN W17 [get_ports seat_belt_closed]
set_property IOSTANDARD LVCMOS33 [get_ports seat_belt_closed]
```

The warning output was assigned to LED0:

```tcl
set_property PACKAGE_PIN U16 [get_ports {light_en}]
set_property IOSTANDARD LVCMOS33 [get_ports {light_en}]
```

### Design Files

- **Design source:** [Link]
- **Testbench:** [Link]
- **Constraints (XDC):** [Link]

The links can be replaced with the actual GitHub or project repository links after the files are uploaded.

---

## 4. Simulation

The design was simulated in Vivado before being programmed onto the FPGA.

The testbench automatically tested all 16 input combinations.

The expected output is based on:

```text
L = (NOT(D) AND K) OR (K AND P AND NOT(S))
```

The complete expected truth table is:

| D | K | P | S | Expected L |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 0 | 1 | 0 |
| 0 | 0 | 1 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 0 | 1 |
| 0 | 1 | 0 | 1 | 1 |
| 0 | 1 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 0 |
| 1 | 0 | 1 | 1 | 0 |
| 1 | 1 | 0 | 0 | 0 |
| 1 | 1 | 0 | 1 | 0 |
| 1 | 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 | 0 |

The warning output should therefore be HIGH for:

```text
0100
0101
0110
0111
1110
```

and LOW for all other input combinations.

### Door Warning Test

Example:

```text
D = 0
K = 1
P = 0
S = 0
```

The door is open and the key is inserted.

Expected:

```text
L = 1
```

Observed:

```text
L = 1
```

The result matched the expected behaviour.

### Seat-Belt Warning Test

Example:

```text
D = 1
K = 1
P = 1
S = 0
```

The door is closed, the key is inserted, a person is seated, and the seat belt is not fastened.

Expected:

```text
L = 1
```

Observed:

```text
L = 1
```

The simulation matched the expected behaviour.

### No-Warning Test

Example:

```text
D = 1
K = 1
P = 1
S = 1
```

The person is seated but the seat belt is fastened.

Expected:

```text
L = 0
```

Observed:

```text
L = 0
```

This also matched the expected result.

Overall, the simulation confirmed that the VHDL implementation correctly followed the required Boolean expression.

<img width="720" height="255" alt="Picture1" src="https://github.com/user-attachments/assets/b762d267-df89-483e-a42b-833dc049fed7" />

---

## 5. Hardware

After successful simulation, the design was synthesized and implemented in Vivado and then programmed onto the Basys3 FPGA board.

### Elaborated Design

The elaborated design shows the logical structure generated directly from the VHDL source before FPGA-specific optimization.

The schematic contains:

- NOT logic for `door_closed`
- NOT logic for `seat_belt_closed`
- AND gates for the two warning conditions
- An OR gate combining the two warnings
- The `light_en` output

The elaborated schematic confirmed that the VHDL statement had been interpreted correctly.

<img width="1125" height="322" alt="image" src="https://github.com/user-attachments/assets/592fa13e-25c6-44d2-9293-4fcaed1642cc" />


### Synthesized Design

The synthesized schematic shows the optimized hardware implementation produced by Vivado.

Because the design contains only simple combinational Boolean logic, Vivado can optimize the logic and implement it efficiently using the FPGA's internal LUT resources.

The synthesized design may therefore appear slightly different from the elaborated schematic, even though it performs the same logical function.

<img width="1005" height="844" alt="image" src="https://github.com/user-attachments/assets/95f892e2-22bc-4cc2-96aa-15fa39284063" />


### Implementation

The synthesized design was then placed and routed on the Basys3 FPGA.

The four physical slide switches were used as inputs, and LED0 was used as the warning output.

The implementation completed successfully, allowing the design bitstream to be generated and programmed onto the board.

<img width="1094" height="822" alt="image" src="https://github.com/user-attachments/assets/2092fc2a-19fa-4474-bbe0-217d72310564" />


### Resource Utilization

The design requires very few FPGA resources because it consists only of simple combinational logic.

The main FPGA resources expected to be used include:

- A small number of LUTs
- Input/output pins
- No flip-flops are required for the warning logic itself
- No block RAM
- No DSP blocks

<img width="691" height="98" alt="image" src="https://github.com/user-attachments/assets/fc09f213-b893-45f3-91ba-d239a4a804da" />

The low utilization is expected because this project implements only a small combinational logic circuit.

### Hardware Testing

The FPGA was tested by manually changing the four slide switches and observing the warning LED.

The XDC file assigns:

```text
SW0 = D
SW1 = K
SW2 = P
SW3 = S
```

One issue was initially encountered while testing the physical board. The conditions `0100` and `0101`, when read visually from left to right on the FPGA board, appeared not to turn the LED on even though the simulation predicted that they should.

The problem was caused by the physical orientation of the Basys3 switches.

When viewing the four switches from left to right, their order is:

```text
SW3 SW2 SW1 SW0
```

Therefore, the physical left-to-right order is:

```text
S P K D
```

rather than:

```text
D K P S
```

For example, the logical condition:

```text
D K P S = 0100
```

must physically be entered as:

```text
SW3 SW2 SW1 SW0 = 0010
```

Similarly:

```text
D K P S = 0101
```

must physically be entered as:

```text
SW3 SW2 SW1 SW0 = 1010
```

After accounting for the switch orientation, the hardware results matched the simulation and expected truth table.

This confirmed that the VHDL logic and FPGA implementation were correct.

**[Photograph of Basys3 hardware testing]**

---

## 6. Reflection

One of the main challenges in this project was distinguishing between a logic-design problem and a hardware-interface problem.

The VHDL simulation showed that the Boolean expression behaved correctly. However, during hardware testing, some input combinations initially appeared to produce incorrect results. In particular, the `0100` and `0101` conditions appeared not to activate the warning light.

After checking the Boolean equation, simulation waveform, and FPGA constraints, it was determined that the problem was caused by the physical order of the Basys3 switches. The switches are numbered from SW0 on the right to SW3 on the left, so visually reading them from left to right reverses the intended `D K P S` order.

This demonstrated the importance of carefully checking the relationship between logical signal names, FPGA pins, and physical board components.

From this project, I learned how to:

- Translate written system requirements into Boolean expressions.
- Implement combinational logic using VHDL.
- Create a testbench that automatically tests all possible input combinations.
- Interpret simulation waveforms.
- Use an XDC constraints file to connect VHDL signals to FPGA switches and LEDs.
- Elaborate, synthesize, implement, and generate a bitstream in Vivado.
- Debug differences between simulation and real FPGA hardware.
- Understand how synthesis may optimize a logic circuit while preserving the same functional behaviour.

This project relates directly to digital-design concepts covered in the course, including Boolean algebra, truth tables, combinational logic, logic gates, simulation, synthesis, and FPGA implementation.

Overall, the project demonstrated the complete FPGA design process from a written specification to a working hardware implementation.

You mainly need to replace the `[Link]`, `[Insert screenshot...]`, and resource-utilization placeholders with your own files and Vivado screenshots.********
