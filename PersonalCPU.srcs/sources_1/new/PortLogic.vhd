----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2024 03:10:06 PM
-- Design Name: 
-- Module Name: PortLogic - Behavioral
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PortLogic is
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
end PortLogic;

architecture Behavioral of PortLogic is
    signal counter : integer range 0 to 2 := 0;
begin

-- setting PortID to inputs case handle
PortID <= PortID_dir 
            when PortID_sel = '0' else PortID_indir;


-- counter does bs
process (reset, clk, IORD, IOWR)
begin
    if(IORD='0' or IOWR='0' or reset='1')then
        counter <= 0;
    else
        if(falling_edge(clk))then
            if(counter < 2)then
                counter <= counter + 1;
            else 
                counter <=0;
            end if;
        end if;    
    end if;
end process;

-- main stuff
process(clk, reset, counter) 
begin
    if(reset = '1')then
        PortDataOut <= (others => '0');
        PortIntoCPU <= (others => '0');
    else
        if(falling_edge(clk))then
            if(IOWR='1' and IORD='0')then
            -- do a case for counter stages
            else
            -- do a case for counter stages
            end if;
        end if;
    end if;
end process;

end Behavioral;
