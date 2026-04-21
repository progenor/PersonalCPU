set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { clk_in }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk_in }];

set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports { reset }];
set_property -dict { PACKAGE_PIN M20 IOSTANDARD LVCMOS33 } [get_ports { LEDsw }];

set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN N16 IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { led[3] }];

set_property -dict { PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { psdata }];
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 PULLUP true } [get_ports { psclock }];

set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[0] }];
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[1] }];
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[2] }];
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[3] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[4] }];
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[5] }];
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[6] }];
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports { lcd_data[7] }];

set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { lcd_control[0] }];
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { lcd_control[1] }];
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { lcd_control[2] }];

set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { test_clk }];