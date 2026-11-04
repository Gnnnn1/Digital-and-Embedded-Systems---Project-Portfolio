---
layout: default
title: Project 1
---

# Project 1: Car Seat Belt Warning System

## 1. Introduction

This project implements a **Car Seat Belt Warning System** using VHDL on the Basys3 FPGA board. The system uses four digital input signals representing vehicle conditions and produces a warning light when an unsafe condition is detected.

The four inputs are:

| Signal | Description |
|---|---|
| `D` | Door status: `1` = door closed, `0` = door open |
| `K` | Key status: `1` = key inserted, `0` = key not inserted |
| `P` | Seat pressure: `1` = person seated, `0` = seat empty |
| `S` | Seat belt status: `1` = belt fastened, `0` = belt not fastened |

The original system in **Part 1** activates a single warning light when either:

1. The key is inserted while the door is open.
2. The key is inserted, a person is seated, and the seat belt is not fastened.

The design was extended in **Part 2** by adding a two-bit `STATUS` output to distinguish between the warning conditions.

| STATUS | Meaning |
|---|---|
| `00` | No warning |
| `01` | Door warning only |
| `10` | Seat-belt warning only |
| `11` | Both warnings |

The main objectives were to:

- Convert system requirements into Boolean logic.
- Implement the logic using VHDL.
- Develop a testbench to verify all input combinations.
- Simulate and verify the design in Vivado.
- Synthesize and implement the design on the Basys3 FPGA.
- Test the system using physical switches and LEDs.
- Extend the original system to identify individual warning conditions.

---

## 2. Design

### Part 1 – Basic Warning System

The warning light is controlled by two independent warning conditions.

### Door Warning

A door warning occurs when:

- The key is inserted: `K = 1`
- The door is open: `D = 0`

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

The final warning-light equation is:

```text
L = (NOT(D) AND K) OR (K AND P AND NOT(S))
```

### Part 1 Block Diagram

```text
                Door Warning
          +----------------------+
D ------->| NOT                  |
          |        AND ----------|----+
K ------------------------------>|    |
          +----------------------+    |
                                       | OR ------> Warning Light L
          +----------------------+    |
K ------->|                      |    |
P ------->|        AND ----------|----+
S ------->| NOT                  |
          +----------------------+
              Seat-Belt Warning
```

---

### Part 2 – Warning STATUS Extension

Part 2 extends the system by creating two internal warning signals:

```vhdl
signal door_warning : STD_LOGIC;
signal belt_warning : STD_LOGIC;
```

The warning signals are generated independently:

```vhdl
door_warning <= key_in AND NOT(door_closed);

belt_warning <= key_in AND seat_pressure
                AND NOT(seat_belt_closed);
```

The main warning light remains active whenever either warning is present:

```vhdl
light_en <= door_warning OR belt_warning;
```

The two-bit `STATUS` output identifies the active warning:

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
                         |     |
                         |     |
                         v     v
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

The original design implements the complete Boolean expression using a concurrent signal assignment:

```vhdl
light_en <= (NOT(door_closed) AND key_in)
            OR
            (key_in AND seat_pressure
            AND NOT(seat_belt_closed));
```

The four Basys3 switches are assigned as:

```text
SW0 = D = Door closed
SW1 = K = Key inserted
SW2 = P = Person seated
SW3 = S = Seat belt fastened
```

The warning output is connected to `LED0`.

---

### Part 2 Files

- **Design source:** [car_warnlight.vhd](code/mp1/part2/car_warnlight.vhd)
- **Testbench:** [car_warnlight_tb.vhd](code/mp1/part2/car_warnlight_tb.vhd)
- **Constraints (XDC):** [car_warnlight.xdc](code/mp1/part2/car_warnlight.xdc)

Part 2 separates the warning conditions into two internal signals:

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

The LEDs used for Part 2 are:

```text
LED0 = light_en
LED1 = STATUS(0) = Door warning
LED2 = STATUS(1) = Seat-belt warning
```

---

## 4. Simulation

### Part 1 Simulation

The Part 1 testbench automatically tests all 16 possible combinations of the four inputs.

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

The warning light should turn ON for:

```text
0100
0101
0110
0111
1110
```

and remain OFF for all other combinations.

The simulation waveform confirmed that `L` behaved according to the expected Boolean expression.

![Part 1 Simulation Waveform](code/mp1/part1/simulation.jpg)

---

### Part 2 Simulation

The Part 2 testbench retains the same 16-combination testing method while also monitoring `STATUS[1:0]`.

The important warning states are:

| D K P S | STATUS | Meaning | light_en |
|---|---|---|---:|
| `1101` | `00` | No warning | 0 |
| `0101` | `01` | Door warning only | 1 |
| `1110` | `10` | Seat-belt warning only | 1 |
| `0110` | `11` | Both warnings | 1 |

The waveform displays all four required STATUS values: `00`, `01`, `10`, and `11`.

![Part 2 Simulation Waveform](code/mp1/part2/simulation_waveform.jpg)

The simulation confirmed that the main warning light remained HIGH whenever either warning was active and that the STATUS output correctly identified the warning type.

---

## 5. Hardware

# Part 1 Hardware

### Elaborated Design

The elaborated schematic shows the VHDL logic before FPGA-specific optimization. It contains the logic required to detect the door-warning and seat-belt-warning conditions and combine them into the warning-light output.

![Part 1 Elaborated Design](code/mp1/part1/elaborated_design_schematic.jpg)

---

### Synthesized Design

After synthesis, Vivado optimized the Boolean logic and mapped it to FPGA resources such as LUTs and input/output buffers.

![Part 1 Synthesized Design](code/mp1/part1/synthesized_design_schematic.jpg)

---

### Implementation

The implemented design shows the placement of the synthesized logic inside the Basys3 FPGA.

Only a very small part of the FPGA is required because the warning system consists of simple combinational logic.

![Part 1 Implemented Design](code/mp1/part1/implemented_design.jpg)

---

### Resource Utilization

The design uses very few FPGA resources because it does not require memory, counters, or complex sequential logic.

![Part 1 Resource Utilization](code/mp1/part1/utilization_report.jpg)

---

## Part 1 Hardware Testing

### Test 1 – DKPS = `0100`

This condition represents:

- Door open
- Key inserted
- Seat empty
- Seat belt not fastened

The door-warning condition is active.

![Hardware Test – DKPS 0100](code/mp1/part1/0100.jpeg)

**Expected behaviour:** Warning light ON.

**Observed behaviour:** The warning LED turned ON as expected.

---

### Test 2 – DKPS = `0101`

This condition represents:

- Door open
- Key inserted
- Seat empty
- Seat belt fastened

The door is still open while the key is inserted, so the door-warning condition remains active.

![Hardware Test – DKPS 0101](code/mp1/part1/0101.jpeg)

**Expected behaviour:** Warning light ON.

**Observed behaviour:** The warning LED turned ON as expected.

---

### Test 3 – DKPS = `0110`

This condition represents:

- Door open
- Key inserted
- Person seated
- Seat belt not fastened

Both the door-warning and seat-belt-warning conditions are active.

![Hardware Test – DKPS 0110](code/mp1/part1/0110.jpeg)

**Expected behaviour:** Warning light ON.

**Observed behaviour:** The warning LED turned ON as expected.

---

### Test 4 – DKPS = `0111`

This condition represents:

- Door open
- Key inserted
- Person seated
- Seat belt fastened

The seat-belt warning is inactive because the belt is fastened, but the door warning remains active.

![Hardware Test – DKPS 0111](code/mp1/part1/0111.jpeg)

**Expected behaviour:** Warning light ON.

**Observed behaviour:** The warning LED remained ON as expected.

---

### Test 5 – DKPS = `1110`

This condition represents:

- Door closed
- Key inserted
- Person seated
- Seat belt not fastened

The door warning is inactive, while the seat-belt warning is active.

![Hardware Test – DKPS 1110](code/mp1/part1/1110.jpeg)

**Expected behaviour:** Warning light ON.

**Observed behaviour:** The warning LED turned ON as expected.

---

### Test 6 – No Warning Condition

The condition `1111` represents:

- Door closed
- Key inserted
- Person seated
- Seat belt fastened

Neither warning condition is active.

![Hardware Test – No Warning](code/mp1/part1/1111(all_other_conditions_no_light).jpeg)

**Expected behaviour:** Warning light OFF.

**Observed behaviour:** The warning LED remained OFF as expected.

The same behaviour is expected for all other combinations where neither warning condition is active.

---

### Part 1 Hardware Testing Issue

One issue initially occurred when interpreting the four physical switches.

The VHDL input order is:

```text
D K P S
```

However, when viewing the four Basys3 switches physically from left to right, they appear as:

```text
SW3 SW2 SW1 SW0
 S   P   K   D
```

Therefore, reading the switches from left to right as `D K P S` resulted in apparently incorrect test conditions.

After using the actual switch labels, the hardware behaviour matched the simulation.

---

# Part 2 Hardware

### Elaborated Design

The Part 2 elaborated schematic shows two separate internal warning paths.

The door-warning logic implements:

```text
key_in AND NOT(door_closed)
```

The seat-belt-warning logic implements:

```text
key_in AND seat_pressure AND NOT(seat_belt_closed)
```

The resulting warning signals feed both the main warning output and the STATUS logic.

![Part 2 Elaborated Design](code/mp1/part2/elaborated_design_schematic.jpg)

---

### Synthesized Design

Vivado maps the VHDL logic to FPGA LUT resources.

The synthesized design includes input buffers, LUTs that generate the warning outputs, and output buffers connected to the FPGA pins.

![Part 2 Synthesized Design](code/mp1/part2/synthesized_design_schematic.jpg)

---

### Resource Utilization

The Part 2 design remains very small even after adding the STATUS output.

| Resource | Used |
|---|---:|
| Slice LUTs | 2 |
| Bonded I/O | 7 |

The seven I/O connections consist of:

```text
4 input switches + 3 output LEDs = 7 I/O
```

![Part 2 Resource Utilization](code/mp1/part2/utilization.jpg)

---

## Part 2 Hardware Testing

### Test 1 – No Warning: DKPS = `1101`

This condition represents:

- Door closed
- Key inserted
- Seat empty
- Seat belt fastened

Neither warning condition is active.

![Part 2 Hardware Test – No Warning](code/mp1/part2/1101.jpeg)

Expected output:

```text
STATUS = 00

LED2 = OFF
LED1 = OFF
LED0 = OFF
```

**Observed behaviour:** All three warning LEDs remained OFF, matching the expected `STATUS = 00`.

---

### Test 2 – Door Warning Only: DKPS = `0101`

This condition represents:

- Door open
- Key inserted
- Seat empty
- Seat belt fastened

Only the door-warning condition is active.

![Part 2 Hardware Test – Door Warning](code/mp1/part2/0101.jpeg)

Expected output:

```text
STATUS = 01

LED2 = OFF
LED1 = ON
LED0 = ON
```

**Observed behaviour:** LED1 and the general warning LED turned ON, while LED2 remained OFF. This correctly represents `STATUS = 01`.

---

### Test 3 – Seat-Belt Warning Only: DKPS = `1110`

This condition represents:

- Door closed
- Key inserted
- Person seated
- Seat belt not fastened

Only the seat-belt-warning condition is active.

![Part 2 Hardware Test – Seat-Belt Warning](code/mp1/part2/1110.jpeg)

Expected output:

```text
STATUS = 10

LED2 = ON
LED1 = OFF
LED0 = ON
```

**Observed behaviour:** LED2 and the general warning LED turned ON, while LED1 remained OFF. This correctly represents `STATUS = 10`.

---

### Test 4 – Both Warnings: DKPS = `0110`

This condition represents:

- Door open
- Key inserted
- Person seated
- Seat belt not fastened

Both warning conditions are active simultaneously.

![Part 2 Hardware Test – Both Warnings](code/mp1/part2/0110.jpeg)

Expected output:

```text
STATUS = 11

LED2 = ON
LED1 = ON
LED0 = ON
```

**Observed behaviour:** LED0, LED1, and LED2 all turned ON. This correctly represents `STATUS = 11`, confirming that both warning conditions were detected simultaneously.

The Part 2 hardware results matched the simulation for all four possible STATUS values.

---

## 6. Reflection

This project demonstrated the complete FPGA development process, beginning with a written system specification and ending with a functioning hardware implementation on the Basys3 board.

One of the first challenges was translating the real-world warning requirements into Boolean logic. Because `door_closed` and `seat_belt_closed` are active-high signals, detecting an open door or an unfastened seat belt required the use of the `NOT` operator.

Another challenge occurred during physical FPGA testing. Some input combinations initially appeared to produce incorrect results even though the simulation was correct. The problem was caused by interpreting the physical switch order incorrectly. The VHDL logic uses the order `D K P S`, while the Basys3 switches appear physically from left to right as `S P K D`. After using the correct switch labels, the hardware results matched the simulation.

Part 2 demonstrated how an existing design can be extended without removing its original functionality. The two warning conditions were separated into internal signals and used to generate the two-bit STATUS output. This allowed the system to distinguish between a door warning, a seat-belt warning, both warnings, and no warning.

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
- XDC pin constraints
- Resource utilization
- Bitstream generation
- Basys3 hardware testing
- Debugging differences between simulation and physical hardware

The project reinforced the relationship between digital-design theory and FPGA implementation. The Boolean expressions written in VHDL were first represented as RTL logic during elaboration and were then optimized into LUT resources during synthesis. Simulation verified the design before programming the FPGA, while hardware testing confirmed that the physical implementation behaved according to the intended logic.
