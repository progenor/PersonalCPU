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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity toplevel is
    Port ( clk_in : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (3 downto 0);
           psdata : in std_logic;
           psclock : in std_logic;
           LEDsw : in std_logic;
           Db : out STD_LOGIC_VECTOR (7 downto 0);
           Rs : out STD_LOGIC;
           Rw : out STD_LOGIC;
           E : out STD_LOGIC;
           reset : in std_logic;
           
           UART_TX : out STD_LOGIC
           --UART_RX : in STD_LOGIC
         );
end toplevel;

architecture Behavioral of toplevel is

component kcpsm6 is
  generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                  interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
           scratch_pad_memory_size : integer := 64);
  port (                   address : out std_logic_vector(11 downto 0);
                       instruction : in std_logic_vector(17 downto 0);
                       bram_enable : out std_logic;
                           in_port : in std_logic_vector(7 downto 0);
                          out_port : out std_logic_vector(7 downto 0);
                           port_id : out std_logic_vector(7 downto 0);
                      write_strobe : out std_logic;
                    k_write_strobe : out std_logic;
                       read_strobe : out std_logic;
                         interrupt : in std_logic;
                     interrupt_ack : out std_logic;
                             sleep : in std_logic;
                             reset : in std_logic;
                               clk : in std_logic);
  end component;
  
  component prog_memory is
  generic(             C_FAMILY : string := "7S"; 
              C_RAM_SIZE_KWORDS : integer := 2;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (       address : in std_logic_vector(11 downto 0);
           instruction : out std_logic_vector(17 downto 0);
                enable : in std_logic;
                   rdl : out std_logic;                    
                   clk : in std_logic);
  end component;
  
  component uart_tx6 is
    port (               data_in : in std_logic_vector(7 downto 0);
                    en_16_x_baud : in std_logic;
                      serial_out : out std_logic;
                    buffer_write : in std_logic;
             buffer_data_present : out std_logic;
                buffer_half_full : out std_logic;
                     buffer_full : out std_logic;
                    buffer_reset : in std_logic;
                             clk : in std_logic);
  end component;


  signal address : std_logic_vector(11 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal portid : std_logic_vector(7 downto 0);
  signal inport : std_logic_vector(7 downto 0);
  signal outport : std_logic_vector(7 downto 0);
  signal wrstr : std_logic;
  signal rdstr : std_logic;
  signal bren : std_logic;
  signal clk : std_logic;
  
    signal interrupt_ack: std_logic;
    signal  interrupt_req  : std_logic :='0';

    signal clk_count, data_count: std_logic_vector(4 downto 0) := (others => '0');
    signal ps2_clk_clean, ps2_data_clean : std_logic := '1';
    signal clk_inter, data_inter : std_logic := '1';
    
    signal data_Db    : std_logic_vector(7 downto 0) := x"00";
    signal data_cntrl : std_logic_vector(2 downto 0) := "000";
    
    signal psdatabuff : std_logic_vector(7 downto 0);
    signal lcd_data_buff : std_logic_vector(7 downto 0);
    signal lcd_control_buff : std_logic_vector(2 downto 0);
    

    signal baud_count : integer range 0 to 67 := 0; 
    signal en_16_x_baud : std_logic := '0';
    signal uart_tx_buffer_full : std_logic;
    signal write_to_uart_tx : std_logic;
    
begin
    clk <= clk_in; 


processzor : kcpsm6
generic map (
   hwbuild => x"00",
   interrupt_vector => x"3ff",
   scratch_pad_memory_size => 64
)
port map (
                         address =>  address,
                       instruction =>  instruction,
                       bram_enable =>  bren,
                           in_port =>  inport,
                          out_port =>  outport,
                           port_id =>  portid,
                      write_strobe =>  wrstr,
                    k_write_strobe =>  open,
                       read_strobe =>  rdstr,
                         interrupt =>  interrupt_req,
                     interrupt_ack =>  interrupt_ack,
                             sleep =>  '0',
                             reset =>  reset,
                               clk =>  clk

);

 memoria: prog_memory
  generic map(             C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(       address => address,
           instruction => instruction,
                enable => bren,
                   rdl => open,                    
                   clk => clk
);



baud_rate_gen: process(clk)
begin
    if rising_edge(clk) then
        if baud_count = 67 then
            baud_count <= 0;
            en_16_x_baud <= '1';
        else
            baud_count <= baud_count + 1;
            en_16_x_baud <= '0';
        end if;
    end if;
end process baud_rate_gen;

write_to_uart_tx <= '1' when (wrstr = '1' and portid = x"05") else '0';

tx_macro: uart_tx6
    port map (
        data_in             => outport,
        en_16_x_baud        => en_16_x_baud,
        serial_out          => UART_TX,
        buffer_write        => write_to_uart_tx,
        buffer_data_present => open,
        buffer_half_full    => open,
        buffer_full         => uart_tx_buffer_full,
        buffer_reset        => reset,
        clk                 => clk
    );


process(clk)
   begin
      if(rising_edge(clk)) then
         if(psclock /= clk_inter) then
            clk_inter <= psclock;
            clk_count <= (others => '0');
         elsif(clk_count = "11111") then
             ps2_clk_clean <= clk_inter;
         else
             clk_count <= clk_count + 1;
         end if;
      end if;
   end process;


process(clk)
   begin
      if(rising_edge(clk)) then
         if(psdata /= data_inter) then
            data_inter <= psdata;
            data_count <= (others => '0');
         elsif(data_count = "11111") then
             ps2_data_clean <= data_inter;
         else
             data_count <= data_count + 1;
         end if;
      end if;
   end process;
   
  
readmux_ps2_prg: process(clk)
begin
if clk'event and clk='0' then
    if rdstr='1' and portid=x"00" then
        inport(7) <= ps2_data_clean;
        inport(6 downto 0) <= "0000000";    
    end if;    
end if;
      
end process readmux_ps2_prg;


writemux_ps2_prg: process(clk)
begin
if clk'event and clk='0' then

    if wrstr='1' and portid=x"00" then
        psdatabuff <= outport;
    end if;    

    if wrstr='1' and portid=x"3" then
        data_Db <= outport;
       lcd_data_buff <= outport;
    end if;    

    if wrstr='1' and portid=x"4" then
       data_cntrl  <= outport(2 downto 0); 
       lcd_control_buff <= outport(2 downto 0);
    end if;
     
end if;
        Db <= data_Db;
        Rs <= data_cntrl(0);
        Rw <= data_cntrl(1);
        E  <= data_cntrl(2);
end process writemux_ps2_prg;

    led <=psdatabuff(3 downto 0) when
    LEDsw = '0' 
    else psdatabuff(7 downto 4);
    
interrupt_control: process(clk)
variable psclk_prev :std_logic:='0';
begin
if clk'event and clk='1' then
    if interrupt_ack='1' then
        interrupt_req <= '0';
    elsif psclk_prev='1' and ps2_clk_clean ='0' then 
        interrupt_req<='1';
    else
        interrupt_req<=interrupt_req;
    end if;
    psclk_prev:=ps2_clk_clean;
end if;
end process interrupt_control;

end Behavioral;