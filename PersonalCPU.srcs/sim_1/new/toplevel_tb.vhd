----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2024 03:59:39 PM
-- Design Name: 
-- Module Name: toplevel_tb - Behavioral
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

entity toplevel_tb is
--  Port ( );
end toplevel_tb;

architecture Behavioral of toplevel_tb is

component toplevel is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0);
           reset : in STD_LOGIC
           );
end component;

    signal btn : std_logic_vector (3 downto 0) := (others => '0');
    signal led : std_logic_vector (3 downto 0)  :=  (others =>'0');
    signal reset : std_logic := '0';
    
    signal clk          : std_logic := '0';
    constant clk_period : time := 8 ns;
begin

uut: toplevel PORT MAP (
       clk => clk,
       btn => btn,
       led => led,
       reset => reset
);

clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

 stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for clk_period;
      
      btn <= x"1";
      wait;

      
      
      
    end process;


end Behavioral;
