
V
Command: %s
53*	vivadotcl2%
#write_bitstream -force toplevel.bitZ4-113h px� 

@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
Implementation2	
xc7z020Z17-347h px� 
o
0Got license for feature '%s' and/or device '%s'
310*common2
Implementation2	
xc7z020Z17-349h px� 
f
,Running DRC as a precondition to command %s
1349*	planAhead2
write_bitstreamZ12-1349h px� 
>
IP Catalog is up to date.1232*coregenZ19-1839h px� 
>
Running DRC with %s threads
24*drc2
2Z23-27h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_0[0]$processor/PFC_inst/phasenum_reg[1]_02^
 "Z
*processor/PFC_inst/Instr_code_reg[5]_i_2/O*processor/PFC_inst/Instr_code_reg[5]_i_2/O2Z
 "V
(processor/PFC_inst/Instr_code_reg[5]_i_2	(processor/PFC_inst/Instr_code_reg[5]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_1[0]$processor/PFC_inst/phasenum_reg[1]_12Z
 "V
(processor/PFC_inst/KK_const_reg[7]_i_2/O(processor/PFC_inst/KK_const_reg[7]_i_2/O2V
 "R
&processor/PFC_inst/KK_const_reg[7]_i_2	&processor/PFC_inst/KK_const_reg[7]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_2[0]$processor/PFC_inst/phasenum_reg[1]_22b
 "^
,processor/PFC_inst/Branch_Addr_reg[11]_i_2/O,processor/PFC_inst/Branch_Addr_reg[11]_i_2/O2^
 "Z
*processor/PFC_inst/Branch_Addr_reg[11]_i_2	*processor/PFC_inst/Branch_Addr_reg[11]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_3[0]$processor/PFC_inst/phasenum_reg[1]_32^
 "Z
*processor/PFC_inst/PortID_dir_reg[7]_i_2/O*processor/PFC_inst/PortID_dir_reg[7]_i_2/O2Z
 "V
(processor/PFC_inst/PortID_dir_reg[7]_i_2	(processor/PFC_inst/PortID_dir_reg[7]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_4[0]$processor/PFC_inst/phasenum_reg[1]_42b
 "^
,processor/PFC_inst/DMemAddr_dir_reg[5]_i_2/O,processor/PFC_inst/DMemAddr_dir_reg[5]_i_2/O2^
 "Z
*processor/PFC_inst/DMemAddr_dir_reg[5]_i_2	*processor/PFC_inst/DMemAddr_dir_reg[5]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_5[0]$processor/PFC_inst/phasenum_reg[1]_52X
 "T
'processor/PFC_inst/SY_Addr_reg[3]_i_2/O'processor/PFC_inst/SY_Addr_reg[3]_i_2/O2T
 "P
%processor/PFC_inst/SY_Addr_reg[3]_i_2	%processor/PFC_inst/SY_Addr_reg[3]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�Gated clock check: Net %s is a gated clock net sourced by a combinational pin %s, cell %s. This is not good design practice and will likely impact performance. For SLICE registers, for example, use the CE pin to control the loading of data.%s*DRC2U
 "Q
'processor/PFC_inst/phasenum_reg[1]_6[0]$processor/PFC_inst/phasenum_reg[1]_62X
 "T
'processor/PFC_inst/SX_Addr_reg[3]_i_2/O'processor/PFC_inst/SX_Addr_reg[3]_i_2/O2T
 "P
%processor/PFC_inst/SX_Addr_reg[3]_i_2	%processor/PFC_inst/SX_Addr_reg[3]_i_22+
 %DRC|Physical Configuration|Chip Level8ZPDRC-153h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2p
 "l
3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[10]3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[10]2
 "
mem/Q[6]mem/Q[6]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[6]	;processor/PFC_inst/programflowcontrol.programcounter_reg[6]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2p
 "l
3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[11]3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[11]2
 "
mem/Q[7]mem/Q[7]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[7]	;processor/PFC_inst/programflowcontrol.programcounter_reg[7]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2p
 "l
3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[12]3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[12]2
 "
mem/Q[8]mem/Q[8]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[8]	;processor/PFC_inst/programflowcontrol.programcounter_reg[8]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2p
 "l
3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[13]3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[13]2
 "
mem/Q[9]mem/Q[9]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[9]	;processor/PFC_inst/programflowcontrol.programcounter_reg[9]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2p
 "l
3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[14]3mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[14]2
 "
	mem/Q[10]	mem/Q[10]2�
 "~
<processor/PFC_inst/programflowcontrol.programcounter_reg[10]	<processor/PFC_inst/programflowcontrol.programcounter_reg[10]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[4]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[4]2
 "
mem/Q[0]mem/Q[0]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[0]	;processor/PFC_inst/programflowcontrol.programcounter_reg[0]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[5]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[5]2
 "
mem/Q[1]mem/Q[1]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[1]	;processor/PFC_inst/programflowcontrol.programcounter_reg[1]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[6]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[6]2
 "
mem/Q[2]mem/Q[2]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[2]	;processor/PFC_inst/programflowcontrol.programcounter_reg[2]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[7]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[7]2
 "
mem/Q[3]mem/Q[3]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[3]	;processor/PFC_inst/programflowcontrol.programcounter_reg[3]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[8]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[8]2
 "
mem/Q[4]mem/Q[4]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[4]	;processor/PFC_inst/programflowcontrol.programcounter_reg[4]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
�RAMB36 async control check: The RAMB36E1 %s has an input control pin %s (net: %s) which is driven by a register (%s) that has an active asychronous set or reset. This may cause corruption of the memory contents and/or read values when the set/reset is asserted and is not analyzed by the default static timing analysis. It is suggested to eliminate the use of a set/reset to registers driving this RAMB pin or else use a synchronous reset in which the assertion of the reset is timed by default.%s*DRC2P
 "L
#mem/ram_2k_generate.akv7.kcpsm6_rom	#mem/ram_2k_generate.akv7.kcpsm6_rom2n
 "j
2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[9]2mem/ram_2k_generate.akv7.kcpsm6_rom/ADDRARDADDR[9]2
 "
mem/Q[5]mem/Q[5]2�
 "|
;processor/PFC_inst/programflowcontrol.programcounter_reg[5]	;processor/PFC_inst/programflowcontrol.programcounter_reg[5]20
 *DRC|Netlist|Instance|Required Pin|RAMB36E18Z	REQP-1839h px� 
�
uPS7 block required: The PS7 cell must be used in this Zynq design in order to enable correct default configuration.%s*DRC2)
 #DRC|PS7|Zynq requires PS7 block|PS78ZZPS7-1h px� 
U
DRC finished with %s
1905*	planAhead2
0 Errors, 19 WarningsZ12-3199h px� 
i
BPlease refer to the DRC report (report_drc) for more information.
1906*	planAheadZ12-3200h px� 
W
)Running write_bitstream with %s threads.
1750*designutils2
2Z20-2272h px� 
?
Loading data files...
1271*designutilsZ12-1165h px� 
>
Loading site data...
1273*designutilsZ12-1167h px� 
?
Loading route data...
1272*designutilsZ12-1166h px� 
?
Processing options...
1362*designutilsZ12-1514h px� 
<
Creating bitmap...
1249*designutilsZ12-1141h px� 
7
Creating bitstream...
7*	bitstreamZ40-7h px� 
M
Writing bitstream %s...
11*	bitstream2
./toplevel.bitZ40-11h px� 
F
Bitgen Completed Successfully.
1606*	planAheadZ12-1842h px� 
�
�WebTalk data collection is mandatory when using a ULT device. To see the specific WebTalk data collected for your design, open the usage_statistics_webtalk.html or usage_statistics_webtalk.xml file in the implementation directory.698*projectZ1-1876h px� 
H
Releasing license: %s
83*common2
ImplementationZ17-83h px� 

G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
142
192
02
0Z4-41h px� 
O
%s completed successfully
29*	vivadotcl2
write_bitstreamZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
write_bitstream: 2

00:00:112

00:00:112

2693.9572	
441.082Z17-268h px� 


End Record