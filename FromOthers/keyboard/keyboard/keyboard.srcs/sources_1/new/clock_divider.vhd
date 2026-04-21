library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_divider is
    Port ( clk_in  : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           reset   : in STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : std_logic_vector(6 downto 0) := (others => '0');
    signal clk_reg : std_logic := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            clk_reg <= '0';
        elsif rising_edge(clk_in) then
            if counter = "0000110" then -- 6 dec -> kb 10 MHz
                counter <= (others => '0');
                clk_reg <= not clk_reg;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    
    clk_out <= clk_reg;
end Behavioral;