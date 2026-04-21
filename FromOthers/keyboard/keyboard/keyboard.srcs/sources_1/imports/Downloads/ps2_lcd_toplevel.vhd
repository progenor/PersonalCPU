library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity toplevel is
    Port ( clk_in      : in STD_LOGIC;
           led         : out STD_LOGIC_VECTOR (3 downto 0);
           psdata      : in std_logic;
           psclock     : in std_logic;
           LEDsw       : in std_logic;
           lcd_data    : out STD_LOGIC_VECTOR (7 downto 0);
           lcd_control : out STD_LOGIC_VECTOR (2 downto 0);
           test_clk    : out std_logic;
           reset       : in std_logic
         );
end toplevel;

architecture Behavioral of toplevel is

  component clock_divider is
    Port ( clk_in  : in STD_LOGIC;
           clk_out : out STD_LOGIC;
           reset   : in STD_LOGIC
         );
  end component;

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

  -- Itt hivatkozunk a kigenerált memória fájlodra
  component prog_memory is
    generic(             C_FAMILY : string := "7S"; 
                C_RAM_SIZE_KWORDS : integer := 2;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;

  signal address       : std_logic_vector(11 downto 0);
  signal instruction   : std_logic_vector(17 downto 0);
  signal portid        : std_logic_vector(7 downto 0);
  signal inport        : std_logic_vector(7 downto 0);
  signal outport       : std_logic_vector(7 downto 0);
  signal wrstr         : std_logic;
  signal rdstr         : std_logic;
  signal bren          : std_logic;
  signal clk           : std_logic;

  signal interrupt_ack : std_logic;
  signal interrupt_req : std_logic := '0';

  signal clk_count, data_count : std_logic_vector(4 downto 0);
  signal ps2_clk_clean, ps2_data_clean : std_logic;
  signal clk_inter, data_inter : std_logic;

  signal psdatabuff       : std_logic_vector(7 downto 0);
  signal lcd_data_buff    : std_logic_vector(7 downto 0);
  signal lcd_control_buff : std_logic_vector(2 downto 0);

begin

  -- Órajelosztó példányosítása
--  inst_clkdiv: clock_divider
--    Port Map(
--      clk_in  => clk_in,
--      clk_out => clk,
--      reset   => reset
--    );
  clk <= clk_in;
  -- Processzor példányosítása
  processzor : kcpsm6
    generic map (
      hwbuild => x"00",
      interrupt_vector => x"3ff",
      scratch_pad_memory_size => 64
    )
    port map (
      address       => address,
      instruction   => instruction,
      bram_enable   => bren,
      in_port       => inport,
      out_port      => outport,
      port_id       => portid,
      write_strobe  => wrstr,
      k_write_strobe=> open,
      read_strobe   => rdstr,
      interrupt     => interrupt_req,
      interrupt_ack => interrupt_ack,
      sleep         => '0',
      reset         => reset,
      clk           => clk
    );

  -- Memória példányosítása
  memoria: prog_memory
    generic map(
      C_FAMILY => "7S", 
      C_RAM_SIZE_KWORDS => 2,
      C_JTAG_LOADER_ENABLE => 0
    )
    Port map(
      address     => address,
      instruction => instruction,
      enable      => bren,
      rdl         => open,                    
      clk         => clk
    );

  -- PS2 Clock pergésmentesítő (Debounce)
  process(clk)
  begin
     if rising_edge(clk) then
        if psclock /= clk_inter then
           clk_inter <= psclock;
           clk_count <= (others => '0');
        elsif clk_count = "11111" then
           ps2_clk_clean <= clk_inter;
        else
           clk_count <= clk_count + 1;
        end if;
     end if;
  end process;

  -- PS2 Data pergésmentesítő (Debounce)
  process(clk)
  begin
     if rising_edge(clk) then
        if psdata /= data_inter then
           data_inter <= psdata;
           data_count <= (others => '0');
        elsif data_count = "11111" then
           ps2_data_clean <= data_inter;
        else
           data_count <= data_count + 1;
        end if;
     end if;
  end process;

  -- Bemeneti Multiplexer (Input Port MUX)
  readmux_ps2_prg: process(clk)
  begin
    if falling_edge(clk) then
        if rdstr = '1' and portid = x"00" then
            inport(7) <= ps2_data_clean;
            inport(6 downto 0) <= "0000000";    
        end if;    
    end if;
  end process readmux_ps2_prg;

  -- Kimeneti Multiplexer (Output Port MUX)
  writemux_ps2_prg: process(clk)
  begin
    if falling_edge(clk) then
        -- Írás a 00-s portra (LED bufferek)
        if wrstr = '1' and portid = x"00" then
            psdatabuff <= outport;
        end if;    
        
        -- Írás az LCD adat portra
        if wrstr = '1' and portid = x"03" then
            lcd_data_buff <= outport;
        end if;    

        -- Írás az LCD kontroll portra
        if wrstr = '1' and portid = x"04" then
             lcd_control_buff <= outport(2 downto 0);
        end if;
    end if;
  end process writemux_ps2_prg;

  -- LED kapcsoló logika
  led <= psdatabuff(3 downto 0) when LEDsw = '0' else psdatabuff(7 downto 4);
       
  -- LCD jelek kiküldése
  lcd_data <= lcd_data_buff;
  lcd_control <= lcd_control_buff; 
  
  -- Teszt órajel kiküldése
  test_clk <= clk;
    
  -- Megszakítás (Interrupt) Generátor
  interrupt_control: process(clk)
    variable psclk_prev : std_logic := '0';
  begin
    if rising_edge(clk) then
        if interrupt_ack = '1' then
            interrupt_req <= '0';
        elsif psclk_prev = '1' and ps2_clk_clean = '0' then 
            interrupt_req <= '1';
        end if;
        psclk_prev := ps2_clk_clean;
    end if;
  end process interrupt_control;

end Behavioral;