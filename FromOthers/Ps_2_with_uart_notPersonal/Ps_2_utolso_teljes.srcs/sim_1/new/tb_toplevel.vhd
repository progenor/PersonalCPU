library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_toplevel is
-- A tesztpadnak nincsenek külső portjai
end tb_toplevel;

architecture behavior of tb_toplevel is

    -- A te fő modulod (toplevel) deklarációja. 
    -- Ellenőrizd, hogy a portnevek hajszálpontosan egyeznek-e a toplevel.vhd-ddal!
    component toplevel
    Port (
        clk_in   : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        psdata   : in  STD_LOGIC;
        psclock  : in  STD_LOGIC;
        LEDsw    : in  STD_LOGIC;
        UART_RX  : in  STD_LOGIC;
        Db       : out STD_LOGIC_VECTOR (7 downto 0);
        Rs       : out STD_LOGIC;
        Rw       : out STD_LOGIC;
        E        : out STD_LOGIC;
        led      : out STD_LOGIC_VECTOR (3 downto 0);
        UART_TX  : out STD_LOGIC
    );
    end component;

    -- Bemeneti jelek (Kezdeti értékekkel)
    signal clk_in   : std_logic := '0';
    signal reset    : std_logic := '1'; 
    signal psdata   : std_logic := '1'; -- PS/2 alapállapotban magas (idle)
    signal psclock  : std_logic := '1'; -- PS/2 alapállapotban magas (idle)
    signal LEDsw    : std_logic := '0';
    signal UART_RX  : std_logic := '1'; -- UART alapállapotban magas

    -- Kimeneti jelek megfigyeléshez
    signal Db       : std_logic_vector(7 downto 0);
    signal Rs       : std_logic;
    signal Rw       : std_logic;
    signal E        : std_logic;
    signal led      : std_logic_vector(3 downto 0);
    signal UART_TX  : std_logic;

    -- Órajel periódus (PYNQ-Z2: 125 MHz -> 8 ns)
    constant clk_period : time := 8 ns;

    -- PS/2 BÁJT KÜLDŐ ELJÁRÁS
    -- Ez a blokk generálja le a pontos PS/2 időzítéseket a teszthez
    procedure send_ps2_byte (
        constant data : in std_logic_vector(7 downto 0);
        signal ps_clk : out std_logic;
        signal ps_dat : out std_logic
    ) is
        variable parity : std_logic := '1';
    begin
        -- Páratlan paritás (Odd parity) számolása
        for i in 0 to 7 loop
            parity := parity xor data(i);
        end loop;

        -- Start bit (Mindig 0)
        ps_dat <= '0';
        wait for 20 us; ps_clk <= '0'; wait for 40 us; ps_clk <= '1'; wait for 20 us;

        -- Adatbitek (LSB-től MSB felé haladva)
        for i in 0 to 7 loop
            ps_dat <= data(i);
            wait for 20 us; ps_clk <= '0'; wait for 40 us; ps_clk <= '1'; wait for 20 us;
        end loop;

        -- Paritás bit
        ps_dat <= parity;
        wait for 20 us; ps_clk <= '0'; wait for 40 us; ps_clk <= '1'; wait for 20 us;

        -- Stop bit (Mindig 1)
        ps_dat <= '1';
        wait for 20 us; ps_clk <= '0'; wait for 40 us; ps_clk <= '1'; wait for 20 us;
    end procedure;

begin

    -- A tesztelendő modul bekötése
    uut: toplevel PORT MAP (
        clk_in   => clk_in,
        reset    => reset,
        psdata   => psdata,
        psclock  => psclock,
        LEDsw    => LEDsw,
        UART_RX  => UART_RX,
        Db       => Db,
        Rs       => Rs,
        Rw       => Rw,
        E        => E,
        led      => led,
        UART_TX  => UART_TX
    );

    -- Órajel generátor (Folyamatosan billeg 125 MHz-en)
    clk_process :process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- A TÉNYLEGES TESZT FORGATÓKÖNYV
    stim_proc: process
    begin
        -- 1. Hardver reset (100 ns-ig aktív)
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- 2. Várakozás az LCD inicializálására (NAGYON FONTOS!)
        -- Az Assembly kódod az elején vár 20ms-t, hogy az LCD felébredjen. Ezt ki kell várni.
        wait for 50 ms;

        -- 3. 'A' betű (Scan code: 1C) lenyomásának szimulálása
        -- 1C hex = 00011100 bin
        send_ps2_byte("00011100", psclock, psdata);
        
        wait for 2 ms; -- Rövid szünet a gomb nyomva tartása alatt

        -- 4. 'A' betű felengedése (Break kód: F0, majd újra az 1C)
        -- F0 hex = 11110000 bin
        send_ps2_byte("11110000", psclock, psdata);
        wait for 1 ms;
        send_ps2_byte("00011100", psclock, psdata);

        -- 5. Várakozás a jelfeldolgozásra és az UART kiküldésre
        wait for 5 ms;
        
        -- Teszt vége
        wait;
    end process;

end behavior;