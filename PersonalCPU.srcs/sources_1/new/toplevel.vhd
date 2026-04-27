----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2022 08:50:12 AM
-- Design Name: 
-- Module Name: toplevel - Behavioral
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

entity toplevel is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
--           sw1 : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (3 downto 0);
           reset : in STD_LOGIC;
           psclock : in STD_LOGIC;                     -- PS/2 keyboard clock (T11)
           psdata : in STD_LOGIC;                      -- PS/2 keyboard data (W14)
           -- LCD Interface
           Db : out STD_LOGIC_VECTOR(7 downto 0);     -- LCD data bus (PmodA Y18-W19)
           Rs : out STD_LOGIC;                         -- Register select (V16)
           Rw : out STD_LOGIC;                         -- Read/Write (W16)
           E : out STD_LOGIC;                          -- Enable (V12)
           -- UART Interface
           uart_tx : out STD_LOGIC;                    -- UART transmit
           uart_rx : in STD_LOGIC);                    -- UART receive
end toplevel;

architecture Behavioral of toplevel is

  component CPU is
    Port ( clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           PortDataIn : in STD_LOGIC_VECTOR (15 downto 0);
           interrupt : in STD_LOGIC;
           instruction : in STD_LOGIC_VECTOR (17 downto 0);
           PortDataOut : out STD_LOGIC_VECTOR (15 downto 0);
           PortID : out STD_LOGIC_VECTOR (7 downto 0);
           ReadStrobe : out STD_LOGIC;
           WriteStrobe : out STD_LOGIC;
           interrupt_Acknowledge : out STD_LOGIC;
           instruction_Address : out STD_LOGIC_VECTOR (11 downto 0));
end component;
  
  component PS2_Controller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        ps2_clk : in STD_LOGIC;
        ps2_data : in STD_LOGIC;
        ps2_clk_clean : out STD_LOGIC;
        ps2_data_clean : out STD_LOGIC;
        interrupt_req : out STD_LOGIC
    );
  end component;
  
  component LCD_Controller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        write_en : in STD_LOGIC;
        rs_flag : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(7 downto 0);
        lcd_data : out STD_LOGIC_VECTOR(7 downto 0);
        lcd_rs : out STD_LOGIC;
        lcd_rw : out STD_LOGIC;
        lcd_e : out STD_LOGIC;
        busy : out STD_LOGIC
    );
  end component;
  
  component UART_BaudRate_Gen is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_16_x_baud : out STD_LOGIC);
  end component;
  
  component UART_Controller is
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
  end component;
  
  component memoria is
  generic(             C_FAMILY : string := "7S"; 
              C_RAM_SIZE_KWORDS : integer := 2;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end component;

  -- CPU and memory signals
  signal address : std_logic_vector(11 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal portid : std_logic_vector(7 downto 0);
  signal inport : std_logic_vector(15 downto 0);
  signal outport : std_logic_vector(15 downto 0);
  signal wrstr : std_logic;
  signal rdstr : std_logic;
  signal bren : std_logic;
  
  -- PS/2 controller signals
  signal ps2_clk_clean : std_logic;
  signal ps2_data_clean : std_logic;
  signal ps2_interrupt_req : std_logic;
  
  -- LCD controller signals
  signal lcd_write_en : std_logic;
  signal lcd_rs_flag : std_logic;
  signal lcd_data_out : std_logic_vector(7 downto 0);
  signal lcd_busy : std_logic;
  
  -- UART signals
  signal en_16_x_baud : std_logic;
  signal uart_tx_data : std_logic_vector(7 downto 0);
  signal uart_tx_write : std_logic;
  signal uart_rx_data : std_logic_vector(7 downto 0);
  signal uart_rx_read : std_logic;
  signal uart_rx_data_present : std_logic;
  signal uart_tx_full : std_logic;

begin

process(clk,wrstr,portid)
begin
if clk'event and clk='1' then
if wrstr='1' and portid=x"06" then
    led<=outport(3 downto 0);
elsif wrstr='1' and portid=x"04" then
    -- UART Tx data write
    uart_tx_data <= outport(7 downto 0);
    uart_tx_write <= '1';
else
    uart_tx_write <= '0';
end if;
end if;
end process;

process(clk,rdstr,portid)
begin
if clk'event and clk='1' then
if rdstr='1' and portid=x"05" then
     inport<="000000000000"&btn;
--    inport<="00000000000"&sw1&btn;
elsif rdstr='1' and portid=x"01" then
     -- PS/2 data read at port 0x01
     -- PS/2 data bit packed at bit 7, rest zeros
     inport<="000000000000000"&ps2_data_clean;
elsif rdstr='1' and portid=x"07" then
     -- UART Rx status at port 0x07
     -- bit 0: rx_data_present, bit 1: tx_full
     inport<="00000000000000"&uart_tx_full&uart_rx_data_present;
elsif rdstr='1' and portid=x"04" then
     -- UART Rx data at port 0x04
     inport<="00000000"&uart_rx_data;
end if;
end if;
end process;

-- LCD Port Mux (Port 0x02 = command, Port 0x03 = data)
process(clk, wrstr, portid)
begin
    if clk'event and clk='1' then
        lcd_write_en <= '0';
        if wrstr='1' then
            if portid=x"02" then        -- LCD command (Rs=0)
                lcd_data_out <= outport(7 downto 0);
                lcd_rs_flag <= '0';
                lcd_write_en <= '1';
            elsif portid=x"03" then     -- LCD data (Rs=1)
                lcd_data_out <= outport(7 downto 0);
                lcd_rs_flag <= '1';
                lcd_write_en <= '1';
            end if;
        end if;
    end if;
end process;

-- UART Rx read pulse (triggered by read strobe on port 0x04)
process(clk, rdstr, portid)
begin
    if clk'event and clk='1' then
        uart_rx_read <= '0';
        if rdstr='1' and portid=x"04" then
            uart_rx_read <= '1';
        end if;
    end if;
end process;


processor : CPU
port map (
         instruction_Address =>  address,
       instruction =>  instruction,
           PortDataIn =>  inport,
          PortDataOut =>  outport,
           PortID =>  portid,
      WriteStrobe =>  wrstr,
       ReadStrobe =>  rdstr,
         interrupt =>  ps2_interrupt_req,
     interrupt_Acknowledge =>  open,
             Reset =>  reset,
               clk =>  clk
);

-- PS/2 Keyboard Controller Instantiation
ps2_ctrl : PS2_Controller
port map (
         clk =>  clk,
         reset =>  reset,
         ps2_clk =>  psclock,
         ps2_data =>  psdata,
         ps2_clk_clean =>  ps2_clk_clean,
         ps2_data_clean =>  ps2_data_clean,
         interrupt_req =>  ps2_interrupt_req
);

-- LCD Controller Instantiation
lcd_ctrl : LCD_Controller
port map (
         clk => clk,
         reset => reset,
         write_en => lcd_write_en,
         rs_flag => lcd_rs_flag,
         data_in => lcd_data_out,
         lcd_data => Db,
         lcd_rs => Rs,
         lcd_rw => Rw,
         lcd_e => E,
         busy => lcd_busy
);

-- UART Baud Rate Generator Instantiation
uart_baud_gen : UART_BaudRate_Gen
port map (
         clk => clk,
         reset => reset,
         en_16_x_baud => en_16_x_baud
);

-- UART Controller Instantiation
uart_ctrl : UART_Controller
port map (
         clk => clk,
         reset => reset,
         en_16_x_baud => en_16_x_baud,
         tx_data => uart_tx_data,
         tx_write => uart_tx_write,
         rx_data => uart_rx_data,
         rx_read => uart_rx_read,
         uart_tx => uart_tx,
         uart_rx => uart_rx,
         rx_data_present => uart_rx_data_present,
         tx_full => uart_tx_full
);

 mem: memoria
  generic map(C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(      address => address,
          instruction => instruction,
               enable => '1',
                  rdl => open,                   
                  clk => clk
);


end Behavioral;