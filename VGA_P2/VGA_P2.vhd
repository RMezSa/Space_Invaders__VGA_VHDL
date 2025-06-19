------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------

--Top level entity, en la cual se integran todos los componentes desarrollados.
library ieee;
use ieee.std_logic_1164.ALL;

entity VGA_P2 is

	port(
		clk_50, RST, START: in std_logic;
		
		joystick_nave: in std_logic_vector(3 downto 0);
		joystick_nave_2: in std_logic_vector(1 downto 0);
		vsync, hsync: out std_logic;
		shot: in std_logic;
		R, G, B: out std_logic_vector(3 downto 0)
	);

end entity;

architecture RTL of VGA_P2 is
--Contadores
component Contadores_MOD is
    port(
        CLK, RST: in std_logic;
        CNT_5: out std_logic_vector(9 downto 0);
        CNT_8: out std_logic_vector(9 downto 0)
    );
end component;
-- Divisor de CLK
component CLK_divisor is
    Port ( clk_50  : in  std_logic;  
           RST  : in  std_logic;  
           clk_25 : out std_logic); 
end component;

--Maquina de estados horizontal
component Estados_VGA is
    port(
        CLK, RST: in std_logic;
        START: in std_logic;
        hcount: in std_logic_vector(9 downto 0);
        vcount: in std_logic_vector(9 downto 0);
        vsyncST: in std_logic_vector(1 downto 0);
        joystick_nave: in std_logic_vector(3 downto 0);
		  joystick_nave_2: in std_logic_vector(1 downto 0);
		  shot: in std_logic;
        R, G, B: out std_logic_vector(3 downto 0);
        hsync: out std_logic
    );
end component;

--Maquina de estados vertical
component Estados_VGA_V is
    port(
        CLK, RST: in std_logic;
        START: in std_logic;
        vcount: in std_logic_vector(9 downto 0);
        vsyncST: out std_logic_vector(1 downto 0);
        vsync: out std_logic
    );
end component;

signal CLK: std_logic;
signal CNT_15, CNT_18: std_logic_vector(9 downto 0);
signal vsyncst :std_logic_vector(1 downto 0);

begin
I0 : CLK_divisor port map(clk_50, RST, CLK);
I1 : Contadores_MOD port map(CLK, RST, CNT_15, CNT_18);
I2 : Estados_VGA_V port map (CLK, RST, START, CNT_15, vsyncst, vsync);
I3 : Estados_VGA port map (CLK, RST, START, CNT_18, CNT_15, vsyncst, joystick_nave, joystick_nave_2, shot, R, G, B, hsync);

end architecture;