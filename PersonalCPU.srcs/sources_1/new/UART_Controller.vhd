----------------------------------------------------------------------------------
-- UART Controller for PersonalCPU
-- Wrapper around uart_tx6 and uart_rx6 with port I/O logic
-- Port I/O Mapping:
--   - Port 0x04: UART Tx data write
--   - Port 0x07: UART Rx data read + status (bits 0-1: rx_present, tx_full)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_Controller is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_16_x_baud : in STD_LOGIC;
           tx_data : in STD_LOGIC_VECTOR(7 downto 0);
           tx_write : in STD_LOGIC;
           rx_data : out STD_LOGIC_VECTOR(7 downto 0);
           rx_read : in STD_LOGIC;
           uart_tx : out STD_LOGIC;
           uart_rx : in STD_LOGIC;
           rx_data_present : out STD_LOGIC;
           tx_full : out STD_LOGIC);
end UART_Controller;

architecture Behavioral of UART_Controller is

  component uart_tx6 is
    Port (             data_in : in std_logic_vector(7 downto 0);
                  en_16_x_baud : in std_logic;
                    serial_out : out std_logic;
                  buffer_write : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
  end component;

  component uart_rx6 is
    Port (             serial_in : in std_logic;
                  en_16_x_baud : in std_logic;
                      data_out : out std_logic_vector(7 downto 0);
                   buffer_read : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
  end component;

  signal tx_buf_data_present : std_logic;
  signal tx_buf_half_full : std_logic;
  signal tx_buf_full : std_logic;
  
  signal rx_buf_data_present : std_logic;
  signal rx_buf_half_full : std_logic;
  signal rx_buf_full : std_logic;

begin

  -- UART Transmitter
  uart_tx_inst : uart_tx6
    port map (
      data_in => tx_data,
      en_16_x_baud => en_16_x_baud,
      serial_out => uart_tx,
      buffer_write => tx_write,
      buffer_data_present => tx_buf_data_present,
      buffer_half_full => tx_buf_half_full,
      buffer_full => tx_buf_full,
      buffer_reset => reset,
      clk => clk
    );

  -- UART Receiver
  uart_rx_inst : uart_rx6
    port map (
      serial_in => uart_rx,
      en_16_x_baud => en_16_x_baud,
      data_out => rx_data,
      buffer_read => rx_read,
      buffer_data_present => rx_buf_data_present,
      buffer_half_full => rx_buf_half_full,
      buffer_full => rx_buf_full,
      buffer_reset => reset,
      clk => clk
    );

  -- Output status signals
  rx_data_present <= rx_buf_data_present;
  tx_full <= tx_buf_full;

end Behavioral;
