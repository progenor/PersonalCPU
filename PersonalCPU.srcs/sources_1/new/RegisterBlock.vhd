----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2024 05:58:04 PM
-- Design Name: 
-- Module Name: RegisterBlock - Behavioral
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
use IEEE.numeric_std.ALL;
--use IEEE.std_logic_unsigned.ALL;
--use IEEE.std_logic_arith.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterBlock is
    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Data_IN : in STD_LOGIC_VECTOR (15 downto 0);
           SxAddr : in STD_LOGIC_VECTOR (3 downto 0);
           SyAddr : in STD_LOGIC_VECTOR (3 downto 0);
           RW : in STD_LOGIC;
           Data_Out_x : out STD_LOGIC_VECTOR (15 downto 0);
           Data_Out_y : out STD_LOGIC_VECTOR (15 downto 0));
end RegisterBlock;

architecture Behavioral of RegisterBlock  is
    type Regis is array (0 to 15) of  std_logic_vector(15 downto 0);
begin
    process(Clk, Reset, RW)
     variable Tarolo : Regis := (others=>(others => '0'));
    begin
        if(falling_edge(Clk))then
            if(Reset = '1') then
                Tarolo := (others =>(others => '0'));
                Data_Out_x <= (others => '0');
            else
                if(RW = '1') then
                    Tarolo(TO_INTEGER(unsigned(SxAddr))) := Data_IN;
                else
                    Data_Out_x <= Tarolo(TO_INTEGER(unsigned(SxAddr)));
                    Data_Out_y <= Tarolo(TO_INTEGER(unsigned(SyAddr)));
                    
                end if;
            end if;
        end if;
    
    end process;


end Behavioral;
