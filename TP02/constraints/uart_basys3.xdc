## Clock 100 MHz
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.0 -name sys_clk -waveform {0 5} [get_ports clk]

## Reset (BTNC)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## UART RX/TX
set_property PACKAGE_PIN V11 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property PACKAGE_PIN U12 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

## Switches (para operandos manuales)
set_property PACKAGE_PIN V17 [get_ports {i_sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {i_sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {i_sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {i_sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {i_sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {i_sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {i_sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {i_sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {i_sw[*]}]

## LEDs (resultado ALU)
set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]

## Flags (LD15–LD13)
set_property PACKAGE_PIN N3 [get_ports o_flags[0]]
set_property PACKAGE_PIN P1 [get_ports o_flags[1]]
set_property PACKAGE_PIN L1 [get_ports o_flags[2]]
set_property IOSTANDARD LVCMOS33 [get_ports {o_flags[*]}]
