----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2024 05:42:45 PM
-- Design Name: 
-- Module Name: DataMemorySim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataMemorySim is
--  Port ( );
end DataMemorySim;

architecture Behavioral of DataMemorySim is

component DataMemory is
    Port ( Clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           DataOutX : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutY : in STD_LOGIC_VECTOR (5 downto 0);
           DMemAdd_Dir : in STD_LOGIC_VECTOR (5 downto 0);
           SelAddr : in STD_LOGIC;
           MRd : in STD_LOGIC;
           MWr : in STD_LOGIC;
           DataMemOut : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    -- Input overall
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
    -- Clock period definitions
   constant clk_period : time := 10 ns;
   
           signal DataOutX :  STD_LOGIC_VECTOR (15 downto 0)  := (others => '0');
           signal DataOutY :  STD_LOGIC_VECTOR (5 downto 0)  := (others => '0');
           signal DMemAdd_Dir :  STD_LOGIC_VECTOR (5 downto 0)  := (others => '0');
           signal SelAddr :  STD_LOGIC := '0';
           signal MRd :  STD_LOGIC := '0';
           signal MWr :  STD_LOGIC := '0';
           signal DataMemOut : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');

begin   
   
   uut:DataMemory PORT MAP ( 
           Clk =>clk,
           reset => reset,
           DataOutX => DataOutX,
           DataOutY => DataOutY,
           DMemAdd_Dir => DMemAdd_Dir,
           SelAddr => SelAddr,
           MRd => MRd,
           MWr => MWr,
           DataMemOut =>DataMemOut
           );


 -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
    
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
      
      
   end process;


end Behavioral;
