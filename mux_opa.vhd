library IEEE;
use IEEE.std_logic_1164.ALL;

entity mux_opa is
    generic ( DATA_WIDTH : integer := 32 );
    port (
        in_rs1  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 00: Registre
        in_pc   : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 01: PC
        in_zero : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 10: Zéro (pour LUI)
        sel     : in  std_logic_vector(1 downto 0);
        dout    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity mux_opa;

architecture rtl of mux_opa is
    constant ZERO_VECT : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin
    with sel select dout <=
        in_rs1  when "00",
        in_pc   when "01",
        ZERO_VECT when "10",
        ZERO_VECT when others;
end rtl;