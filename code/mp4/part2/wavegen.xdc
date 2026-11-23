## Mini Project 4 - Part II: Multiple Waveforms (Basys3)
## Clock: 100 MHz
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clock]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clock]

## Enable: SW0
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports enable]

## Select waveform: SW1=wave_sel[0], SW2=wave_sel[1]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {wave_sel[0]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {wave_sel[1]}]

## Reset: center pushbutton (BTNC)
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports reset]

## Pmod JA data bus, D0 (LSB) to D7 (MSB)
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {JA[0]}]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {JA[1]}]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {JA[2]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {JA[3]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {JA[4]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {JA[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {JA[6]}]
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {JA[7]}]

## Duplicate output to LEDs LD0 through LD7 (named sine_out by handout)
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {sine_out[0]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {sine_out[1]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {sine_out[2]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {sine_out[3]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {sine_out[4]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {sine_out[5]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {sine_out[6]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {sine_out[7]}]
