---
layout: default
title: "Project 2: Event Counter"
---

# Project 2: Event Counter

## 1. Introduction

This project focuses on designing and implementing a 4-bit modulo-16 counter using VHDL on the Digilent Basys3 FPGA board. The project is divided into two parts: an automatic counter driven by a frequency-divided clock and a button-controlled event counter.

In **Part I**, the counter automatically increments using a 1 Hz clock derived from the FPGA's 100 MHz system clock. The count is displayed in hexadecimal (0–F) on the rightmost seven-segment display, while four onboard LEDs display the corresponding binary value.

In **Part II**, the automatic clock is replaced by a debounced push-button signal. Each valid button press increments the counter by one, while a separate button asynchronously resets the count to zero. The debounce module prevents mechanical button bouncing from causing multiple unwanted increments.

The main objectives are to:

- Design and implement sequential circuits using VHDL.
- Develop a configurable frequency divider and modulo-16 counter.
- Implement a hexadecimal-to-seven-segment decoder.
- Integrate button debouncing to detect individual button events.
- Verify functionality using Vivado Behavioral Simulation.
- Synthesize, implement, and test the design on the Basys3 FPGA board.

## 2. Design

The system uses a structural VHDL design that connects multiple functional modules.

### Part I: Automatic Counter

The automatic counter consists of three main components:

**1. Clock Divider (`clk_div.vhd`)**

The Basys3 board provides a 100 MHz system clock. The clock divider reduces this frequency to 1 Hz, allowing the count to increment at a rate observable on the seven-segment display.

The required count value is calculated using:

\[
MAX\_COUNT = \frac{f_{in}}{2f_{out}} - 1
\]

For a 100 MHz input and a 1 Hz output:

\[
MAX\_COUNT = \frac{100,000,000}{2(1)} - 1 = 49,999,999
\]

The divided clock toggles every 50 million input clock cycles.

**2. Modulo-16 Counter (`modMCounter.vhd`)**

The counter uses a 4-bit unsigned register that increments on each rising edge of the input clock.

Since the counter has four bits:

\[
M = 2^4 = 16
\]

The output cycles through hexadecimal values 0 to F before returning to 0. An asynchronous, active-high reset clears the count immediately.

**3. Hexadecimal-to-Seven-Segment Decoder (`hex_7seg.vhd`)**

The decoder converts the 4-bit count into a seven-segment display pattern using a combinational `case` statement.

The Basys3 display uses active-low signals, meaning a logic 0 turns a segment ON and a logic 1 turns it OFF.

The anode signal is assigned `1110` to activate only the rightmost digit.

**Part I Block Diagram**

![Part I Block Diagram](images/part1_block_diagram.png)

*Figure 1. Block diagram showing the clock divider, modulo-16 counter, hexadecimal decoder, LEDs, and reset connection.*

### Part II: Button Event Counter

Part II modifies the design to increment only when a push button is pressed.

The clock divider is replaced by the provided `button_debounce.vhd` module, while the modulo-16 counter and hexadecimal decoder are reused without modification.

**1. Button Debounce Module (`button_debounce.vhd`)**

Mechanical push buttons may produce rapid unwanted transitions when pressed or released.

The debounce module synchronizes the button input to the 100 MHz system clock and checks whether the input remains stable before accepting a new state.

The hardware debounce interval is:

\[
T = \frac{2,000,000}{100,000,000} = 20\text{ ms}
\]

After the button remains stable for the required interval, the module updates its debounced output.

**2. Button-Controlled Counter**

The debounced button output replaces the 1 Hz clock input to the modulo-16 counter.

Each rising edge of the debounced signal increments the counter once. Holding the button does not repeatedly increment the counter because no additional rising edges occur.

**3. Reset and Display**

Two push buttons are used:

- **BTNU:** Increment the counter.
- **BTNC:** Reset the counter to zero.

The count continues to be displayed on the rightmost seven-segment digit and the first four onboard LEDs.

**Part II Block Diagram**

![Part II Block Diagram](images/part2_block_diagram.png)

*Figure 2. Block diagram showing the button debounce module connected to the modulo-16 counter and display outputs.*

## 3. Code

The project is developed using VHDL in Xilinx Vivado 2019.2.

### Part I: Clock Divider

The clock divider generates the slower clock by counting rising edges of the 100 MHz input clock.

```vhdl
elsif rising_edge(clk_in) then
    if count = MAX_COUNT then
        count := 0;
        clk_sig <= not clk_sig;
    else
        count := count + 1;
    end if;
end if;
```

The output changes state when the maximum count is reached.

### Modulo-16 Counter

The counter uses the `unsigned` datatype from the `numeric_std` library to perform binary arithmetic.

```vhdl
process(clk, reset)
begin
    if reset = '1' then
        count_reg <= (others => '0');

    elsif rising_edge(clk) then
        count_reg <= count_reg + 1;
    end if;
end process;

count <= std_logic_vector(count_reg);
```

The reset is asynchronous, allowing the counter to clear independently of the clock.

The four-bit register automatically wraps from 15 to 0 due to its limited width.

### Hexadecimal-to-Seven-Segment Decoder

The decoder uses a `case` statement to convert each hexadecimal value into the required seven-segment pattern.

```vhdl
process(hexdigit)
begin
    case hexdigit is
        when "0000" => seg <= "1000000"; -- 0
        when "0001" => seg <= "1111001"; -- 1
        when "0010" => seg <= "0100100"; -- 2
        when "0011" => seg <= "0110000"; -- 3
        -- Remaining hexadecimal values
        when "1111" => seg <= "0001110"; -- F
        when others => seg <= "1111111";
    end case;
end process;
```

This is combinational logic because the output depends only on the current hexadecimal input.

### Part II: Button Debouncing

The provided debounce module checks whether the synchronized button input differs from the previously accepted state.

```vhdl
if btn2 = btn_stable then
    count <= 0;
else
    if count < STABLE_CYCLES - 1 then
        count <= count + 1;
    else
        btn_stable <= btn2;
        count <= 0;
    end if;
end if;
```

When the input remains stable for the specified number of clock cycles, the accepted button state is updated.

The default hardware debounce interval is 20 ms. A smaller generic value of 4 cycles is used in the testbench to accelerate simulation.

### Part II: Top-Level Integration

The top-level design connects the debounced button output directly to the counter's clock input.

```vhdl
U1: entity work.button_debounce
    generic map (
        STABLE_CYCLES => DEBOUNCE_CYCLES
    )
    port map (
        clk_in => clock,
        reset  => btn_reset,
        btn_in => btn_count,
        btn_db => btn_db_sig
    );

U2: entity work.modMCounter
    generic map (
        N => 4
    )
    port map (
        clk   => btn_db_sig,
        reset => btn_reset,
        count => count_sig
    );
```

The counter output is connected to the decoder and LEDs, allowing the same display design to be reused.

### Design Files

**Part I — Automatic Counter**

- [Clock Divider](Part1/clk_div.vhd)
- [Modulo-16 Counter](Part1/modMCounter.vhd)
- [Seven-Segment Decoder](Part1/hex_7seg.vhd)
- [Top-Level Design](Part1/count_display.vhd)
- [Clock Divider Testbench](Part1/clk_div_tb.vhd)
- [Counter Testbench](Part1/modMCounter_tb.vhd)
- [Top-Level Testbench](Part1/count_display_tb.vhd)
- [Constraints (XDC)](Part1/lab7.xdc)

**Part II — Button Event Counter**

- [Button Debounce Module](Part2/button_debounce.vhd)
- [Top-Level Design](Part2/count_display.vhd)
- [Modulo-16 Counter](Part2/modMCounter.vhd)
- [Seven-Segment Decoder](Part2/hex_7seg.vhd)
- [Testbench](Part2/count_display_tb.vhd)
- [Constraints (XDC)](Part2/lab7.xdc)

*Note: Update these relative links to match the final GitHub repository folder structure.*

## 4. Simulation

Behavioral simulations were performed in Vivado to verify the functional operation of the modules and their integration.

### Part I: Clock Divider Simulation

**Test:** Verify that the clock divider generates a slower clock signal from the input clock.

**Expected Behaviour:** The output clock should toggle periodically according to the configured division ratio.

**Observed Results:** The simulation showed a periodically toggling output clock after an initially flat waveform. The initial observation window was too short to display the divided clock transitions.

![Clock Divider Simulation](images/part1_clk_div_sim.png)

*Figure 3. Clock divider waveform showing the slower output clock.*

### Part I: Modulo-16 Counter Simulation

**Test:** Verify that the four-bit counter increments sequentially and wraps around after hexadecimal F.

**Expected Behaviour:**

The count should follow:

`0 → 1 → 2 → ... → E → F → 0`

**Observed Results:** The counter simulation showed the expected four-bit binary counting sequence. The individual output bits changed at the appropriate binary counting intervals.

![Modulo-16 Counter Simulation](images/part1_modcounter_sim.png)

*Figure 4. Four-bit modulo-16 counter simulation.*

### Part I: Top-Level Simulation

**Test:** Verify the integration of the clock divider, modulo-16 counter, LED outputs, and seven-segment decoder.

**Expected Behaviour:** The count should increment automatically on rising edges of the divided clock, with the binary LED and hexadecimal display outputs updating accordingly.

**Observed Results:** The top-level simulation showed the count advancing from 0 to 1 and 2. The seven-segment output changed from `40` to `79` and `24` in hexadecimal, corresponding to digits 0, 1, and 2.

The anode output remained `1110`, selecting the rightmost digit.

![Part I Top-Level Simulation](images/part1_top_sim.png)

*Figure 5. Automatic counter simulation showing synchronized count, LED, and seven-segment outputs.*

### Part II: Button Event Counter Simulation

The testbench simulated multiple button presses, a short invalid pulse, a held button, modulo-16 wraparound, and asynchronous reset.

The simulation used `DEBOUNCE_CYCLES = 4` to reduce the simulation time while maintaining the functional debounce logic.

| Test Scenario | Expected Behaviour | Observed Result |
|---|---|---|
| Initial reset | Counter starts at 0 | Counter displayed 0 |
| Short button pulse | Invalid pulse is rejected | No count increment |
| Multiple button presses | Increment once per valid press | Counter advanced sequentially |
| Button held down | Only one increment occurs | Count remained unchanged during the hold |
| Modulo-16 wraparound | F returns to 0 | Counter wrapped from F to 0 |
| Asynchronous reset | Counter immediately returns to 0 | Counter returned to 0 |
| Counting after reset | New press increments to 1 | Counter incremented to 1 |
| Seven-segment decoding | Display corresponds to count | Display outputs matched hexadecimal values |

**Observed Results:**

The final simulation showed the count progressing through the full hexadecimal sequence from 0 to F and returning to 0.

The seven-segment output changed accordingly, and the counter remained constant when the button was held.

The reset test also showed the counter returning to zero and responding correctly to subsequent button presses.

![Part II Button Event Simulation](images/part2_button_sim.png)

*Figure 6. Final Part II simulation showing multiple button events, counter progression, wraparound, and reset.*

### Simulation Challenges and Resolution

During initial Part II simulations, the button input pulses were visible, but the debounced output remained low and the counter did not increment.

The issue was traced to the debounce configuration. The hardware debounce value was too large for the short simulated button presses.

To resolve this, a configurable `DEBOUNCE_CYCLES` generic was added to the top-level module. The testbench used a reduced value of 4, while the hardware design retained the default value of 2,000,000.

After the correction, the simulated counter advanced correctly in response to button presses.

## 5. Hardware

### 5.1 Elaborated Design

The elaborated schematic illustrates the structural VHDL architecture and the connections between the functional modules.

**Part I:**

The clock divider output is connected to the modulo-16 counter, which drives both the LEDs and the seven-segment decoder.

![Part I Elaborated Schematic](images/part1_elaborated.png)

*Figure 7. Elaborated schematic for the automatic counter.*

**Part II:**

The clock divider is replaced by the button debounce module. The debounced output drives the counter clock input, while the reset button is connected to both the debouncer and counter.

![Part II Elaborated Schematic](images/part2_elaborated.png)

*Figure 8. Elaborated schematic showing the button debounce module, modulo-16 counter, and seven-segment display connections.*

The elaborated design confirmed the intended module interconnections and signal routing.

### 5.2 Synthesized Design

Vivado synthesis converts the VHDL design into a hardware representation using FPGA-compatible logic.

The synthesized Part II schematic includes:

- Input buffers (`IBUF`) for push-button signals.
- An input buffer and global clock buffer (`BUFG`) for the 100 MHz system clock.
- Counter and button debounce logic.
- Output buffers (`OBUF`) for the LEDs, seven-segment outputs, and anodes.

![Part II Synthesized Schematic](images/part2_synthesized.png)

*Figure 9. Synthesized schematic showing the counter and debounce logic with FPGA input/output buffers.*

The synthesized schematic was consistent with the intended design structure.

### 5.3 Implementation

The implementation process maps the synthesized logic onto the physical resources of the Artix-7 FPGA.

Vivado's Device view was used to inspect the placement of the design within the FPGA fabric.

![Part II Implementation](images/part2_implementation.png)

*Figure 10. FPGA Device view showing the implemented design.*

The Device view showed logic resources placed within the FPGA fabric.

### 5.4 Resource Utilization

The design uses FPGA resources for the counter, button debouncer, logic decoding, and input/output connections.

The following table should be completed using the **Vivado Utilization Report**.

| Resource | Part I Used | Part II Used |
|---|---|---|
| Slice LUTs | TBD | TBD |
| Slice Registers | TBD | TBD |
| F7/F8 Muxes | TBD | TBD |
| Bonded IOBs | TBD | TBD |
| BUFG/BUFGCTRL | TBD | TBD |

![Resource Utilization Report](images/utilization.png)

*Figure 11. Vivado resource utilization summary.*

The two designs use different clock-control mechanisms. Part I requires a frequency-divider counter, whereas Part II requires synchronization and debounce logic.

### 5.5 Hardware Testing

The design targets the Digilent Basys3 FPGA board.

For Part I, the expected hardware behaviour is an automatic hexadecimal count from 0 to F, with the four LEDs displaying the corresponding binary values.

For Part II, the expected hardware behaviour is:

| Test | Expected Result |
|---|---|
| Press BTNU once | Counter increments by one |
| Hold BTNU | Counter increments only once |
| Release and press BTNU again | Counter increments again |
| Reach F and press BTNU | Counter wraps to 0 |
| Press BTNC | Counter resets to 0 |
| Observe LED0–LED3 | LEDs display binary count |

The following photographs or video evidence can be included after hardware testing.

![Basys3 Hardware Test](images/part2_hardware.png)

*Figure 12. Basys3 board displaying the counter output during physical testing.*

**Hardware observation:** [Insert the actual observed results after programming and testing the FPGA.]

## 6. Reflection

This project provided practical experience in designing and integrating sequential and combinational digital circuits using VHDL.

One important concept was frequency division. In Part I, the 100 MHz system clock needed to be reduced to a much slower frequency for observable counting. Implementing the clock divider helped reinforce the relationship between clock frequency, counter size, and output timing.

The modulo-16 counter demonstrated binary arithmetic, register-based sequential logic, and asynchronous reset behaviour. The hexadecimal decoder also reinforced the use of truth tables and combinational logic.

Part II introduced additional challenges related to mechanical push-button inputs. Unlike an ideal digital signal, a physical button may produce unwanted transitions. Using a debounce module allowed the design to recognize a valid button event without counting multiple times for a single press.

A significant challenge occurred during simulation when the counter initially remained at zero despite the button input changing. This was resolved by adjusting the debounce configuration for simulation while preserving the intended hardware timing.

Another important lesson was distinguishing between simulation and physical FPGA operation. Simulation allowed the behaviour of individual modules and the integrated design to be observed before hardware implementation.

The project also provided experience with the Vivado workflow, including behavioral simulation, RTL elaboration, synthesis, FPGA implementation, constraints configuration, and bitstream preparation.

Overall, this project strengthened my understanding of sequential circuits, clocking, digital input conditioning, modular VHDL design, and FPGA-based hardware development. It demonstrated how reusable VHDL modules can be combined and modified to implement different digital systems with minimal changes to their underlying components.
