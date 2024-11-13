----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2024 05:09:29 PM
-- Design Name: 
-- Module Name: DataMemory - Behavioral
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

entity DataMemory is
    Port ( Clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           DataOutX : in STD_LOGIC_VECTOR (15 downto 0);
           DataOutY : in STD_LOGIC_VECTOR (5 downto 0);
           DMemAdd_Dir : in STD_LOGIC_VECTOR (5 downto 0);
           SelAddr : in STD_LOGIC;
           MRd : in STD_LOGIC;
           MWr : in STD_LOGIC;
           DataMemOut : out STD_LOGIC_VECTOR (15 downto 0));
end DataMemory;

architecture Behavioral of DataMemory is
    type Regis is array (0 to 63) of  std_logic_vector(15 downto 0);
    signal DMemAddr : integer range 0 to 63 := 0;
begin
    DMemAddr <= conv_integer(DMemAdd_Dir) 
            when SelAddr = '0' else conv_integer(DataOutY);

process(Clk, reset, MWr, MRd)
    variable Tarolo : Regis := (others=>(others => '0'));
begin
if(falling_edge(Clk))then
    if(reset='1')then
        DataMemOut <= (others => '0');  
        Tarolo := (others =>(others => '0'));  
    else
        if(MWr = '1' and MRd = '0') then
            Tarolo(DMemAddr) := DataOutX;
        elsif (MWr = '0' and MRd = '1')then
            DataMemOut <= Tarolo(DMemAddr);
        end if;    
    end if;
end if;
end process;
    

end Behavioral;
