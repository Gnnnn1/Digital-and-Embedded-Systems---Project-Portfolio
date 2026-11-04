## Basys3 pin constraints for Stepper_Controller.vhd
## 100 MHz oscillator
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## SW0 direction, SW1 enable
set_property PACKAGE_PIN V17 [get_ports dir]
set_property IOSTANDARD LVCMOS33 [get_ports dir]
set_property PACKAGE_PIN V16 [get_ports en]
set_property IOSTANDARD LVCMOS33 [get_ports en]

## Center button (active HIGH)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## PMOD JA: outputs to ULN2003 IN1..IN4 (D, C, B, A)
set_property PACKAGE_PIN J1 [get_ports {q[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[0]}]
set_property PACKAGE_PIN L2 [get_ports {q[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[1]}]
set_property PACKAGE_PIN J2 [get_ports {q[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[2]}]
set_property PACKAGE_PIN G2 [get_ports {q[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[3]}]
