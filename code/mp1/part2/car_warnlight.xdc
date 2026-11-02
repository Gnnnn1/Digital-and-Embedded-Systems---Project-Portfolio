## =========================================================
## SWITCHES
## =========================================================

## SW0 - Door closed (D)
set_property PACKAGE_PIN V17 [get_ports door_closed]
set_property IOSTANDARD LVCMOS33 [get_ports door_closed]

## SW1 - Key inserted (K)
set_property PACKAGE_PIN V16 [get_ports key_in]
set_property IOSTANDARD LVCMOS33 [get_ports key_in]

## SW2 - Seat pressure / person seated (P)
set_property PACKAGE_PIN W16 [get_ports seat_pressure]
set_property IOSTANDARD LVCMOS33 [get_ports seat_pressure]

## SW3 - Seat belt fastened (S)
set_property PACKAGE_PIN W17 [get_ports seat_belt_closed]
set_property IOSTANDARD LVCMOS33 [get_ports seat_belt_closed]


## =========================================================
## LEDs
## =========================================================

## LED0 - Main warning light
set_property PACKAGE_PIN U16 [get_ports light_en]
set_property IOSTANDARD LVCMOS33 [get_ports light_en]

## LED1 - STATUS(0) - Door warning
set_property PACKAGE_PIN E19 [get_ports {STATUS[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {STATUS[0]}]

## LED2 - STATUS(1) - Seat-belt warning
set_property PACKAGE_PIN U19 [get_ports {STATUS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {STATUS[1]}]


## =========================================================
## CONFIGURATION
## =========================================================

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]