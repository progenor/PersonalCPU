----------------------------------------------------------------------------------
-- UART Baud Rate Generator for 115200 baud at 125 MHz clock
-- Output: en_16_x_baud pulse (16x oversampling)
-- Divisor: 125,000,000 / (115200 * 16) = 67.12 → use 67 for close approximation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_BaudRate_Gen is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_16_x_baud : out STD_LOGIC);
end UART_BaudRate_Gen;

architecture Behavioral of UART_BaudRate_Gen is
    signal counter : std_logic_vector(9 downto 0);
    constant DIVISOR : integer := 67;
begin

process(clk, reset)
begin
    if reset = '1' then
        counter <= (others => '0');
        en_16_x_baud <= '0';
    elsif clk'event and clk = '1' then
        en_16_x_baud <= '0';
        if counter = DIVISOR - 1 then
            counter <= (others => '0');
            en_16_x_baud <= '1';
        else
            counter <= counter + 1;
        end if;
    end if;
end process;

end Behavioral;
