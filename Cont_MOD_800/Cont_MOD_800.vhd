------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------

-- Contador modulo 800
library ieee;
use ieee.std_logic_1164.ALL;

entity Cont_MOD_800 is
    port(
        CLK, RST: in std_logic;
        Cout: out std_logic;
        CUENTA: out std_logic_vector(9 downto 0)
    );
end entity;

architecture RTL of Cont_MOD_800 is

    signal D, Q: std_logic_vector(9 downto 0);


COMPONENT Cont_MOD_800_AUX is
	port(
		A: in std_logic_vector(9 downto 0);
		X: out std_logic_vector(9 downto 0)
	);
	
end COMPONENT;
begin
    I0: Cont_MOD_800_AUX port map (Q, D);
    CUENTA <= Q;

    P1: process(CLK, RST)
    begin
        if (RST = '0') then
            Q <= "0000000000";
            Cout <= '0';
        elsif (CLK'event and CLK = '1') then
            if (Q = "1100011111") then  
                Q <= "0000000000";
					 Cout <= '1';
            else
                Q <= D; 
                Cout <= '0';  
            end if;
        end if;
    end process P1;
end architecture RTL;
