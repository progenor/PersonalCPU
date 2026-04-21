----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026
-- Design Name: PS2 Controller Testbench
-- Module Name: ps2_tb - Testbench
-- Project Name: PersonalCPU
-- Target Devices: 
-- Tool Versions: 
-- Description: 
--   Testbench for PS2_Controller module
--   Simulates PS/2 keyboard protocol to verify debouncing and interrupt generation
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_tb is
end ps2_tb;

architecture Behavioral of ps2_tb is

    -- Component declaration for PS2_Controller
    component PS2_Controller is
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
            ps2_clk         : in STD_LOGIC;
            ps2_data        : in STD_LOGIC;
            ps2_clk_clean   : out STD_LOGIC;
            ps2_data_clean  : out STD_LOGIC;
            interrupt_req   : out STD_LOGIC
        );
    end component;

    -- Test signals
    signal clk              : STD_LOGIC := '0';
    signal reset            : STD_LOGIC := '0';
    signal ps2_clk          : STD_LOGIC := '1';
    signal ps2_data         : STD_LOGIC := '1';
    signal ps2_clk_clean    : STD_LOGIC;
    signal ps2_data_clean   : STD_LOGIC;
    signal interrupt_req    : STD_LOGIC;
    
    -- Test timing parameters
    constant CLK_PERIOD     : time := 8 ns;        -- 125 MHz system clock
    constant PS2_CLK_PERIOD : time := 32 us;       -- ~31 kHz PS/2 clock
    constant DEBOUNCE_TIME  : time := 32 * CLK_PERIOD;  -- 256 ns debounce window
    
    -- PS/2 scancode to send: 0x1C (key 'A')
    -- Frame: Start(0) + Data(1C LSB first) + Parity(0) + Stop(1)
    -- Bits:  0      + 0,0,0,1,1,1,0,0    + 0      + 1
    signal scancode_bits : STD_LOGIC_VECTOR(10 downto 0) := "10000111000";  -- Stop,Parity,Data(LSB first),Start
    
    -- Test state
    signal test_phase : integer := 0;
    signal bit_index  : integer := 0;

begin

    -- Instantiate PS2_Controller
    ps2_ctrl_inst : PS2_Controller
    port map (
        clk             => clk,
        reset           => reset,
        ps2_clk         => ps2_clk,
        ps2_data        => ps2_data,
        ps2_clk_clean   => ps2_clk_clean,
        ps2_data_clean  => ps2_data_clean,
        interrupt_req   => interrupt_req
    );

    -- System clock generation (125 MHz)
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Main test stimulus
    stimulus_process : process
    begin
        -- Phase 0: Initial reset
        test_phase <= 0;
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Phase 1: Test debouncing with single bit transitions
        test_phase <= 1;
        report "TEST PHASE 1: Debouncing with clock transitions" severity NOTE;
        
        -- Wait a few clock cycles
        wait for 1 us;
        
        -- Pull clock low (keyboard is transmitting bit 0 - START bit)
        ps2_clk <= '0';
        ps2_data <= '0';  -- START bit
        wait for 100 us;  -- Hold for 100us (3125 clocks at 125MHz)
        
        -- Release clock (keyboard waits for ACK)
        ps2_clk <= '1';
        wait for 100 us;
        
        -- Phase 2: Send complete scancode 0x1C (bits transmitted LSB first)
        test_phase <= 2;
        report "TEST PHASE 2: Sending scancode 0x1C (11-bit frame)" severity NOTE;
        
        -- Wait for stability
        wait for 1 us;
        
        -- Transmit 11 bits using PS2 protocol
        -- Each bit: clock low, set data, wait, clock high, wait
        for bit_idx in 0 to 10 loop
            bit_index <= bit_idx;
            
            -- Set data bit (LSB first, so bit 0 first)
            if bit_idx = 0 then
                ps2_data <= '0';  -- START bit
                report "Sending START bit (0)" severity NOTE;
            elsif bit_idx <= 8 then
                ps2_data <= scancode_bits(bit_idx - 1);
                report "Sending data bit " & integer'image(bit_idx - 1) & " = " & 
                        std_logic'image(scancode_bits(bit_idx - 1)) severity NOTE;
            elsif bit_idx = 9 then
                ps2_data <= '0';  -- Parity bit (odd parity for 0x1C)
                report "Sending parity bit (0)" severity NOTE;
            elsif bit_idx = 10 then
                ps2_data <= '1';  -- STOP bit
                report "Sending STOP bit (1)" severity NOTE;
            end if;
            
            -- Pull clock low
            ps2_clk <= '0';
            wait for PS2_CLK_PERIOD / 2;
            
            -- Release clock (pull high via open drain)
            ps2_clk <= '1';
            wait for PS2_CLK_PERIOD / 2;
        end loop;
        
        -- Release data line
        ps2_data <= '1';
        wait for 1 us;
        
        -- Phase 3: Test glitch immunity (noise on PS2 lines)
        test_phase <= 3;
        report "TEST PHASE 3: Testing glitch immunity (noise on clock)" severity NOTE;
        
        wait for 1 us;
        
        -- Simulate glitch: quick pulse on clock (should be filtered)
        ps2_clk <= '0';
        wait for 100 ns;  -- Very short pulse
        ps2_clk <= '1';
        wait for 100 ns;
        ps2_clk <= '0';
        wait for 10 us;   -- Normal clock low hold
        ps2_clk <= '1';
        wait for 10 us;
        
        -- Phase 4: Extended test - repeat sending a key
        test_phase <= 4;
        report "TEST PHASE 4: Sending second scancode 0x32 (key 'B')" severity NOTE;
        
        -- Scancode 0x32: 00110010
        -- Frame with parity: 0 + 01001100 (0x32 LSB first) + 1 + 1 = 11001001001 reversed
        scancode_bits <= "10100110010";  -- Stop, Parity(1), Data(LSB first), Start
        
        wait for 2 us;
        
        for bit_idx in 0 to 10 loop
            bit_index <= bit_idx;
            
            if bit_idx = 0 then
                ps2_data <= '0';  -- START
            elsif bit_idx <= 8 then
                ps2_data <= scancode_bits(bit_idx - 1);
            elsif bit_idx = 9 then
                ps2_data <= '1';  -- Parity bit for 0x32
            elsif bit_idx = 10 then
                ps2_data <= '1';  -- STOP
            end if;
            
            ps2_clk <= '0';
            wait for PS2_CLK_PERIOD / 2;
            ps2_clk <= '1';
            wait for PS2_CLK_PERIOD / 2;
        end loop;
        
        ps2_data <= '1';
        ps2_clk <= '1';
        
        -- End simulation
        test_phase <= 5;
        report "TEST COMPLETE" severity NOTE;
        wait for 10 us;
        
        -- Stop simulation
        report "Testbench finished" severity NOTE;
        wait;
    end process;

    -- Monitor and report key events
    monitor_process : process(clk)
        variable last_interrupt : STD_LOGIC := '0';
        variable interrupt_count : integer := 0;
    begin
        if rising_edge(clk) then
            -- Detect rising edge of interrupt
            if interrupt_req = '1' and last_interrupt = '0' then
                interrupt_count := interrupt_count + 1;
                report "INTERRUPT #" & integer'image(interrupt_count) & 
                        " detected at test_phase=" & integer'image(test_phase) & 
                        ", bit_index=" & integer'image(bit_index) severity WARNING;
            end if;
            last_interrupt := interrupt_req;
            
            -- Report debounced line changes
            -- (You can add more monitoring here)
        end if;
    end process;

    -- Optional: Generate VCD waveform dump for viewing in waveform viewer
    -- Uncomment if your simulator supports it:
    -- process
    -- begin
    --     wait for CLK_PERIOD * 100000;  -- Simulate for a long time
    -- end process;

end Behavioral;
