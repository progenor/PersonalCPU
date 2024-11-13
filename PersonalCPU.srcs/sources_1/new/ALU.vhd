----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2024 04:36:33 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;
--use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           OP1 : in STD_LOGIC_VECTOR (15 downto 0);
           OP2 : in STD_LOGIC_VECTOR (15 downto 0);
           Instr_code : in STD_LOGIC_VECTOR (5 downto 0);
           Al_Instr_Ext : in STD_LOGIC_VECTOR (3 downto 0);
           KK_const : in STD_LOGIC_VECTOR (7 downto 0);
           Execute : in STD_LOGIC;
           Carry : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALU_Result : out STD_LOGIC_VECTOR (15 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

process(clk,reset,Execute,Instr_code,Al_instr_Ext)
variable Result:std_logic_vector (16 downto 0):=(others=>'0');
variable CarryFlag, ZeroFlag: std_logic:='0';

begin
    if (reset='1') then
        Carry<='0';
        Zero<='0';
        ALU_Result<=(others=>'0');
    else 
        if(falling_edge(clk)) then
            case Instr_code is --sorra veszi az osszes utasitast
                when "000011" => --(AND Sx,kk)
                    Result(15 downto 0):= Result(15 downto 8) & (KK_const and OP1(7 downto 0)); 
                    if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                        ZeroFlag:='1';
                    else
                        ZeroFlag:='0';
                    end if;
                    
                when "000010"=> --(AND, Sx,SY)
                    
                    Result(15 downto 0):= Result(15 downto 8) & (OP2(7 downto 0) and OP1(7 downto 0));
                    if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                        ZeroFlag:='1';
                    else
                        ZeroFlag:='0';
                    end if;
                    
                when "000101" => --(OR Sx,KK)
                    Result(15 downto 0) := Result(15 downto 8) & (KK_const or OP1(7 downto 0));
                        if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                        end if;
                        
                when "000100" => --(OR Sx, Sy)
                    Result(15 downto 0) := Result(15 downto 8) & (OP2(7 downto 0) or OP1(7 downto 0));
                        if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                    end if;
                    
                when "000111" => --(XOR SX, kk)
                    Result(15 downto 0) := Result(15 downto 8) & (KK_const xor OP1(7 downto 0));
                        if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                        end if;
                        
                when "000110" => --(XOR Sx, Sy)
                    Result(15 downto 0) := Result(15 downto 8) & (OP2(7 downto 0) xor OP1(7 downto 0));
                        if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                    end if;
                    
                when "001101" => --(Mult8 Sx, kk)
                    Result(15 downto 0):= unsigned(KK_const) * unsigned(OP1(7 downto 0));
                    if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                        end if;
                    -- carry nem lesz 8 biten mert nem fut ki a 16 bitbol

                        
                when "001100" => --(Mult8 Sx, Sy)
                    Result(15 downto 0):= unsigned(OP2(7 downto 0)) * unsigned(OP1(7 downto 0));
                    if(Result(15 downto 0)=x"00")then -- eredmeny=0 eseten zeroflag lenullazasa
                            ZeroFlag:='1';
                        else
                            ZeroFlag:='0';
                        end if;
                    -- carry nem lesz 8 biten mert nem fut ki a 16 bitbol
                
                when "011101" => -- (COMP Sx, kk)
                    if(OP1(15 downto 0)< KK_const(7 downto 0)) then
                        CarryFlag:='1'; --ha kk_const nagyobb, Carry=1 maskepp 0
                    else 
                        CarryFlag:='0';
                    end if;
                     if(OP1(15 downto 0)= KK_const(7 downto 0)) then
                        ZeroFlag:='1'; --ha a ket szam egyenlo Zero=1, maskepp 0
                    else 
                        ZeroFlag:='0';
                    end if;
                
                when "011100" => -- (COMP Sx, Sy)
                    if(OP1(15 downto 0)< OP2(15 downto 0)) then
                        CarryFlag:='1'; --ha kk_const nagyobb, Carry=1 maskepp 0
                    else 
                        CarryFlag:='0';
                    end if;
                     if(OP1(15 downto 0)= OP2(15 downto 0)) then
                        ZeroFlag:='1'; --ha a ket szam egyenlo Zero=1, maskepp 0
                    else 
                        ZeroFlag:='0';
                    end if;
               
                 
                
                -- forgotten functions added later

                when "010001" => -- Add sX, KK
                    Result(15 downto 0) := ('0' & OP1(7 downto 0)) + ( "00000000" & KK_Const);
                    CarryFlag := Result(16);
                   
                   if Result(15 downto 0) = x"0000" then
                        ZeroFlag := '1';
                   else ZeroFlag := '0';
                   end if;
                   
                when "010000" => -- Add sX, sY
                    Result(15 downto 0) := ('0' & OP1(7 downto 0)) + ("00000000" & OP2(7 downto 0));
                    CarryFlag := Result(16);
                   
                   if Result(15 downto 0) = x"0000" then
                        ZeroFlag := '1';
                   else ZeroFlag := '0';
                   end if;
                   
                when "010011" => -- AddCy sX, KK
                    Result(15 downto 0) := ('0' & OP1(7 downto 0)) + ( "00000000" & KK_Const) + CarryFlag;
                    CarryFlag := Result(16);
                   
                   if Result(15 downto 0) = x"0000" then
                        ZeroFlag := '1';
                   else ZeroFlag := '0';
                   end if;
                   
                when "010010" => -- AddCy sX, sY
                    Result(15 downto 0) := ('0' & OP1(7 downto 0)) + ("00000000" & OP2(7 downto 0)) + CarryFlag;
                    CarryFlag := Result(16);
                   
                   if Result(15 downto 0) = x"0000" then
                        ZeroFlag := '1';
                   else ZeroFlag := '0';
                   end if;

                when "011001" => -- SUB sX, KK
                    Result(15 downto 0):= Result(15 downto 8) & (OP1(7 downto 0)-KK_const);
                    if(Result(15 downto 0)=x"0000")then -- eredmeny=0 eseten zeroflag lenullazasa
                        ZeroFlag:='1';
                    else
                        ZeroFlag:='0';
                    end if;
                    if(OP1>(KK_const+CarryFlag)) then --Carry flag allitasa negativ tulcsordulas eseten
                        CarryFlag:='0';
                    else
                        CarryFlag:='1';
                    end if;
                    
                    when "011000" => -- SUB sX, sY
                    Result(15 downto 0):= Result(15 downto 8) & (OP1(7 downto 0)-OP2(7 downto 0)-CarryFlag);
                    if(Result(15 downto 0)=x"0000")then -- eredmeny=0 eseten zeroflag lenullazasa
                        ZeroFlag:='1';
                    else
                        ZeroFlag:='0';
                    end if;
                    if(OP1>(KK_const+CarryFlag)) then --Carry flag allitasa negativ tulcsordulas eseten
                        CarryFlag:='0';
                    else
                        CarryFlag:='1';
                    end if;

                -- Start of the shift registers
                when "010100" => --(SRR Sx)
                    case KK_const(3 downto 0) is
                        -------------- SRR ----------------------
                        when "1110" => -- SR0
                            CarryFlag := OP1(0); 
                            Result(14 downto 0) :=OP1(15 downto 1);
                            Result(15) :='0';
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                                    
                        when "1111" => -- SR1
                            CarryFlag := OP1(0);
                            Result(14 downto 0) :=OP1(15 downto 1);
                            Result(15) :='1';
                            
                        when "1010" => -- SRx
                            Result(15 downto 0) :=OP1(15 downto 0);
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                            
                         when "1000" => -- SRA
                            CarryFlag := OP1(0);
                            Result(14 downto 0) := OP1(15 downto 1);
                            Result(15) := CarryFlag;
                            if(Result(15 downto 0)=x"00")then
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                            
                         when "1100" => -- RR
                            CarryFlag := OP1(0);
                            Result(14 downto 0) := OP1(15 downto 1);
                            Result(15) := OP1(0);
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                            ----------------- SRL-------------------
                         when "0110" => -- SL0
                            CarryFlag := OP1(15);
                            Result(15 downto 1) :=OP1(14 downto 0);
                            Result(0) :='0';
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                                    
                        when "0111" => -- SL1
                            CarryFlag := OP1(15);
                            Result(15 downto 1) :=OP1(14 downto 0);
                            Result(0) :='1';
                            
                        when "0100" => -- SLx
                            CarryFlag := OP1(15);
                            Result(15 downto 1) := OP1(14 downto 0);
                            Result(0) := OP1(0);
                            if(Result(15 downto 0)=x"00")then
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                            
                         when "0000" => -- SLA
                            CarryFlag := OP1(15);
                            Result(15 downto 1) := OP1(14 downto 0);
                            Result(0) := CarryFlag;
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                            
                         when "0010" => -- RL
                            CarryFlag := OP1(15);
                            Result(15 downto 1) := OP1(14 downto 0);
                            Result(0) := OP1(15);
                            if(Result(15 downto 0)=x"00")then 
                                ZeroFlag:='1';
                            else
                                ZeroFlag:='0';
                            end if;
                         when others =>
                            null;
                    end case; 
                    when others =>
                        null;
            end case;
            ALU_Result<=Result(15 downto 0);
            Carry<=CarryFlag;
            Zero<=ZeroFlag;
        end if; --orajeles if lezarasa
    end if; --resetes if lezarasa  
end process;

end Behavioral;

