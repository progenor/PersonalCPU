----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026
-- Design Name: PS2 Keyboard Controller
-- Module Name: PS2_Controller - Behavioral
-- Project Name: PersonalCPU
-- Target Devices: Xilinx 7-Series
-- Tool Versions: Vivado
-- Description: 
--   PS/2 Keyboard Interface Controller
--   - Dual debounce filters for PS/2 clock and data signals
--   - Falling-edge detector on debounced clock to generate interrupt
--   - Provides clean PS/2 signals and interrupt request pulse
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--   Adapted from FromOthers/Diakoknak/Kod/ps2toplevel.vhd
--   Debounce counter: 5-bit counter = 32 system clock cycles
--   At 125 MHz system clock, debounce window = 256 ns
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_Controller is
    Port (
        clk         : in STD_LOGIC;                     -- System clock (125 MHz)
        reset       : in STD_LOGIC;                     -- Active high reset
        ps2_clk     : in STD_LOGIC;                     -- Raw PS/2 clock from keyboard
        ps2_data    : in STD_LOGIC;                     -- Raw PS/2 data from keyboard
        ps2_clk_clean : out STD_LOGIC;                  -- Debounced PS/2 clock
        ps2_data_clean : out STD_LOGIC;                 -- Debounced PS/2 data
        interrupt_req : out STD_LOGIC                   -- Interrupt pulse on clock falling edge
    );
end PS2_Controller;

architecture Behavioral of PS2_Controller is

    -- Debounce signals for PS/2 clock
    signal clk_count : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal clk_inter : STD_LOGIC := '1';
    signal ps2_clk_debounced : STD_LOGIC := '1';
    
    -- Debounce signals for PS/2 data
    signal data_count : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal data_inter : STD_LOGIC := '1';
    signal ps2_data_debounced : STD_LOGIC := '1';
    
    -- Synchronization and edge detection
    signal ps2_clk_sync : STD_LOGIC := '1';
    signal ps2_clk_prev : STD_LOGIC := '1';
    
begin

    -- Output assignments
    ps2_clk_clean <= ps2_clk_debounced;
    ps2_data_clean <= ps2_data_debounced;

    ---------------------------------------------------------------------------
    -- PS/2 Clock Debounce Process
    -- Waits for 32 consecutive stable samples before updating clean signal
    ---------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            clk_count <= (others => '0');
            clk_inter <= '1';
            ps2_clk_debounced <= '1';
        elsif rising_edge(clk) then
            -- If PS/2 clock changed from last sample, reset counter
            if ps2_clk /= clk_inter then
                clk_inter <= ps2_clk;
                clk_count <= (others => '0');
            -- If counter has counted to 31 (0x1F), signal is stable
            elsif clk_count = "11111" then
                ps2_clk_debounced <= clk_inter;
            -- Otherwise increment debounce counter
            else
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- PS/2 Data Debounce Process
    -- Waits for 32 consecutive stable samples before updating clean signal
    ---------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            data_count <= (others => '0');
            data_inter <= '1';
            ps2_data_debounced <= '1';
        elsif rising_edge(clk) then
            -- If PS/2 data changed from last sample, reset counter
            if ps2_data /= data_inter then
                data_inter <= ps2_data;
                data_count <= (others => '0');
            -- If counter has counted to 31 (0x1F), signal is stable
            elsif data_count = "11111" then
                ps2_data_debounced <= data_inter;
            -- Otherwise increment debounce counter
            else
                data_count <= data_count + 1;
            end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- PS/2 Clock Synchronization
    -- Synchronize debounced clock to system clock domain
    ---------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            ps2_clk_sync <= '1';
            ps2_clk_prev <= '1';
        elsif rising_edge(clk) then
            ps2_clk_sync <= ps2_clk_debounced;
            ps2_clk_prev <= ps2_clk_sync;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- Interrupt Request Generation
    -- Detects falling edge on debounced PS/2 clock and generates pulse
    -- PS/2 clock falling edge indicates keyboard is transmitting a data bit
    ---------------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            interrupt_req <= '0';
        elsif rising_edge(clk) then
            -- Falling edge detection: previous=1, current=0
            if ps2_clk_prev = '1' and ps2_clk_sync = '0' then
                interrupt_req <= '1';
            else
                interrupt_req <= '0';
            end if;
        end if;
    end process;

end Behavioral;
