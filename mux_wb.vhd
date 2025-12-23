library IEEE;
use IEEE.std_logic_1164.ALL;

entity mux_wb is
    generic ( DATA_WIDTH : integer := 32 );
    port (
        in_alu  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 00
        in_mem  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 01
        in_pc4  : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- 10
        sel     : in  std_logic_vector(1 downto 0);
        dout    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity mux_wb;

architecture rtl of mux_wb is
begin
    with sel select dout <=
        in_alu when "00",
        in_mem when "01",
        in_pc4 when "10",
        (others => '0') when others;
end rtl;