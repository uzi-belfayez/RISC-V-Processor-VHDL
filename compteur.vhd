library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity compteur is
    generic (
        TAILLE : integer := 32
    );
    port (
        din         : in  std_logic_vector(TAILLE-1 downto 0);
        clk         : in  std_logic;
        load        : in  std_logic;
        reset       : in  std_logic;
        dout        : out std_logic_vector(TAILLE-1 downto 0);
        pc_plus_4   : out std_logic_vector(TAILLE-1 downto 0) -- NOUVELLE SORTIE
    );
end entity compteur;

architecture behavior of compteur is
    signal cpt : unsigned(TAILLE-1 downto 0);
begin
    process (clk, reset)
    begin
        if reset = '1' then
            cpt <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                cpt <= unsigned(din);
            else
                cpt <= cpt + 4; -- Incrémentation par 4 (adresses octets)
            end if;
        end if;
    end process;

    dout <= std_logic_vector(cpt);
    
    -- Calcul combinatoire de PC + 4 pour le Write-Back (JAL/JALR)
    pc_plus_4 <= std_logic_vector(cpt + 4); 

end behavior;