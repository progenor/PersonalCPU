# Clock
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

# LEDs
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L6N_T0_VREF_34 Sch=led[0]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L6P_T0_34 Sch=led[1]
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L21N_T3_DQS_AD14N_35 Sch=led[2]
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L23P_T3_35 Sch=led[3]   

# Buttons (Note: VHDL uses btn[0] for the CPU interrupt)
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; #IO_L4P_T0_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; #IO_L4N_T0_35 Sch=btn[1]
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; #IO_L9N_T1_DQS_AD3N_35 Sch=btn[2]
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; #IO_L9P_T1_DQS_AD3P_35 Sch=btn[3]  

# Switches
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { LEDsw }]; #IO_L7N_T1_AD2N_35 Sch=sw[0] (UNUSED)
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { reset }]; #IO_L7P_T1_AD2P_35 Sch=sw[1] (Moved reset here)

# PmodA - Digilent PmodCLP LCD Data Bus (8-bit)
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { Db[0] }]; #IO_L17P_T2_34 Sch=ja_p[1]
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { Db[1] }]; #IO_L17N_T2_34 Sch=ja_n[1]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { Db[2] }]; #IO_L7P_T1_34 Sch=ja_p[2]
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { Db[3] }]; #IO_L7N_T1_34 Sch=ja_n[2]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { Db[4] }]; #IO_L12P_T1_MRCC_34 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { Db[5] }]; #IO_L12N_T1_MRCC_34 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { Db[6] }]; #IO_L22P_T3_34 Sch=ja_p[4]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { Db[7] }]; #IO_L22N_T3_34 Sch=ja_n[4]

# PmodB - Digilent PS2 Pmod + LCD Control Signals
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { psdata }];  #IO_L8P_T1_34 Sch=jb_p[1] PS2_DATA
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { psclock }]; #IO_L1P_T0_34 Sch=jb_p[2] PS2_CLK

# LCD Control Signals on PmodB
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { Rs }]; #IO_L18P_T2_34 Sch=jb_p[3] LCD_RS
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { Rw }]; #IO_L18N_T2_34 Sch=jb_n[3] LCD_RW
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { E }];  #IO_L4P_T0_34 Sch=jb_p[4] LCD_E

# PmodC - UART
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports { uart_tx }]; #IO_L6P_T0_34 Sch=jc_p[1] UART_TX
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { uart_rx }]; #IO_L6N_T0_VREF_34 Sch=jc_n[1] UART_RX