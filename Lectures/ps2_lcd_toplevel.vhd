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
		   lcd_data: out STD_LOGIC_VECTOR (7 downto 0);
		   lcd_control : out STD_LOGIC_VECTOR (2 downto 0);
		   test_clk :out std_logic;
		   reset : in std_logic
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
  
  component MyPS2 is
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
    Port ( clk_in : in STD_LOGIC;
           clk_div : out STD_LOGIC;
           reset : in STD_LOGIC
           );
end component;


--component clk_div is
--port
-- (-- Clock in ports
--  clkfb_in          : in     std_logic;
--  -- Clock out ports
--  clk_div          : out    std_logic;
--  clkfb_out         : out    std_logic;
--  -- Status and control signals
--  reset             : in     std_logic;
--  locked            : out    std_logic;
--  clk_in           : in     std_logic
-- );
--end component;
  

  signal address : std_logic_vector(11 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal portid : std_logic_vector(7 downto 0);
  signal inport : std_logic_vector(7 downto 0);
  signal outport : std_logic_vector(7 downto 0);
  signal wrstr : std_logic;
  signal rdstr : std_logic;
  signal bren : std_logic;
  signal clk : std_logic;
  
  
 -- signal addr_ps2 : std_logic_vector(9 downto 0);
--	signal instr_ps2 : std_logic_vector(17 downto 0);
--	signal out_port_ps2_prg, in_port_ps2_prg, port_id_ps2_prg : std_logic_vector(7 downto 0);
--	signal read_strobe_ps2_prg, write_strobe_ps2_prg,
    signal interrupt_ack: std_logic;
	signal  interrupt_req  : std_logic :='0';
--	signal ps2c : std_logic;
	

	signal clk_count, data_count: std_logic_vector(4 downto 0);
	signal ps2_clk_clean, ps2_data_clean : std_logic;
--	signal  ps2_clk_s, ps2_data_s : std_logic;
	signal clk_inter, data_inter : std_logic;
	
	signal psdatabuff : std_logic_vector(7 downto 0);
    signal lcd_data_buff : std_logic_vector(7 downto 0);
    signal lcd_control_buff : std_logic_vector(2 downto 0);
    
    
    
begin

inst_clkdiv: clk_div 
    Port Map( clk_in => clk_in,
           clk_div => clk,
           reset => reset
           );
           
           
--   inst_clkdiv: clk_div        
--      port map (         
--      clkfb_in => clkfb_in,        
--     -- Clock out ports          
--      clk_div => clk_div,        
--      clkfb_out => clkfb_out,        
--     -- Status and control signals                        
--      reset => reset,        
--      locked => locked,        
--      -- Clock in ports        
--      clk_in => clk_in        
--    );        
           
           
           
--process(clk,wrstr,portid)
--begin
--if clk'event and clk='1' then
--if wrstr='1' and portid=x"00" then
--    led<=outport(3 downto 0);
--end if;
--end if;
--end process;

--process(clk,rdstr,portid)
--begin
--if clk'event and clk='1' then
--if rdstr='1' and portid=x"00" then
--    inport<="0000"&btn;
--end if;
--end if;
--end process;


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

 memoria: MyPS2
  generic map(             C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(      address => address,
          instruction => instruction,
               enable => bren,
                  rdl => open,                   
                  clk => clk
);


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
         elsif(clk_count = "11111") then
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
         elsif(data_count = "11111") then
            ps2_data_clean <= data_inter;
         -- ps2_data did not change, but counter did not
         -- reach limit. Increment counter
         else
            data_count <= data_count + 1;
         end if;
      end if;
   end process;
   
   -- Synchronize ps2 entries
--  ps2_clk_s <= ps2_clk_clean when rising_edge(clk);
--  ps2_data_s <= ps2_data_clean when rising_edge(clk);
  
readmux_ps2_prg: process(clk)
--variable datain : std_logic:='0';
begin
if clk'event and clk='0' then

	--if read_strobe_ps2='1' and port_id_ps2_prg=x"00" then
	if rdstr='1' and portid=x"00" then
		--datain:=PSdata;	
--		inport(7) <= ps2_data_s;
		inport(7) <= ps2_data_clean;
		inport(6 downto 0) <= "0000000";	
	end if;	

end if;
      
end process readmux_ps2_prg;


writemux_ps2_prg: process(clk)
--variable data_Db : std_logic_vector(7 downto 0);
--variable data_cntrl : std_logic_vector(2 downto 0);
--variable data_leds : std_logic_vector(7 downto 0);
--variable psdatabuff : std_logic_vector(7 downto 0);
begin
if clk'event and clk='0' then

	if wrstr='1' and portid=x"00" then
		--data_Db := outport;
		psdatabuff <= outport;
	end if;	
--if LEDsw = '0' then
--    led <= psdatabuff(3 downto 0);
--   else 
--        led <= psdatabuff(7 downto 4);
--   end if;
--	if wrstr='1' and portid=x"01" then
--		data_cntrl := outport(2 downto 0);
--	end if;

--	if wrstr='1' and outport=x"02" then
--		data_leds := outport;
--	end if;

    if wrstr='1' and portid=x"3" then
	--	data_Db <= outport;
	lcd_data_buff <= outport;
	--lcd_data <= outport;
	--	LCD_data <= data_Db;
	--psdatabuff <= outport;
	end if;	


--    led <= psdatabuff(3 downto 0);
--   else 
--        led <= psdatabuff(7 downto 4);
--   end if;

	if wrstr='1' and portid=x"4" then
	--	data_cntrl  <= outport(2 downto 0);
	--	LCd_control <= data_cntrl;
	 lcd_control_buff <= outport(2 downto 0);
	-- lcd_control <= outport(2 downto 0);
	end if;

 -- if wrstr = '1' then

        -- Write to output_port_w at port address 01 hex
--        if portid=x"00" then
        --  LEDs <=out_port(3 downto 0);
--        psdatabuff <= outport;
--	    end if;

        -- Write to output_port_x at port address 02 hex
 --       if  portid=x"03" then
  --      lcd_data <= outport;
  --      end if;

        -- Write to output_port_y at port address 04 hex
  --      if  portid(2)=1 then
  --      lcd_control <= outport(2 downto 0);
   --     end if;

     
end if;
--		Db <= data_Db;
--		Rs <= data_cntrl(0);
--		Rw <= data_cntrl(1);
--		E  <= data_cntrl(2);
--		Led0 <= data_leds(0);
--		Led1 <= data_leds(1);
--		Led2  <= data_leds(2);
--		Led3  <= data_leds(3);
--		Led4  <= data_leds(4);
--		Led5  <= data_leds(5);
--		Led6  <= data_leds(6);
--		Led7  <= data_leds(7);		
end process writemux_ps2_prg;

    led <=psdatabuff(3 downto 0) when
    LEDsw = '0' 
    else psdatabuff(7 downto 4);
       
    lcd_data <= lcd_data_buff;
    lcd_control <= lcd_control_buff; 
    
    test_clk <= clk;
    
interrupt_control: process(clk)
variable psclk_prev :std_logic:='0';
begin
if clk'event and clk='1' then
	if interrupt_ack='1' then
		interrupt_req <= '0';
--	elsif psclk_prev='1' and ps2_clk_s='0' then 
	elsif psclk_prev='1' and ps2_clk_clean ='0' then 
		interrupt_req<='1';
	else
		interrupt_req<=interrupt_req;
	end if;
--	psclk_prev:=ps2_clk_s;
    psclk_prev:=ps2_clk_clean;
end if;
end process interrupt_control;
end Behavioral;
