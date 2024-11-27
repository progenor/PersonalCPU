----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 05:32:01 PM
-- Design Name: 
-- Module Name: CPU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    Port ( clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           PortDataIn : in STD_LOGIC_VECTOR (15 downto 0);
           interrupt : in STD_LOGIC;
           instruction : in STD_LOGIC_VECTOR (17 downto 0);
           PortDataOut : out STD_LOGIC_VECTOR (15 downto 0);
           PortID : out STD_LOGIC_VECTOR (7 downto 0);
           ReadStrobe : out STD_LOGIC;
           WriteStrobe : out STD_LOGIC;
           interrupt_Acknowledge : out STD_LOGIC;
           instruction_Address : out STD_LOGIC_VECTOR (11 downto 0));
end CPU;

architecture Behavioral of CPU is

-- component declarations

component RegisterBlock is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Data_IN : in STD_LOGIC_VECTOR (15 downto 0);
           SxAddr : in STD_LOGIC_VECTOR (3 downto 0);
           SyAddr : in STD_LOGIC_VECTOR (3 downto 0);
           RW : in STD_LOGIC;
           Data_Out_x : out STD_LOGIC_VECTOR (15 downto 0);
           Data_Out_y : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component PortLogic is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           PortID_dir : in STD_LOGIC_VECTOR (7 downto 0);
           PortID_indir : in STD_LOGIC_VECTOR (7 downto 0);
           PortDataIn : in STD_LOGIC_VECTOR (15 downto 0);
           PortID_sel : in STD_LOGIC;
           IORD : in STD_LOGIC;
           IOWR : in STD_LOGIC;
           DataOutX : in STD_LOGIC_VECTOR (15 downto 0);
           PortID : out STD_LOGIC_VECTOR (7 downto 0);
           PortDataOut : out STD_LOGIC_VECTOR (15 downto 0);
           Rd_strobe : out STD_LOGIC;
           Wr_strobe : out STD_LOGIC;
           PortIntoCPU : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component PFC is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           Instr_code : in  STD_LOGIC_VECTOR (5 downto 0);
           Branch_addr : in  STD_LOGIC_VECTOR (11 downto 0);
           Int_req : in  STD_LOGIC;
           Carry : in  STD_LOGIC;
           Zero : in  STD_LOGIC;
           En_Intr : in  STD_LOGIC;
           Instr_phase : out  STD_LOGIC_VECTOR (2 downto 0);
           Execute : out  STD_LOGIC;
           Int_Ack : out  STD_LOGIC;
           Mux_Sel : out  STD_LOGIC_VECTOR (2 downto 0);
           Sel_Addr : out  STD_LOGIC;
           PortId_Sel : out  STD_LOGIC;
           RW : out  STD_LOGIC;
           Mrd : out  STD_LOGIC;
           Mwr : out  STD_LOGIC;
           IOrd : out  STD_LOGIC;
           IOwr : out  STD_LOGIC;
           Instr_addr : out  STD_LOGIC_VECTOR (11 downto 0));
           
end component;

component Mux is
    Port ( MUX_Sel : in STD_LOGIC_VECTOR (2 downto 0);
           DataMemOut : in STD_LOGIC_VECTOR (15 downto 0);
           PortIntoCPU : in STD_LOGIC_VECTOR (15 downto 0);
           ALUresult : in STD_LOGIC_VECTOR (15 downto 0);
           KK_const : in STD_LOGIC_VECTOR (7 downto 0);
           DataOut_Y : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutMUX : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component IfAndDec is
    Port ( reset : in STD_LOGIC;
           Instr_Phase : in STD_LOGIC_VECTOR (2 downto 0);
           Instruction : in STD_LOGIC_VECTOR (17 downto 0);
           SX_Addr : out STD_LOGIC_VECTOR (3 downto 0);
           SY_Addr : out STD_LOGIC_VECTOR (3 downto 0);
           DMemAddr_dir : out STD_LOGIC_VECTOR (5 downto 0);
           ENInterrupt : out std_logic;
           Instr_code : out STD_LOGIC_VECTOR (5 downto 0);
           PortID_dir : out STD_LOGIC_VECTOR (7 downto 0);
           Branch_Addr : out STD_LOGIC_VECTOR (11 downto 0);
           AL_Instr_Ext : out STD_LOGIC_VECTOR (3 downto 0);
           KK_const : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component DataMemory is
    Port ( Clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           DataOutX : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutY : in STD_LOGIC_VECTOR (15 downto 0);
           DMemAdd_Dir : in STD_LOGIC_VECTOR (5 downto 0);
           SelAddr : in STD_LOGIC;
           MRd : in STD_LOGIC;
           MWr : in STD_LOGIC;
           DataMemOut : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component ALU is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           OP1 : in STD_LOGIC_VECTOR (15 downto 0);
           OP2 : in STD_LOGIC_VECTOR (15 downto 0);
           Instr_code : in STD_LOGIC_VECTOR (5 downto 0);
           Al_Instr_Ext : in STD_LOGIC_VECTOR (3 downto 0);
           KK_const : in STD_LOGIC_VECTOR (7 downto 0);
           Execute : in STD_LOGIC;
           Carry : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALU_Result : out STD_LOGIC_VECTOR (15 downto 0));
end component;

    -- Shared signal declarations across components with the same name
    signal SxAddr           : STD_LOGIC_VECTOR(3 downto 0);
    signal SyAddr           : STD_LOGIC_VECTOR(3 downto 0);
    signal RW               : STD_LOGIC;
    signal Data_Out_x       : STD_LOGIC_VECTOR(15 downto 0);
    signal Data_Out_y       : STD_LOGIC_VECTOR(15 downto 0);
    signal PortID_dir       : STD_LOGIC_VECTOR(7 downto 0);
    signal PortID_indir     : STD_LOGIC_VECTOR(7 downto 0);
    signal PortID_sel       : STD_LOGIC;
    signal IORD             : STD_LOGIC;
    signal IOWR             : STD_LOGIC;
    signal MRd             : STD_LOGIC;
    signal MWr             : STD_LOGIC;
    signal PortIntoCPU      : STD_LOGIC_VECTOR(15 downto 0);
    signal Instr_code       : STD_LOGIC_VECTOR(5 downto 0);
    signal Branch_addr      : STD_LOGIC_VECTOR(11 downto 0);
    signal Carry            : STD_LOGIC;
    signal Zero             : STD_LOGIC;
    signal En_Intr          : STD_LOGIC;
    signal Instr_phase      : STD_LOGIC_VECTOR(2 downto 0);
    signal Execute          : STD_LOGIC;
    signal Int_Ack          : STD_LOGIC;
    signal Mux_Sel          : STD_LOGIC_VECTOR(2 downto 0);
    signal Sel_Addr         : STD_LOGIC;
    signal KK_const         : STD_LOGIC_VECTOR(7 downto 0);
    signal DMemAddr_dir     : STD_LOGIC_VECTOR(5 downto 0);
    signal DataMemOut       : STD_LOGIC_VECTOR(15 downto 0);
    signal AL_Instr_Ext     : STD_LOGIC_VECTOR(3 downto 0);
    signal ALU_Result       : STD_LOGIC_VECTOR(15 downto 0);
    signal Data_in          : STD_LOGIC_VECTOR (15 downto 0);

begin
    -- RegisterBlock instance
    RegisterBlock_inst: RegisterBlock
        port map (
            Clk => clk,
            Reset => Reset,
            Data_IN => Data_in,
            SxAddr => SxAddr,
            SyAddr => SyAddr,
            RW => RW,
            Data_Out_x => Data_Out_x,
            Data_Out_y => Data_Out_y
        );

    -- PortLogic instance
    PortLogic_inst: PortLogic
        port map (
            clk => clk,
            reset => Reset,
            PortID_dir => PortID_dir,
            PortID_indir => PortID_indir,
            PortDataIn => PortDataIn,
            PortID_sel => PortID_sel,
            IORD => IORD,
            IOWR => IOWR,
            DataOutX => Data_Out_x,
            PortID => PortID,
            PortDataOut => PortDataOut,
            Rd_strobe => ReadStrobe,
            Wr_strobe => WriteStrobe,
            PortIntoCPU => PortIntoCPU
        );

    -- PFC instance
    PFC_inst: PFC
        port map (
            clk => clk,
            reset => Reset,
            Instr_code => Instr_code,
            Branch_addr => Branch_addr,
            Int_req => interrupt,
            Carry => Carry,
            Zero => Zero,
            En_Intr => En_Intr,
            Instr_phase => Instr_phase,
            Execute => Execute,
            Int_Ack => Int_Ack,
            Mux_Sel => Mux_Sel,
            Sel_Addr => Sel_Addr,
            PortId_Sel => PortID_sel,
            RW => RW,
            Mrd => MRd,
            Mwr => MWr,
            IOrd => IORD,
            IOwr => IOWR,
            Instr_addr => instruction_Address
        );

    -- Mux instance
    Mux_inst: Mux
        port map (
            MUX_Sel => Mux_Sel,
            DataMemOut => DataMemOut,
            PortIntoCPU => PortIntoCPU,
            ALUresult => ALU_Result,
            KK_const => KK_const,
            DataOut_Y => Data_Out_y,
            DataOutMUX => Data_in
        );

    -- IfAndDec instance
    IfAndDec_inst: IfAndDec
        port map (
            reset => Reset,
            Instr_Phase => Instr_phase,
            Instruction => instruction,
            SX_Addr => SxAddr,
            SY_Addr => SyAddr,
            DMemAddr_dir => DMemAddr_dir,
            ENInterrupt => En_Intr,
            Instr_code => Instr_code,
            PortID_dir => PortID_dir,
            Branch_Addr => Branch_addr,
            AL_Instr_Ext => AL_Instr_Ext,
            KK_const => KK_const
        );

    -- DataMemory instance
    DataMemory_inst: DataMemory
        port map (
            Clk => clk,
            reset => Reset,
            DataOutX => Data_Out_x,
            DataOutY => Data_Out_y,
            DMemAdd_Dir => DMemAddr_dir,
            SelAddr => Sel_Addr,
            MRd => MRd,
            MWr => MWr,
            DataMemOut => DataMemOut
        );

    -- ALU instance
    ALU_inst: ALU
        port map (
            clk => clk,
            reset => Reset,
            OP1 => Data_Out_x,
            OP2 => Data_Out_y,
            Instr_code => Instr_code,
            Al_Instr_Ext => AL_Instr_Ext,
            KK_const => KK_const,
            Execute => Execute,
            Carry => Carry,
            Zero => Zero,
            ALU_Result => ALU_Result
        );
end Behavioral;

