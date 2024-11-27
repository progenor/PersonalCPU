----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/16/2024 01:41:54 PM
-- Design Name: 
-- Module Name: Mux - Behavioral
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

entity Mux is
    Port ( MUX_Sel : in STD_LOGIC_VECTOR (2 downto 0);
           DataMemOut : in STD_LOGIC_VECTOR (15 downto 0);
           PortIntoCPU : in STD_LOGIC_VECTOR (15 downto 0);
           ALUresult : in STD_LOGIC_VECTOR (15 downto 0);
           KK_const : in STD_LOGIC_VECTOR (7 downto 0);
           DataOut_Y : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutMUX : out STD_LOGIC_VECTOR (15 downto 0));
end Mux;

architecture Behavioral of Mux is

begin
process(MUX_Sel) is
    begin
  
        case MUX_Sel is
            when "000" =>
                DataOutMUX <= DataMemOut;
            when "001" =>
                DataOutMUX <= PortIntoCPU;
            when "010" =>
                DataOutMUX <= ALUresult;
            when "011" =>
                DataOutMUX <=  "00000000" & KK_const;
            when "100" =>
                DataOutMUX <= DataOut_Y;   
            when others =>
                DataOutMUX <= (others => '0');
        end case;
  
    end process;
    

end Behavioral;
