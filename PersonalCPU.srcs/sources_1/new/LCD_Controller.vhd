----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026
-- Design Name: LCD Controller
-- Module Name: LCD_Controller - Behavioral
-- Project Name: PersonalCPU
-- Target Devices: Xilinx 7-Series
-- Tool Versions: Vivado
-- Description: 
--   HD44780-compatible LCD 16x2 Controller
--   Generates proper timing for LCD control (Rs, Rw, E) and 8-bit data bus
--
-- Dependencies: None
-- 
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_Controller is
    Port (
        clk         : in STD_LOGIC;                    -- 125 MHz system clock
        reset       : in STD_LOGIC;                    -- Active high reset
        write_en    : in STD_LOGIC;                    -- Write strobe from CPU
        rs_flag     : in STD_LOGIC;                    -- Register select: 0=cmd, 1=data
        data_in     : in STD_LOGIC_VECTOR(7 downto 0); -- Data/command byte from CPU
        
        -- LCD Interface (HD44780 compatible)
        lcd_data    : out STD_LOGIC_VECTOR(7 downto 0); -- Data bus to LCD
        lcd_rs      : out STD_LOGIC;                    -- Register Select: 0=cmd, 1=data
        lcd_rw      : out STD_LOGIC;                    -- Read/Write: 0=write, 1=read (always 0)
        lcd_e       : out STD_LOGIC;                    -- Enable strobe
        
        busy        : out STD_LOGIC                     -- Busy flag (1=still processing)
    );
end LCD_Controller;

architecture Behavioral of LCD_Controller is

    -- State machine states
    type state_type is (IDLE, SET_DATA, PULSE_ENABLE, HOLD_LOW, WAIT_SETTLE);
    signal state : state_type := IDLE;
    
    -- Timing counters
    -- At 125 MHz: period = 8 ns
    -- 40 clocks = 320 ns (suitable for E pulse and setup/hold times)
    signal cycle_count : STD_LOGIC_VECTOR(5 downto 0) := "000000";
    signal data_latch : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rs_latch : STD_LOGIC := '0';

begin

    lcd_rw <= '0';  -- Always write mode (reading not implemented)

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            cycle_count <= (others => '0');
            lcd_data <= (others => '0');
            lcd_rs <= '0';
            lcd_e <= '0';
            busy <= '0';
            data_latch <= (others => '0');
            rs_latch <= '0';
        elsif rising_edge(clk) then
            case state is
                -- IDLE: Wait for write strobe from CPU
                when IDLE =>
                    lcd_e <= '0';
                    busy <= '0';
                    if write_en = '1' then
                        -- Capture data and RS flag
                        data_latch <= data_in;
                        rs_latch <= rs_flag;
                        cycle_count <= (others => '0');
                        state <= SET_DATA;
                        busy <= '1';
                    end if;

                -- SET_DATA: Place data and RS on bus, wait for setup time
                when SET_DATA =>
                    lcd_data <= data_latch;
                    lcd_rs <= rs_latch;
                    -- Wait 5 clocks for setup time (40 ns, HD44780 requires 40 ns min)
                    if cycle_count = "000101" then
                        cycle_count <= (others => '0');
                        state <= PULSE_ENABLE;
                    else
                        cycle_count <= cycle_count + 1;
                    end if;

                -- PULSE_ENABLE: Generate E pulse (40 clocks = 320 ns)
                when PULSE_ENABLE =>
                    lcd_e <= '1';
                    if cycle_count = "101000" then  -- 40 decimal = 0x28
                        cycle_count <= (others => '0');
                        state <= HOLD_LOW;
                    else
                        cycle_count <= cycle_count + 1;
                    end if;

                -- HOLD_LOW: Hold E low for hold time
                when HOLD_LOW =>
                    lcd_e <= '0';
                    if cycle_count = "101000" then  -- 40 clocks
                        cycle_count <= (others => '0');
                        state <= WAIT_SETTLE;
                    else
                        cycle_count <= cycle_count + 1;
                    end if;

                -- WAIT_SETTLE: Additional settling time before accepting next command
                when WAIT_SETTLE =>
                    -- Wait 10 clocks for LCD to internally process
                    if cycle_count = "001010" then  -- 10 decimal
                        state <= IDLE;
                    else
                        cycle_count <= cycle_count + 1;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;
