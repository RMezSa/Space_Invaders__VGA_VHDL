--Entidad en la que se integran ambos contadores, el contador módulo 525 y el contador módulo 800
library ieee;
use ieee.std_logic_1164.ALL;

entity Contadores_MOD is
    port(
        CLK, RST: in std_logic;
        CNT_5: out std_logic_vector(9 downto 0);
        CNT_8: out std_logic_vector(9 downto 0)
    );
end entity;

architecture RTL of Contadores_MOD is
component Cont_MOD_800 is
    port(
        CLK, RST: in std_logic;
        Cout: out std_logic;
        CUENTA: out std_logic_vector(9 downto 0)
    );
end component;

component Cont_MOD_500 is
	port(
		CLK, RST: in std_logic;
		vcount: out std_logic_vector(9 downto 0)
	);
end component;


signal OV: std_logic;

begin
I0 : Cont_MOD_800 port map(CLK, RST, OV, CNT_8);
I1 : Cont_MOD_500 port map(OV, RST, CNT_5);

end architecture;