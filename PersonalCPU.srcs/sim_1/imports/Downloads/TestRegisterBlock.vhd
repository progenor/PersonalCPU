--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:01:23 10/05/2020
-- Design Name:   
-- Module Name:   D:/Work/Sapientia/2018-2019/I felev/Archit/PicoBLclone/TestRegisterBlock.vhd
-- Project Name:  SapiLabProc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegBlock
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TestRegisterBlock IS
END TestRegisterBlock;
 
ARCHITECTURE behavior OF TestRegisterBlock IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
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
    
    component Mux is
    Port ( MUX_Sel : in STD_LOGIC_VECTOR (2 downto 0);
           DataMemOut : in STD_LOGIC_VECTOR (15 downto 0);
           PortIntoCPU : in STD_LOGIC_VECTOR (15 downto 0);
           ALUresult : in STD_LOGIC_VECTOR (15 downto 0);
           KK_const : in STD_LOGIC_VECTOR (15 downto 0);
           DataOut_Y : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutMUX : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

   -- Inputs for Mux
   signal SMUX_Sel : std_logic_vector(2 downto 0) := (others =>'0');
   signal SDataOut_Y : std_logic_vector(15 downto 0);
   signal SDataOutMux : std_logic_vector(15 downto 0);
   signal SKK_const: std_logic_vector(15 downto 0);    
   signal SALUresult : std_logic_vector(15 downto 0);
   signal SPortIntoCPU: std_logic_vector(15 downto 0);
   
   -- Outputs for Mux
   signal SDataMemOut: std_logic_vector(15 downto 0);
   
   
   --Inputs for RegisterBlock
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rw : std_logic := '0';
   signal RegAddr_X : std_logic_vector(3 downto 0) := (others => '0');
   signal RegAddr_Y : std_logic_vector(3 downto 0) := (others => '0');
   signal RegData_In : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs for RegisterBlock
   signal Reg_Out_X : std_logic_vector(15 downto 0);
   signal Reg_Out_Y : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: RegisterBlock PORT MAP (
          Clk => clk,
          Reset => reset,
          RW => rw,
          SxAddr => RegAddr_X,
          SyAddr => RegAddr_Y,
          Data_IN => RegData_IN,
          Data_Out_x => Reg_Out_X,
          Data_Out_y => Reg_Out_Y
        );
    -- Instantiate the Mux component
   uut2:  Mux PORT MAP ( 
          MUX_Sel  => SMUX_Sel,
          DataMemOut  => SDataMemOut,
          PortIntoCPU => SPortIntoCPU,
          ALUresult => SALUresult,
          KK_const => SKK_const,
          DataOut_Y => SDataOut_Y,
          DataOutMUX => SDataOutMux
   );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

     -- wait for clk_period*10;

      -- insert stimulus here 
		RegAddr_X<="0011";
		RegData_IN <= x"DD00"; -- ezt kell megkapni a mux tol
		rw <= '1';
		wait for clk_period;
		rw <= '0';
		wait for clk_period;

		RegAddr_X<="1100";
		RegData_IN <= x"F0F0";
		rw <= '1';
		wait for clk_period;
		rw <= '0';
		wait for clk_period;		
		
		RegAddr_X<="0011";
		RegAddr_Y<="1100";
		rw <= '0';
		wait for clk_period;	
		
		wait for 100 ns;
		----------------------------- START WITH MUX TESTING
		
		RegAddr_X<="0011";
		
		
      wait;
   end process;

END;
