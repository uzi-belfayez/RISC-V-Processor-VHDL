library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity bc is
    generic (
        dataWidth   : integer := 32
    );
    port (
        src1    : in  std_logic_vector(dataWidth - 1 downto 0); -- BusA
        src2    : in  std_logic_vector(dataWidth - 1 downto 0); -- BusB
        btype   : in  std_logic_vector(2 downto 0);             -- funct3 (Type de saut)
        bres    : out std_logic                                 -- Résultat (1=Sauter, 0=Continuer)
    );
end entity bc;

architecture behav of bc is
    -- Conversion pour comparaisons signées et non-signées
    signal s1_signed, s2_signed : signed(dataWidth - 1 downto 0);
    signal s1_unsigned, s2_unsigned : unsigned(dataWidth - 1 downto 0);
begin
    s1_signed   <= signed(src1);
    s2_signed   <= signed(src2);
    s1_unsigned <= unsigned(src1);
    s2_unsigned <= unsigned(src2);

    process (src1, src2, btype, s1_signed, s2_signed, s1_unsigned, s2_unsigned)
    begin
        bres <= '0'; -- Par défaut, on ne saute pas

        case btype is
            when "000" => -- BEQ (Equal)
                if src1 = src2 then bres <= '1'; end if;
                
            when "001" => -- BNE (Not Equal)
                if src1 /= src2 then bres <= '1'; end if;
                
            when "100" => -- BLT (Less Than - Signed)
                if s1_signed < s2_signed then bres <= '1'; end if;
                
            when "101" => -- BGE (Greater or Equal - Signed)
                if s1_signed >= s2_signed then bres <= '1'; end if;
                
            when "110" => -- BLTU (Less Than - Unsigned)
                if s1_unsigned < s2_unsigned then bres <= '1'; end if;
                
            when "111" => -- BGEU (Greater or Equal - Unsigned)
                if s1_unsigned >= s2_unsigned then bres <= '1'; end if;
                
            when others => 
                bres <= '0';
        end case;
    end process;
end behav;