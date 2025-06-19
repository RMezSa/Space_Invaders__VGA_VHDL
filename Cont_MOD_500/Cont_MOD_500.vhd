------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------

--Contador Modulo 525
library ieee;
use ieee.std_logic_1164.ALL;

entity Cont_MOD_500 is
	port(
		CLK, RST: in std_logic;
		vcount: out std_logic_vector(9 downto 0)
	);
end entity;


architecture RTL of Cont_MOD_500 is

signal D, Q: std_logic_vector(9 downto 0);

component Cont_MOD_500_AUX is
	port(
		A: in std_logic_vector(9 downto 0);
		X: out std_logic_vector(9 downto 0)
	);
	
end component;

begin
I0: Cont_MOD_500_AUX port map (Q, D);
vcount <= Q;

	
	P1: process(CLK, RST)
    begin
        if (RST = '0') then
            Q <= "0000000000";
        elsif (CLK'event and CLK = '1') then
            if (Q = "1000001100") then  
                Q <= "0000000000"; 
            else
                Q <= D; 
            end if;
        end if;
    end process P1;
end architecture RTL;