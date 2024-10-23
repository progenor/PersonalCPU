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
 
    COMPONENT RegBlock
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         rw : IN  std_logic;
         RegAddr_X : IN  std_logic_vector(3 downto 0);
         RegAddr_Y : IN  std_logic_vector(3 downto 0);
         Reg_In_X : IN  std_logic_vector(15 downto 0);
         Reg_In_Y : IN  std_logic_vector(15 downto 0);
         Reg_Out_X : OUT  std_logic_vector(15 downto 0);
         Reg_Out_Y : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal rw : std_logic := '0';
   signal RegAddr_X : std_logic_vector(3 downto 0) := (others => '0');
   signal RegAddr_Y : std_logic_vector(3 downto 0) := (others => '0');
   signal Reg_In_X : std_logic_vector(15 downto 0) := (others => '0');
   signal Reg_In_Y : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Reg_Out_X : std_logic_vector(15 downto 0);
   signal Reg_Out_Y : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RegBlock PORT MAP (
          clk => clk,
          reset => reset,
          rw => rw,
          RegAddr_X => RegAddr_X,
          RegAddr_Y => RegAddr_Y,
          Reg_In_X => Reg_In_X,
          Reg_In_Y => Reg_In_Y,
          Reg_Out_X => Reg_Out_X,
          Reg_Out_Y => Reg_Out_Y
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
		Reg_In_X <= x"DD00";
		rw <= '1';
		wait for clk_period;
		rw <= '0';
		wait for clk_period;

		RegAddr_X<="1100";
		Reg_In_X <= x"F0F0";
		rw <= '1';
		wait for clk_period;
		rw <= '0';
		wait for clk_period;		
		
		RegAddr_X<="0011";
		RegAddr_Y<="1100";
		rw <= '0';
		wait for clk_period;	
		
      wait;
   end process;

END;
