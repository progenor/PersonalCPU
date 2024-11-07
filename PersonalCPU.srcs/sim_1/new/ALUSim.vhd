library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUSim is
end ALUSim;

architecture sim of ALUSim is
    -- Signal Declarations
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal OP1       : std_logic_vector(15 downto 0) := (others => '0');
    signal OP2       : std_logic_vector(15 downto 0) := (others => '0');
    signal Instr_code : std_logic_vector(5 downto 0) := (others => '0');
    signal Al_Instr_Ext : std_logic_vector(3 downto 0) := (others => '0');
    signal KK_const  : std_logic_vector(7 downto 0) := (others => '0');
    signal Execute   : std_logic := '0';
    signal Carry     : std_logic;
    signal Zero      : std_logic;
    signal ALU_Result : std_logic_vector(15 downto 0);

    -- Clock generation
    constant clk_period : time := 10 ns;
begin
    -- Instantiate ALU Unit Under Test (UUT)
    uut: entity work.ALU
        port map (
            clk       => clk,
            reset     => reset,
            OP1       => OP1,
            OP2       => OP2,
            Instr_code => Instr_code,
            Al_Instr_Ext => Al_Instr_Ext,
            KK_const  => KK_const,
            Execute   => Execute,
            Carry     => Carry,
            Zero      => Zero,
            ALU_Result => ALU_Result
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test process
    test_process : process
    begin
        -- Reset
        reset <= '1';
        wait for clk_period;
        reset <= '0';

        -- Test case 1: AND operation with KK_const
        OP1 <= x"00FF";
        KK_const <= x"0F";
        Instr_code <= "000011"; -- AND Sx, kk
        wait for clk_period;
        assert (ALU_Result = x"000F") report "AND operation failed" severity error;

        -- Test case 2: OR operation with KK_const
        OP1 <= x"00F0";
        KK_const <= x"0F";
        Instr_code <= "000101"; -- OR Sx, KK
        wait for clk_period;
        assert (ALU_Result = x"00FF") report "OR operation failed" severity error;

        -- Test case 3: XOR operation with KK_const
        OP1 <= x"00FF";
        KK_const <= x"0F";
        Instr_code <= "000111"; -- XOR Sx, KK
        wait for clk_period;
        assert (ALU_Result = x"00F0") report "XOR operation failed" severity error;

        -- Test case 4: Addition operation with KK_const
        OP1 <= x"00F0";
        KK_const <= x"0F";
        Instr_code <= "010001"; -- Add Sx, KK
        wait for clk_period;
        assert (ALU_Result = x"00FF") report "Addition operation failed" severity error;

        -- Add more test cases for each instruction as needed
        -- ...

        -- End simulation
        wait for 5 * clk_period;
        assert false report "End of simulation" severity failure;
    end process;
end sim;
