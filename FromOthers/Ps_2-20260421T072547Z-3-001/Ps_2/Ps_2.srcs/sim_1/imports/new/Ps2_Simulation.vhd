library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_toplevel is
end tb_toplevel;

architecture Behavioral of tb_toplevel is

    -- Unit Under Test deklaráció
    component toplevel is
        Port (
            clk_in  : in STD_LOGIC;
            led     : out STD_LOGIC_VECTOR (3 downto 0);
            psdata  : in STD_LOGIC;
            psclock : in STD_LOGIC;
            LEDsw   : in STD_LOGIC;
            reset   : in STD_LOGIC;
            Db      : out STD_LOGIC_VECTOR (7 downto 0);
            Rs      : out STD_LOGIC;
            Rw      : out STD_LOGIC;
            E       : out STD_LOGIC
        );
    end component;

    -- Jelek
    signal clk_in  : std_logic := '0';
    signal reset   : std_logic := '1';
    signal psdata  : std_logic := '1';
    signal psclock : std_logic := '1';
    signal LEDsw   : std_logic := '0';
    signal led     : std_logic_vector(3 downto 0) := (others => '0');
    signal Db      : std_logic_vector(7 downto 0) := (others => '0');
    signal Rs, Rw, E : std_logic := '0';

    constant CLK_PERIOD : time := 10 ns;
    constant PS2_PERIOD : time := 2 ms;  -- lassított PS/2 órajel szimulációhoz

    ------------------------------------------------------------------
    -- PS/2 BYTE KÜLDŐ PROCEDURE
    ------------------------------------------------------------------
    procedure send_ps2_byte(
        constant data_byte : in std_logic_vector(7 downto 0);
        signal ps_clk      : out std_logic;
        signal ps_dat      : out std_logic
    ) is
        variable parity : std_logic := '1';
    begin
        -- START bit
        ps_dat <= '0';
        wait for PS2_PERIOD/4;
        ps_clk <= '0';
        wait for PS2_PERIOD/2;
        ps_clk <= '1';
        wait for PS2_PERIOD/4;

        -- 8 adatbit (LSB first)
        for i in 0 to 7 loop
            ps_dat <= data_byte(i);
            parity := parity xor data_byte(i);
            wait for PS2_PERIOD/4;
            ps_clk <= '0';
            wait for PS2_PERIOD/2;
            ps_clk <= '1';
            wait for PS2_PERIOD/4;
        end loop;

        -- PARITY
        ps_dat <= parity;
        wait for PS2_PERIOD/4;
        ps_clk <= '0';
        wait for PS2_PERIOD/2;
        ps_clk <= '1';
        wait for PS2_PERIOD/4;

        -- STOP
        ps_dat <= '1';
        wait for PS2_PERIOD/4;
        ps_clk <= '0';
        wait for PS2_PERIOD/2;
        ps_clk <= '1';
        wait for PS2_PERIOD/4;

        -- idle szünet
        wait for PS2_PERIOD;
    end procedure;

begin

    ------------------------------------------------------------------
    -- UUT Példányosítása
    ------------------------------------------------------------------
    uut: toplevel
        port map (
            clk_in  => clk_in,
            led     => led,
            psdata  => psdata,
            psclock => psclock,
            LEDsw   => LEDsw,
            reset   => reset,
            Db      => Db,
            Rs      => Rs,
            Rw      => Rw,
            E       => E
        );

    ------------------------------------------------------------------
    -- Órajel generálás
    ------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk_in <= '0';
            wait for CLK_PERIOD/2;
            clk_in <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ------------------------------------------------------------------
    -- Stimulus: PS/2 billentyűzet
    ------------------------------------------------------------------
    stim_proc: process
    begin
        -- Kezdeti állapot
        psclock <= '1';
        psdata  <= '1';
        wait for 100 ns;

        -- Reset feloldása
        reset <= '0';
        wait for 5 ms;  -- PicoBlaze inicializáció

        ------------------------------------------------------------------
        -- TESZT 1: 'A' lenyomás
        ------------------------------------------------------------------
        report "===== TESZT 1: 'A' lenyomas =====";
        send_ps2_byte(x"1C", psclock, psdata); -- 'A' scan code
        wait for 50 ms;

        LEDsw <= '0';
        report "LED alsó nibble (CharCode)";
        wait for 5 ms;
        LEDsw <= '1';
        wait for 5 ms;

        ------------------------------------------------------------------
        -- TESZT 2: 'A' felengedés (Break code)
        ------------------------------------------------------------------
        report "===== TESZT 2: 'A' felengedés =====";
        send_ps2_byte(x"F0", psclock, psdata);
        send_ps2_byte(x"1C", psclock, psdata);
        wait for 30 ms;

        ------------------------------------------------------------------
        -- TESZT 3: 'B' lenyomás
        ------------------------------------------------------------------
        report "===== TESZT 3: 'B' lenyomas =====";
        send_ps2_byte(x"32", psclock, psdata);
        wait for 50 ms;

        LEDsw <= '0';
        wait for 5 ms;
        LEDsw <= '1';
        wait for 5 ms;

        ------------------------------------------------------------------
        -- Szimuláció vége
        ------------------------------------------------------------------
        wait;
    end process;

end Behavioral;