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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
    Port ( clk_in : in STD_LOGIC;
           --btn : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0);
		   psdata : in std_logic;
		   psclock : in std_logic;
		   LEDsw : in std_logic;
		   reset : in std_logic;
           DB:	out std_logic_vector(7 downto 0);		        --output bus, used for data transfer
		   RS:	out std_logic;  								--register selection pin
		   RW:	out std_logic;									--selects between read/write modes
		   E:	out std_logic									--enable signal for starting the data 		   
		   --Tx : out std_logic
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
  
 component memoria is
 -- component testbreak is
  generic(             C_FAMILY : string := "7S"; 
              C_RAM_SIZE_KWORDS : integer := 2;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end component;
  
  component clk_div is
    Port ( clk : in STD_LOGIC;
           clk_div : out STD_LOGIC;
           reset : in STD_LOGIC
           );
end component;

--COMPONENT uart_tx6

--  Port (             data_in : in std_logic_vector(7 downto 0);
--                en_16_x_baud : in std_logic;
--                  serial_out : out std_logic;
--                buffer_write : in std_logic;
--         buffer_data_present : out std_logic;
--            buffer_half_full : out std_logic;
--                 buffer_full : out std_logic;
--                buffer_reset : in std_logic;
--                         clk : in std_logic);
--END COMPONENT;
  

  signal address : std_logic_vector(11 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal portid : std_logic_vector(7 downto 0);
  signal inport : std_logic_vector(7 downto 0);
  signal outport : std_logic_vector(7 downto 0);
  signal wrstr : std_logic;
  signal rdstr : std_logic;
  signal bren : std_logic;
  signal clk : std_logic;
  
  signal addr_ps2 : std_logic_vector(9 downto 0);
	signal instr_ps2 : std_logic_vector(17 downto 0);
	signal out_port_ps2_prg, in_port_ps2_prg, port_id_ps2_prg : std_logic_vector(7 downto 0);
	signal read_strobe_ps2_prg, write_strobe_ps2_prg, interrupt_ack, interrupt_req : std_logic;
	signal ps2c : std_logic;
	

	signal clk_count, data_count: std_logic_vector(5 downto 0);
	signal ps2_clk_clean, ps2_clk_s, ps2_data_clean, ps2_data_s : std_logic;
	signal clk_inter, data_inter : std_logic := '1';
	
	signal psdatabuff : std_logic_vector(7 downto 0);

	signal status_register : std_logic_vector(7 downto 0);
	signal write_uart_word, baudclk, uart_tx_full, uart_tx_half : std_logic;

begin

inst_clkdiv: clk_div 
    Port Map( clk => clk_in,
           clk_div => clk,
           reset => reset
           );

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
                         
--Inst_uart_tx: uart_tx6 PORT MAP(
--	   --adat bemenet 
--		data_in => out_port_ps2_prg, -- PicoBl adat kimenete
--		-- START jel
--		buffer_write => write_uart_word,  -- OUTPUT serialdata, 61
--		-- Soros küldés órajele
--		en_16_x_baud => baudclk,   -- clkdivider kimenete
--		-- Soros kimenet a PC fele
--		serial_out => Tx,
--		buffer_reset => reset,
--		-- Status jelek:
--		buffer_full => uart_tx_full, -- Ha ez nulla, akkor van hely a buffer-ben, mehet a Start
--											-- Ha ez egyes, akkor nincs hely a buffer-ben, NEM mehet a Start
--		buffer_half_full => uart_tx_half,
--		clk => clk
--	);

mem: memoria
-- mem: testbreak
  generic map(             C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(      address => address,
          instruction => instruction,
               enable => bren,
                  rdl => open,                   
                  clk => clk);

-- START jel megadása PicoBlaze utasítással
   write_uart_word <= '1' when (port_id_ps2_prg = x"61") and (write_strobe_ps2_prg ='1') else '0';  -- Start sending UART Tx data
																																    -- OUTPUT SerialData, 61

	status_register(7 downto 2) <= "000000";
	status_register(1)<= uart_tx_full; --uart full ha x02
	status_register(0)<= uart_tx_half; --uart half x01
	--	00000010  - 02
	--	   AND
	--	xxxxxxxx --> status_reg
	-- ________
	-- 000000x0  = 02  ---> x=1
	-- 000000x0  = 00  ---> x=0
	-- TEST status_reg, 02

process(clk)
   begin
      if(rising_edge(clk)) then
         -- if the current bit on ps2_data is different
         -- from the last value, then reset counter
         -- and retain value
         if(psclock /= clk_inter) then
            clk_inter <= psclock;
            clk_count <= (others => '0');
         -- if counter reached upper limit, then
         -- the signal is clean
         elsif(clk_count = "111111") then
            ps2_clk_clean <= clk_inter;
         -- ps2_data did not change, but counter did not
         -- reach limit. Increment counter
         else
            clk_count <= clk_count + 1;
         end if;
      end if;
   end process;


process(clk)
   begin
      if(rising_edge(clk)) then
         -- if the current bit on ps2_data is different
         -- from the last value, then reset counter
         -- and retain value
         if(psdata /= data_inter) then
            data_inter <= psdata;
            data_count <= (others => '0');
         -- if counter reached upper limit, then
         -- the signal is clean
         elsif(data_count = "111111") then
            ps2_data_clean <= data_inter;
         -- ps2_data did not change, but counter did not
         -- reach limit. Increment counter
         else
            data_count <= data_count + 1;
         end if;
      end if;
   end process;
   
   -- Synchronize ps2 entries
   ps2_clk_s <= ps2_clk_clean when rising_edge(clk);
	ps2_data_s <= ps2_data_clean when rising_edge(clk);
  
readmux_ps2_prg: process(clk, rdstr,portid)
--variable datain : std_logic:='0';
begin
if clk'event and clk='1' then

	if rdstr='1' and portid=x"01" then	
		inport(7) <= ps2_data_clean; --ps2_data_s;
		inport(6 downto 0) <= "0000000";	
	end if;	
	
	if rdstr='1' and portid=x"02" then
		inport <= status_register;	-- Read UART Tx status    INPUT status_reg, 02
	end if;		

end if;
      
end process readmux_ps2_prg;


writemux_ps2_prg: process(clk, wrstr,portid)
variable data_Db : std_logic_vector(7 downto 0);
variable data_cntrl : std_logic_vector(2 downto 0);

begin
if clk'event and clk='1' then

	if wrstr='1' and portid=x"00" then
		psdatabuff <= outport;
	end if;	

	if wrstr='1' and portid=x"04" then
		data_cntrl := outport(2 downto 0);
	end if;

	if wrstr='1' and portid=x"03" then
		data_Db := outport;
	end if;
end if;
		Db <= data_Db;
		Rs <= data_cntrl(2);
		Rw <= data_cntrl(1);
		E  <= data_cntrl(0);
end process writemux_ps2_prg;

 led <= psdatabuff(3 downto 0) when LEDsw = '0' else psdatabuff(7 downto 4);
    
    
interrupt_control: process(clk)
variable psclk_prev :std_logic:='0';
begin
if clk'event and clk='1' then
	if interrupt_ack='1' then
		interrupt_req <= '0';
	elsif psclk_prev='1' and ps2_clk_clean='0' then 
	--elsif psclk_prev='1' and ps2_clk_s='0' then 
		interrupt_req<='1';
	else
		interrupt_req<=interrupt_req;
	end if;
	--psclk_prev:=ps2_clk_s;
	psclk_prev:=ps2_clk_clean;
end if;
end process interrupt_control;
end Behavioral;
