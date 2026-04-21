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
           psdata : in STD_LOGIC);                     -- PS/2 keyboard data (W14)
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

begin

process(clk,wrstr,portid)
begin
if clk'event and clk='1' then
if wrstr='1' and portid=x"06" then
    led<=outport(3 downto 0);
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