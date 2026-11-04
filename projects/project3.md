---
layout: default
title: Project 3
---

# Project 3: Stepper Motor Control

## 1. Introduction

This project implements a **finite state machine (FSM) stepper motor controller** in VHDL using the **Digilent Basys3 FPGA** and Xilinx Vivado. The controller generates a four-bit coil-excitation sequence, with user inputs to enable the motor and select its rotation direction.

The project consists of two parts:

- **Part I — FSM design and simulation:** Develop a five-state stepper motor sequencer and verify its state transitions using a VHDL testbench.
- **Part II — FPGA controller integration:** Connect the FSM to a clock divider, assign the Basys3 pins, and prepare the design to drive a stepper motor through a ULN2003 driver.

The main objectives were to implement a direction-controlled FSM, verify clockwise and counterclockwise output sequences, add enable and reset functions, and integrate a **100 MHz-to-500 Hz clock divider** for FPGA operation.

## 2. Design

### 2.1 System architecture

The top-level module, `Stepper_Controller`, contains two principal components: a clock divider and a stepper motor FSM. The Basys3's 100 MHz clock is divided to 500 Hz and supplied to the FSM. At each rising edge of the divided clock, the FSM advances one step when enabled. The `dir` input determines the sequence direction, and `reset` initializes the controller.

**Figure 1. Labelled block diagram of the stepper motor controller.**

```text
 Basys3 100 MHz clock
          |
          v
  +-------------------+
  | Clock Divider     |<--------- reset (BTN Center)
  | clk_div           |
  | 100 MHz -> 500 Hz |
  +-------------------+
          |
       slow_clk
          |
          v
  +------------------------+
  | Stepper Motor FSM      |<--- dir (SW0)
  | S0, S1, S2, S3, S4    |<--- en  (SW1)
  |                        |<--- reset (BTN Center)
  +------------------------+
          |
       q[3:0]
          |
          v
   Basys3 PMOD JA1-JA4
          |
          v
   ULN2003 Motor Driver
          |
          v
       Stepper Motor
```

### 2.2 FSM operation

The controller uses **wave drive**, energizing one motor coil at a time. There are five states: one idle state and four active coil states.

| State | `q[3:0]` | Function |
|:---:|:---:|---|
| S0 | `0000` | Idle; all coils off |
| S1 | `0001` | Energize coil D (`q[0]`) |
| S2 | `0010` | Energize coil C (`q[1]`) |
| S3 | `0100` | Energize coil B (`q[2]`) |
| S4 | `1000` | Energize coil A (`q[3]`) |

When `en = '1'`, the states progress in the selected direction:

- **Clockwise (`dir = '1'`):** S1 → S2 → S3 → S4 → S1 (repeat).
- **Counterclockwise (`dir = '0'`):** S4 → S3 → S2 → S1 → S4 (repeat).
- **Disabled (`en = '0'`):** The FSM returns to S0 on the next active clock edge.
- **Reset (Part II):** The updated FSM immediately returns to S0 when reset is asserted.

### 2.3 Step frequency

The clock divider converts the **100 MHz** FPGA oscillator into a **500 Hz** stepping clock:

\[
T_{step}=\frac{1}{500\ \mathrm{Hz}}=2\ \mathrm{ms}
\]

Thus, the controller commands **500 steps per second**, assuming each rising edge produces one state transition. A complete four-pattern electrical sequence takes **8 ms**. Actual mechanical speed depends on the motor's internal step angle, gear ratio, and ability to follow the commanded steps.

## 3. Code

### 3.1 Part I — Stepper motor FSM

The `stepper_motor_FSM.vhd` design defines the five states and uses a clocked process to update the current state according to `en` and `dir`. A separate output decoder maps the current state to the four-bit coil pattern. This makes the design a **Moore FSM**, because the output depends on the current state.

Example state-transition logic:

```vhdl
if rising_edge(clk) then
    if en = '0' then
        state <= S0;
    elsif dir = '1' then
        case state is
            when S0 => state <= S1;
            when S1 => state <= S2;
            when S2 => state <= S3;
            when S3 => state <= S4;
            when S4 => state <= S1;
        end case;
    else
        case state is
            when S0 => state <= S4;
            when S1 => state <= S4;
            when S2 => state <= S1;
            when S3 => state <= S2;
            when S4 => state <= S3;
        end case;
    end if;
end if;
```

The output decoder is:

```vhdl
with state select
    q <= "0000" when S0,
         "0001" when S1,
         "0010" when S2,
         "0100" when S3,
         "1000" when S4;
```

**Part I files:**

- **Design source:** [stepper_motor_FSM.vhd](../code/mp3/part1/stepper_motor_FSM.vhd)
- **Testbench:** [stepper_motor_FSM_tb.vhd](../code/mp3/part1/stepper_motor_FSM_tb.vhd)
- **Constraints (XDC):** [stepper_m.xdc](../code/mp3/part1/stepper_m.xdc)

### 3.2 Part II — FPGA top-level controller

Part II adds the `clk_div` component and a top-level module named `Stepper_Controller`. The clock divider receives the Basys3's 100 MHz system clock and produces `slow_clk` at 500 Hz. The updated FSM receives the slow clock, direction, enable, and reset signals.

Key instantiations in the top-level module:

```vhdl
U_CLK_DIV : entity work.clk_div
    generic map (
        clk_in_freq  => 100_000_000,
        clk_out_freq => 500
    )
    port map (
        reset   => reset,
        clk_in  => clk,
        clk_out => slow_clk
    );

U_STEPPER_FSM : entity work.stepper_motor_FSM
    port map (
        clk   => slow_clk,
        reset => reset,
        en    => en,
        dir   => dir,
        q     => q
    );
```

Reset was added to the Part II FSM interface to match the assignment's block diagram and allow the FPGA's center button to initialize the controller.

**Part II files:**

- **Top-level design source:** [Stepper_Controller.vhd](../code/mp3/part2/Stepper_Controller.vhd)
- **Clock divider:** [clk_div.vhd](../code/mp3/part2/clk_div.vhd)
- **Clock divider testbench:** [clk_div_tb.vhd](../code/mp3/part2/clk_div_tb.vhd)
- **FSM design source (with reset):** [stepper_motor_FSM.vhd](../code/mp3/part2/stepper_motor_FSM.vhd)
- **FSM testbench:** [stepper_motor_FSM_tb.vhd](../code/mp3/part2/stepper_motor_FSM_tb.vhd)
- **Constraints (XDC):** [stepper_m.xdc](../code/mp3/part2/stepper_m.xdc)

## 4. Simulation

### 4.1 Behavioral simulation — Part I

The FSM was tested in **Vivado Behavioral Simulation** with a **10 µs testbench clock**. This shorter simulation clock was used to observe transitions efficiently; the physical FPGA design uses the 500 Hz divided clock.

**Figure 2. Part I FSM simulation waveforms showing `clk`, `dir`, `en`, `q[3:0]`, and the internal state.**

![Part I behavioral simulation of stepper motor FSM](../code/mp3/part1/simulation_waveforms.jpg)

The simulation covered the required four steps in each direction, as well as extra enable and direction-control checks.

| Scenario | Input conditions | Expected output sequence | Observed result |
|---|---|---|---|
| Initial idle | `en = 0` | `0000` (S0) | S0 observed |
| Clockwise stepping | `en = 1`, `dir = 1` | `0001 → 0010 → 0100 → 1000` | Correct S1 → S2 → S3 → S4 transitions |
| Reverse direction | `en = 1`, `dir = 0` | `0100 → 0010 → 0001 → 1000` | Correct S3 → S2 → S1 → S4 transitions |
| Disable | `en = 0` | `0000` after next rising clock edge | Returned to S0 |
| Restart in reverse | `en = 1`, `dir = 0` | `1000` from idle | Correct S4 output |
| Change direction | `en = 1`, `dir = 1` | `0001` after S4 | Correct S1 output |
| Final disable | `en = 0` | `0000` | Returned to S0 |

The individual output bits also confirmed **one-hot coil activation**: exactly one of `q[3]`, `q[2]`, `q[1]`, and `q[0]` was high in each active state.

**Discrepancies and resolution:** The assignment's counterclockwise state table included an inconsistent S1 → S0 transition. To preserve a continuous reverse four-state sequence, the implementation follows the state diagram with **S1 → S4** for counterclockwise operation. The simulation waveform verifies this transition. Vivado initially displayed the four-bit bus in decimal (`0, 1, 2, 4, 8`); these correspond to the required binary patterns (`0000, 0001, 0010, 0100, 1000`).

### 4.2 Part II simulation scope

A separate top-level simulation was **not required** by the lab instructions. The verified FSM was reused with a slowed clock, and the clock divider and FSM were integrated into the top-level design for elaboration and synthesis. The relevant testbench files are linked in Section 3.

## 5. Hardware

### 5.1 Part I — Elaborated design

**Figure 3. Part I elaborated schematic of the standalone FSM.**

![Part I elaborated design schematic](../code/mp3/part1/elaborated_design_schematic.jpg)

The elaborated schematic shows the control inputs (`clk`, `dir`, `en`), a state register, state-transition logic, and the `q[3:0]` output decoder. It confirms the structural organization of the FSM before implementation on the FPGA.

### 5.2 Part II — Elaborated design

**Figure 4. Part II elaborated schematic of the complete stepper controller.**

![Part II elaborated controller schematic](../code/mp3/part2/elaborated_design.png)

The top-level schematic contains `U_CLK_DIV` and `U_STEPPER_FSM`. The divider's `clk_out` connects to the FSM clock. `reset` connects to both components, while `dir` and `en` control the FSM. The FSM produces the four output signals `q[3:0]`.

### 5.3 Part II — Synthesized design

**Figure 5. Part II synthesized schematic in Vivado.**

![Part II synthesized controller schematic](../code/mp3/part2/synthesized_design.png)

The synthesized schematic shows input buffers (`IBUF`), the system clock buffer (`BUFG`), the clock-divider and FSM blocks, and four output buffers (`OBUF`). These connections are consistent with the intended top-level architecture and confirm that Vivado synthesized the interconnected design. The schematic alone does not establish successful motor operation or quantify FPGA resource usage.

### 5.4 Constraints and FPGA connections

The Basys3 controls are assigned as follows:

| Signal | Basys3 interface | FPGA package pin |
|---|---|---|
| `clk` | 100 MHz onboard clock | W5 |
| `reset` | Center pushbutton | U18 |
| `dir` | Switch SW0 | V17 |
| `en` | Switch SW1 | V16 |
| `q[0]` (coil D) | PMOD JA1 | J1 |
| `q[1]` (coil C) | PMOD JA2 | L2 |
| `q[2]` (coil B) | PMOD JA3 | J2 |
| `q[3]` (coil A) | PMOD JA4 | G2 |

The four FPGA outputs are intended to connect to the **ULN2003 motor driver**, rather than directly to the motor coils. The motor requires an appropriate external supply and a common ground with the FPGA/driver interface. Actual wiring and motor operation will be documented during hardware testing.

### 5.5 Implementation

The design has been elaborated and synthesized, and the corresponding schematic screenshots are shown above. **Final implementation or bitstream-generation results have not been documented in the repository materials shown here.** Those results should be added after checking the Vivado implementation status, timing summary, and bitstream generation.


### 5.6 Physical FPGA testing — Pending

**Hardware testing has not yet been completed/documented.** After programming the Basys3 and connecting the motor driver, the following scenarios will be tested:

| Test condition | Expected behavior | Actual observation |
|---|---|---|
| `en = 0` | Motor coils disabled after next slow-clock edge | Pending |
| `en = 1`, `dir = 1` | Clockwise step sequence | Pending |
| `en = 1`, `dir = 0` | Counterclockwise step sequence | Pending |
| Press center reset | Outputs return to `0000` | Pending |
| Release reset with `en = 1` | Stepping resumes | Pending |

**Physical FPGA photograph/video:** To be added after hardware testing.

## 6. Reflection

This project demonstrated how a **finite state machine** can control a sequential electromechanical process. Designing the FSM separately from the clock divider made the system easier to understand, test, and reuse. The Part I waveform confirmed the expected state transitions for both directions, while the Part II schematics showed how separate VHDL modules can be integrated into a complete FPGA controller.

A key design challenge was translating the assignment's state diagram into consistent next-state logic, particularly where the counterclockwise state table contained an inconsistent transition. Following the complete reverse sequence and verifying each output with the testbench resolved that ambiguity. Another important concept was the distinction between a **simulation clock** (10 µs period for efficient verification) and the much slower **hardware stepping clock** (500 Hz) needed for motor control.

The project reinforced practical applications of **Moore FSMs, state registers, clock division, hierarchical VHDL design, testbench stimulus, pin constraints, elaboration, and synthesis**. The remaining step is to confirm the design through physical FPGA and motor testing and document any differences between simulated and real hardware behaviour.
