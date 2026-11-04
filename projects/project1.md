---
layout: default
title: Project 1
---

# Project 1: Car Seat Belt Warning System

## 1. Introduction

This project implements a **Car Seat Belt Warning System** using VHDL on the Basys3 FPGA board. The system monitors four digital input signals representing vehicle conditions and activates a warning light when an unsafe condition is detected.

The four inputs are:

| Signal | Description |
|---|---|
| `D` | Door status: `1` = door closed, `0` = door open |
| `K` | Key status: `1` = key inserted, `0` = key not inserted |
| `P` | Seat pressure: `1` = person seated, `0` = seat empty |
| `S` | Seat belt status: `1` = belt fastened, `0` = belt not fastened |

The project was completed in two parts.

### Part 1

The original system activates a single warning light when either:

1. The key is inserted while the door is open.
2. The key is inserted, a person is seated, and the seat belt is not fastened.

### Part 2

The design was extended by adding a two-bit output named `STATUS` to identify which warning condition is active.

| STATUS | Meaning |
|---|---|
| `00` | No warning |
| `01` | Door warning only |
| `10` | Seat-belt warning only |
| `11` | Both warnings |

The main objectives of the project were to:

- Translate the system requirements into Boolean logic.
- Implement the logic using VHDL.
- Develop a VHDL testbench to verify the design.
- Simulate all possible input combinations.
- Synthesize and implement the design using Vivado.
- Program and test the system on the Basys3 FPGA.
- Extend the original system to distinguish between different warning conditions.

---

## 2. Design

### Part 1 – Basic Warning System

The warning system contains two separate warning conditions.

### Door Warning

A door warning occurs when:

- The key is inserted: `K = 1`
- The door is open: `D = 0`

Since `D = 1` means the door is closed, an open door is represented by `NOT(D)`.

Therefore:

```text
door_warning = K AND NOT(D)
```

### Seat-Belt Warning

A seat-belt warning occurs when:

- The key is inserted: `K = 1`
- A person is seated: `P = 1`
- The seat belt is not fastened: `S = 0`

Therefore:

```text
belt_warning = K AND P AND NOT(S)
```

The final warning output is:

```text
L = (NOT(D) AND K) OR (K AND P AND NOT(S))
```

### Part 1 Block Diagram

```text
                 Door Warning
          +-----------------------+
D ------->| NOT                   |
          |         AND ----------|-----+
K ------------------------------->|     |
          +-----------------------+     |
                                         | OR -----> Warning Light L
          +-----------------------+     |
K ------->|                       |     |
P ------->|         AND ----------|-----+
S ------->| NOT                   |
          +-----------------------+
               Seat-Belt Warning
```

---

### Part 2 – STATUS Extension

Part 2 separates the two warning conditions into internal signals:

```vhdl
signal door_warning : STD_LOGIC;
signal belt_warning : STD_LOGIC;
```

The door-warning condition is:

```vhdl
door_warning <= key_in AND NOT(door_closed);
```

The seat-belt-warning condition is:

```vhdl
belt_warning <= key_in AND seat_pressure
                AND NOT(seat_belt_closed);
```

The main warning light remains ON whenever either warning is active:

```vhdl
light_en <= door_warning OR belt_warning;
```

The new two-bit `STATUS` output is generated using a conditional signal assignment:

```vhdl
STATUS <= "11" when
          (door_warning = '1' AND belt_warning = '1') else
          "01" when (door_warning = '1') else
          "10" when (belt_warning = '1') else
          "00";
```

### Part 2 Block Diagram

```text
                  +----------------+
D ---------------->|                |
K ---------------->| Door Warning   |------+
                  +----------------+      |
                                          +------> light_en
                  +----------------+      |
K ---------------->|                |------+
P ---------------->| Belt Warning   |
S ---------------->|                |
                  +----------------+
                        |      |
                        |      |
                        v      v
                  +----------------+
                  | STATUS Logic   |
                  |                |
                  | 00 = None      |
                  | 01 = Door      |
                  | 10 = Belt      |
                  | 11 = Both      |
                  +----------------+
                         |
                         v
                    STATUS[1:0]
```

---

## 3. Code

### Part 1 Files

- **Design source:** [car_warnlight.vhd](code/mp1/part1/car_warnlight.vhd)
- **Testbench:** [car_warnlight_tb.vhd](code/mp1/part1/car_warnlight_tb.vhd)
- **Constraints (XDC):** [car_warnlight.xdc](code/mp1/part1/car_warnlight.xdc)

The original VHDL design implements the warning logic using a concurrent signal assignment:

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity car_warnlight is
port (
    door_closed      : in STD_LOGIC;
    key_in           : in STD_LOGIC;
    seat_pressure    : in STD_LOGIC;
    seat_belt_closed : in STD_LOGIC;
    light_en         : out STD_LOGIC
);
end car_warnlight;

architecture Behavioral of car_warnlight is
begin

    light_en <= (NOT(door_closed) AND key_in)
                OR
                (key_in AND seat_pressure
                AND NOT(seat_belt_closed));

end Behavioral;
```

The Basys3 switches are assigned as:

```text
SW0 = D = Door closed
SW1 = K = Key inserted
SW2 = P = Person seated
SW3 = S = Seat belt fastened
```

The original warning output is connected to `LED0`.

---

### Part 2 Files

- **Design source:** [car_warnlight.vhd](code/mp1/part2/car_warnlight.vhd)
- **Testbench:** [car_warnlight_tb.vhd](code/mp1/part2/car_warnlight_tb.vhd)
- **Constraints (XDC):** [car_warnlight.xdc](code/mp1/part2/car_warnlight.xdc)

The Part 2 design introduces separate warning signals:

```vhdl
signal door_warning : STD_LOGIC;
signal belt_warning : STD_LOGIC;
```

The warning conditions are implemented as:

```vhdl
door_warning <= key_in AND NOT(door_closed);

belt_warning <= key_in AND seat_pressure
                AND NOT(seat_belt_closed);
```

The general warning output is:

```vhdl
light_en <= door_warning OR belt_warning;
```

The new STATUS output is:

```vhdl
STATUS <= "11" when
          (door_warning = '1' AND belt_warning = '1') else
          "01" when (door_warning = '1') else
          "10" when (belt_warning = '1') else
          "00";
```

The Part 2 output LEDs are:

```text
LED0 = light_en
LED1 = STATUS(0) = Door warning
LED2 = STATUS(1) = Seat-belt warning
```

---

## 4. Simulation

### Part 1 Simulation

The Part 1 testbench uses a four-bit counter to automatically test all 16 possible input combinations.

```vhdl
for i in 0 to 15 loop

    D <= count(3);
    K <= count(2);
    P <= count(1);
    S <= count(0);

    count <= count + 1;

    wait for 50 ns;

end loop;
```

Since there are four binary inputs:

```text
2^4 = 16 possible input combinations
```

The warning light should be HIGH for:

```text
DKPS = 0100
DKPS = 0101
DKPS = 0110
DKPS = 0111
DKPS = 1110
```

For all other combinations, the warning light should remain LOW.

The simulation waveform confirmed that the output behaved according to the expected Boolean logic.

![Part 1 Simulation Waveform](code/mp1/part1/simulation.jpg)

---

### Part 2 Simulation

The Part 2 testbench continues to test all 16 possible input combinations while also monitoring the new `STATUS[1:0]` output.

The four important STATUS conditions are:

| D K P S | STATUS | Meaning | light_en |
|---|---|---|---:|
| `1101` | `00` | No warning | 0 |
| `0101` | `01` | Door warning only | 1 |
| `1110` | `10` | Seat-belt warning only | 1 |
| `0110` | `11` | Both warnings | 1 |

The waveform shows all four possible STATUS values:

```text
00
01
10
11
```

![Part 2 Simulation Waveform](code/mp1/part2/simulation_waveform.jpg)

The simulation confirmed that:

- `STATUS = 00` when there is no warning.
- `STATUS = 01` when only the door warning is active.
- `STATUS = 10` when only the seat-belt warning is active.
- `STATUS = 11` when both warnings are active.
- `light_en` is HIGH whenever either warning is active.

No functional discrepancies were observed during simulation.

---

## 5. Hardware

# Part 1 Hardware

### Elaborated Design

The elaborated schematic shows the VHDL logic before FPGA-specific optimization.

It contains the logic necessary to detect the door-warning and seat-belt-warning conditions and combine the two warning conditions into the `light_en` output.

![Part 1 Elaborated Design](code/mp1/part1/elaborated_design_schematic.jpg)

---

### Synthesized Design

After synthesis, Vivado optimized the Boolean logic and mapped it into FPGA hardware resources such as LUTs and input/output buffers.

The synthesized schematic therefore appears different from the elaborated schematic even though the logical behaviour remains the same.

![Part 1 Synthesized Design](code/mp1/part1/synthesized_design_schematic.jpg)

---

### Implementation

The implemented design shows the physical placement of the synthesized logic inside the Basys3 FPGA.

Only a very small portion of the FPGA is required because the car warning system consists of simple combinational logic.

![Part 1 Implemented Design](code/mp1/part1/implemented_design.jpg)

---

### Resource Utilization

The Part 1 design uses very few FPGA resources because it does not require memory, counters, DSP blocks, or complex sequential logic.

![Part 1 Resource Utilization](code/mp1/part1/utilization_report.jpg)

---

## Part 1 Hardware Testing

The FPGA was programmed using the generated bitstream and tested by manually changing the four slide switches.

### Scenario 1 – DKPS = `0100`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 0 → Seat empty
S = 0 → Seat belt not fastened
```

The door-warning condition is active because the door is open while the key is inserted.

![Hardware Test DKPS 0100](code/mp1/part1/0100.jpeg)

**Expected result:** Warning light ON.

**Observed result:** The warning LED turned ON as expected.

---

### Scenario 2 – DKPS = `0101`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 0 → Seat empty
S = 1 → Seat belt fastened
```

The seat-belt warning is inactive, but the door-warning condition remains active.

![Hardware Test DKPS 0101](code/mp1/part1/0101.jpeg)

**Expected result:** Warning light ON.

**Observed result:** The warning LED turned ON as expected.

---

### Scenario 3 – DKPS = `0110`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 1 → Person seated
S = 0 → Seat belt not fastened
```

Both warning conditions are active.

The door is open while the key is inserted, and a person is seated without the seat belt fastened.

![Hardware Test DKPS 0110](code/mp1/part1/0110.jpeg)

**Expected result:** Warning light ON.

**Observed result:** The warning LED turned ON as expected.

---

### Scenario 4 – DKPS = `0111`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 1 → Person seated
S = 1 → Seat belt fastened
```

The seat-belt warning is inactive because the seat belt is fastened. However, the door warning remains active.

![Hardware Test DKPS 0111](code/mp1/part1/0111.jpeg)

**Expected result:** Warning light ON.

**Observed result:** The warning LED remained ON as expected.

---

### Scenario 5 – DKPS = `1110`

Input conditions:

```text
D = 1 → Door closed
K = 1 → Key inserted
P = 1 → Person seated
S = 0 → Seat belt not fastened
```

The door warning is inactive, but the seat-belt warning is active.

![Hardware Test DKPS 1110](code/mp1/part1/1110.jpeg)

**Expected result:** Warning light ON.

**Observed result:** The warning LED turned ON as expected.

---

### Scenario 6 – DKPS = `1111`

Input conditions:

```text
D = 1 → Door closed
K = 1 → Key inserted
P = 1 → Person seated
S = 1 → Seat belt fastened
```

Neither warning condition is active.

![Hardware Test No Warning](code/mp1/part1/1111(all_other_conditions_no_light).jpeg)

**Expected result:** Warning light OFF.

**Observed result:** The warning LED remained OFF as expected.

This photograph also represents the expected behaviour for other combinations where neither warning condition is active.

---

### Part 1 Hardware Testing Issue

One issue was initially encountered while testing the physical FPGA.

The logical signal order used in the VHDL and simulation is:

```text
D K P S
```

However, when viewing the four physical Basys3 switches from left to right, they appear as:

```text
SW3  SW2  SW1  SW0
 S    P    K    D
```

Therefore, the physical left-to-right order is:

```text
S P K D
```

rather than:

```text
D K P S
```

This initially caused some test combinations to appear incorrect.

After using the actual switch numbers instead of interpreting the switches from left to right, the FPGA results matched the expected truth table and simulation results.

---

# Part 2 Hardware

Part 2 adds two STATUS LEDs while keeping the original warning-light output.

The output assignments are:

| LED | Function |
|---|---|
| `LED0` | General warning output `light_en` |
| `LED1` | `STATUS(0)` – Door warning |
| `LED2` | `STATUS(1)` – Seat-belt warning |

---

### Elaborated Design

The Part 2 elaborated schematic shows the two warning conditions as separate internal signals.

The door-warning logic detects:

```text
key_in AND NOT(door_closed)
```

The seat-belt-warning logic detects:

```text
key_in AND seat_pressure AND NOT(seat_belt_closed)
```

The two warning signals are then used to generate both the general warning output and the two-bit STATUS output.

![Part 2 Elaborated Design](code/mp1/part2/elaborated_design_schematic.jpg)

---

### Synthesized Design

The synthesized schematic shows how Vivado mapped the VHDL logic into the FPGA architecture.

The inputs pass through input buffers, the Boolean functions are implemented using LUT resources, and the outputs pass through output buffers before reaching the FPGA pins.

![Part 2 Synthesized Design](code/mp1/part2/synthesized_design_schematic.jpg)

---

### Resource Utilization

The Part 2 design remains very small even after adding the two-bit STATUS output.

The utilization report showed:

| Resource | Used |
|---|---:|
| Slice LUTs | 2 |
| Bonded I/O | 7 |

The seven bonded I/O pins correspond to:

```text
4 input switches + 3 output LEDs = 7 I/O pins
```

![Part 2 Resource Utilization](code/mp1/part2/utilization.jpg)

---

## Part 2 Hardware Testing

Four hardware scenarios were used to demonstrate every possible STATUS output.

### Scenario 1 – No Warning: DKPS = `1101`

Input conditions:

```text
D = 1 → Door closed
K = 1 → Key inserted
P = 0 → Seat empty
S = 1 → Seat belt fastened
```

Neither warning condition is active.

![Part 2 No Warning DKPS 1101](code/mp1/part2/1101.jpeg)

Expected output:

```text
STATUS = 00

LED2 = OFF
LED1 = OFF
LED0 = OFF
```

**Observed result:** All three warning LEDs remained OFF.

The FPGA correctly produced:

```text
STATUS = 00
```

---

### Scenario 2 – Door Warning Only: DKPS = `0101`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 0 → Seat empty
S = 1 → Seat belt fastened
```

Only the door-warning condition is active.

![Part 2 Door Warning DKPS 0101](code/mp1/part2/0101.jpeg)

Expected output:

```text
STATUS = 01

LED2 = OFF
LED1 = ON
LED0 = ON
```

**Observed result:** `LED1` and `LED0` turned ON while `LED2` remained OFF.

The FPGA correctly produced:

```text
STATUS = 01
```

---

### Scenario 3 – Seat-Belt Warning Only: DKPS = `1110`

Input conditions:

```text
D = 1 → Door closed
K = 1 → Key inserted
P = 1 → Person seated
S = 0 → Seat belt not fastened
```

Only the seat-belt-warning condition is active.

![Part 2 Seat-Belt Warning DKPS 1110](code/mp1/part2/1110.jpeg)

Expected output:

```text
STATUS = 10

LED2 = ON
LED1 = OFF
LED0 = ON
```

**Observed result:** `LED2` and `LED0` turned ON while `LED1` remained OFF.

The FPGA correctly produced:

```text
STATUS = 10
```

---

### Scenario 4 – Both Warnings: DKPS = `0110`

Input conditions:

```text
D = 0 → Door open
K = 1 → Key inserted
P = 1 → Person seated
S = 0 → Seat belt not fastened
```

Both warning conditions are active.

![Part 2 Both Warnings DKPS 0110](code/mp1/part2/0110.jpeg)

Expected output:

```text
STATUS = 11

LED2 = ON
LED1 = ON
LED0 = ON
```

**Observed result:** `LED0`, `LED1`, and `LED2` all turned ON.

The FPGA correctly produced:

```text
STATUS = 11
```

This confirmed that both warning conditions were detected simultaneously.

The Part 2 hardware results therefore matched the expected simulation results for all four possible STATUS values.

---

## 6. Reflection

This project demonstrated the complete FPGA design process, beginning with a written system specification and ending with a functioning hardware implementation on the Basys3 board.

One of the first challenges was translating the real-world warning requirements into Boolean logic. The `door_closed` and `seat_belt_closed` signals are active-high inputs, which means an open door or an unfastened seat belt must be detected using the `NOT` operator.

Another important challenge occurred during physical FPGA testing. Some input combinations initially appeared to produce incorrect results even though the VHDL simulation was correct. The issue was caused by interpreting the physical switches from left to right as `D K P S`. In reality, the Basys3 switches appear from left to right as `SW3 SW2 SW1 SW0`, which corresponds to `S P K D`. After using the correct switch numbers, the FPGA behaviour matched the simulation.

Part 2 demonstrated how an existing digital system can be extended while preserving its original functionality. The original warning expression was separated into `door_warning` and `belt_warning` signals, which were then used to generate a two-bit STATUS output.

This allowed the system to distinguish between:

```text
00 = No warning
01 = Door warning only
10 = Seat-belt warning only
11 = Both warnings
```

Through this project, I gained practical experience with:

- Boolean logic and truth tables
- Combinational digital circuits
- Concurrent VHDL signal assignments
- Internal VHDL signals
- Conditional signal assignments
- VHDL testbenches
- Simulation waveform analysis
- RTL elaboration
- FPGA synthesis
- LUT-based FPGA implementation
- XDC constraints
- FPGA resource utilization
- Bitstream generation
- Basys3 hardware testing
- Debugging differences between simulation and physical hardware

The project reinforced the relationship between digital-design theory and FPGA implementation. The Boolean expressions written in VHDL were first represented as RTL logic during elaboration and then optimized into LUT resources during synthesis. Simulation verified the functionality before programming the FPGA, while physical hardware testing confirmed that the final implementation behaved according to the intended design.
