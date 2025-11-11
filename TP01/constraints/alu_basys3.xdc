## ============================================================================
## Clock de 100 MHz (oscilador principal)
## ============================================================================
set_property PACKAGE_PIN W5 [get_ports { i_clk }]
set_property IOSTANDARD LVCMOS33 [get_ports { i_clk }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { i_clk }]

## ============================================================================
## Switches (SW0–SW7 → i_sw[7:0])
## ============================================================================
set_property PACKAGE_PIN V17 [get_ports { i_sw[0] }]
set_property PACKAGE_PIN V16 [get_ports { i_sw[1] }]
set_property PACKAGE_PIN W16 [get_ports { i_sw[2] }]
set_property PACKAGE_PIN W17 [get_ports { i_sw[3] }]
set_property PACKAGE_PIN W15 [get_ports { i_sw[4] }]
set_property PACKAGE_PIN V15 [get_ports { i_sw[5] }]
set_property PACKAGE_PIN W14 [get_ports { i_sw[6] }]
set_property PACKAGE_PIN W13 [get_ports { i_sw[7] }]
set_property IOSTANDARD LVCMOS33 [get_ports { i_sw[*] }]

## ============================================================================
## Botones (BTNC, BTNU, BTNL, BTNR → i_btn[0:3])
## ============================================================================
# i_btn[0] = BTNC (central) → carga A
set_property PACKAGE_PIN U18 [get_ports { i_btn[0] }]
# i_btn[1] = BTNU (arriba) → carga B
set_property PACKAGE_PIN T18 [get_ports { i_btn[1] }]
# i_btn[2] = BTNL (izquierda) → operación
set_property PACKAGE_PIN W19 [get_ports { i_btn[2] }]
# i_btn[3] = BTNR (derecha) → reset
set_property PACKAGE_PIN T17 [get_ports { i_btn[3] }]
set_property IOSTANDARD LVCMOS33 [get_ports { i_btn[*] }]

## ============================================================================
## LEDs (LD0–LD7 → o_led[7:0])
## ============================================================================
set_property PACKAGE_PIN U16 [get_ports { o_led[0] }]
set_property PACKAGE_PIN E19 [get_ports { o_led[1] }]
set_property PACKAGE_PIN U19 [get_ports { o_led[2] }]
set_property PACKAGE_PIN V19 [get_ports { o_led[3] }]
set_property PACKAGE_PIN W18 [get_ports { o_led[4] }]
set_property PACKAGE_PIN U15 [get_ports { o_led[5] }]
set_property PACKAGE_PIN U14 [get_ports { o_led[6] }]
set_property PACKAGE_PIN V14 [get_ports { o_led[7] }]
set_property IOSTANDARD LVCMOS33 [get_ports { o_led[*] }]

## ============================================================================
##  FLAGS-LEDS (LD15-LD13) -> o_flags[2:0]  o_flags[2] = 
## ============================================================================
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports o_flags[0]]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports o_flags[1]]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports o_flags[2]]
