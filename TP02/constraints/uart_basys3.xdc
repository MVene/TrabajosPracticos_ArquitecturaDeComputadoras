## Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports i_clk]

## Reset - BTNC
set_property PACKAGE_PIN U18 [get_ports i_rst]
set_property IOSTANDARD LVCMOS33 [get_ports i_rst]

## UART USB-RS232 Basys 3

## PC -> FPGA
set_property PACKAGE_PIN B18 [get_ports i_rx]
set_property IOSTANDARD LVCMOS33 [get_ports i_rx]

## FPGA -> PC
set_property PACKAGE_PIN A18 [get_ports o_tx]
set_property IOSTANDARD LVCMOS33 [get_ports o_tx]

## LEDs resultado ALU (8 bits)

set_property PACKAGE_PIN U16 [get_ports {o_leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {o_leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {o_leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {o_leds[3]}]
set_property PACKAGE_PIN W18 [get_ports {o_leds[4]}]
set_property PACKAGE_PIN U15 [get_ports {o_leds[5]}]
set_property PACKAGE_PIN U14 [get_ports {o_leds[6]}]
set_property PACKAGE_PIN V14 [get_ports {o_leds[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_leds[*]}]

## Flags
## o_flags[0] = NEGATIVE
## o_flags[1] = ZERO
## o_flags[2] = CARRY

set_property PACKAGE_PIN L1 [get_ports {o_flags[0]}]
set_property PACKAGE_PIN P1 [get_ports {o_flags[1]}]
set_property PACKAGE_PIN N3 [get_ports {o_flags[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {o_flags[*]}]