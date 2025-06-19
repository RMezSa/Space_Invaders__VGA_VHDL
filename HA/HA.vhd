--Roberd Otoniel Meza Sainz
-- A01801490
-- Descripción de la función del archivo VHD

library ieee;
use ieee.std_logic_1164.all;

--entity es algo que siempre debe de tener un archivo VHDL
entity HA is 
--En port defino entradas y salidas, 
	port(A, B: in std_logic; 
	S, Co: out std_logic);
end entity;

architecture RTL of HA is 
	--aqui es donde se definen señales variables y demás
	begin 
		S	<= A xor B;
		Co <= A and B;
end architecture;


		