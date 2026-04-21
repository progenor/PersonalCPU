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
           led : out STD_LOGIC_VECTOR (3 downto 0));
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
  
  component test is
  generic(             C_FAMILY : string := "7S"; 
              C_RAM_SIZE_KWORDS : integer := 2;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
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

begin

process(clk,wrstr,portid) -- write 
begin
if clk'event and clk='1' then
if wrstr='1' and portid=x"05" then  -- OUTPUT s0, 05
    led<=outport(3 downto 0);
end if;
end if;
end process;

process(clk,rdstr,portid)  -- read
begin
if clk'event and clk='1' then
if rdstr='1' and portid=x"06" then  -- INPUT s0, 06
    inport<="0000"&btn;
end if;
end if;
end process;


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
                         interrupt =>  '0',
                     interrupt_ack =>  open,
                             sleep =>  '0',
                             reset =>  '0',
                               clk =>  clk
);

 memoria: test
  generic map(             C_FAMILY => "7S", 
              C_RAM_SIZE_KWORDS => 2,
           C_JTAG_LOADER_ENABLE => 0)
  Port map(      address => address,
          instruction => instruction,
               enable => bren,
                  rdl => open,                   
                  clk => clk
);


end Behavioral;
