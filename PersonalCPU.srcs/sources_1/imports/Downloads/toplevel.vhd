----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/20/2022 08:50:12 AM
-- Design Name: 
-- Module Name: toplevel - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity toplevel is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
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

 component prog_memory is
  generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
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

  signal address : std_logic_vector(11 downto 0);
  signal instruction : std_logic_vector(17 downto 0);
  signal portid : std_logic_vector(7 downto 0);
  signal inport : std_logic_vector(15 downto 0);
  signal outport : std_logic_vector(15 downto 0);
  signal wrstr : std_logic;
  signal rdstr : std_logic;
  signal bren : std_logic;

  signal interrupt_ack: std_logic;
  signal interrupt_req  : std_logic :='0';
    
  signal clk_count, data_count: std_logic_vector(4 downto 0);
  signal ps2_clk_clean, ps2_data_clean : std_logic;
  signal clk_inter, data_inter : std_logic;
    
  signal psdatabuff : std_logic_vector(7 downto 0);
  signal lcd_data_buff : std_logic_vector(7 downto 0);
  signal lcd_control_buff : std_logic_vector(2 downto 0);

begin

-- ==========================================
-- UNIFIED READ MULTIPLEXER
-- Combines both PS2 and Button reads to avoid multiple drivers
-- ==========================================
process(clk)  
begin
    if rising_edge(clk) then
        if rdstr='1' then
            if portid = x"06" then  -- INPUT s0, 06 (Buttons)
                -- Pad 12 zeros to the 4-bit button signal to make 16 bits
                inport <= "000000000000" & btn;
                
            elsif portid = x"00" then -- PS2 Read
                -- Pad upper 8 bits with 0, set bit 7 to PS2 data, rest 0
                inport(15 downto 8) <= x"00";
                inport(7) <= ps2_data_clean;
                inport(6 downto 0) <= "0000000";
            end if;
        end if;
    end if;
end process;

-- ==========================================
-- UNIFIED WRITE MULTIPLEXER
-- ==========================================
process(clk)
begin
    if rising_edge(clk) then
        if wrstr='1' then
            if portid = x"00" then
                -- Slice the 16-bit outport to 8 bits for the buffer
                psdatabuff <= outport(7 downto 0);
            end if;    

            if portid = x"03" then
                -- Slice the 16-bit outport to 8 bits for the LCD buffer
                lcd_data_buff <= outport(7 downto 0);
            end if;    

            if portid = x"04" then
                -- Slice the 16-bit outport to 3 bits for LCD control
                lcd_control_buff <= outport(2 downto 0);
            end if;
            
            -- Note: Removed port x"05" writing directly to `led` here 
            -- because `led` is driven by a concurrent assignment below.
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
                 interrupt =>  btn(0),
     interrupt_Acknowledge =>  interrupt_ack, -- Fixed: Hooked this up!
                     Reset =>  '0',
                       clk =>  clk
);

 mem: prog_memory
  generic map(C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(      address => address,
          instruction => instruction,
               enable => '1',
                  rdl => open,                    
                  clk => clk
);

-- PS2 Clock Debouncing
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

-- PS2 Data Debouncing
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

-- Concurrent Assignments
    led <= psdatabuff(3 downto 0) when LEDsw = '0' else psdatabuff(7 downto 4);
       
    lcd_data <= lcd_data_buff;
    lcd_control <= lcd_control_buff; 
    
    test_clk <= clk;
    
-- Interrupt Controller
interrupt_control: process(clk)
variable psclk_prev :std_logic:='0';
begin
if rising_edge(clk) then
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