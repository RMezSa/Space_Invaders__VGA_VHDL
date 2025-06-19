--Contador Auxiliar de 10 bits

library ieee;
use ieee.std_logic_1164.ALL;

entity Cont_MOD_800_AUX is
	port(
		A: in std_logic_vector(9 downto 0);
		X: out std_logic_vector(9 downto 0)
	);
	
end entity;

architecture RTL of Cont_MOD_800_AUX is
component HA is 
	port(
	A, B: in std_logic; 
	S, Co: out std_logic
	);
end component;

signal C: std_logic_vector(9 downto 1);

begin
	 I0: HA port map(A(0), '1', X(0), C(1));
    I1: HA port map(A(1), C(1), X(1), C(2));
    I2: HA port map(A(2), C(2), X(2), C(3));
    I3: HA port map(A(3), C(3), X(3), C(4));
    I4: HA port map(A(4), C(4), X(4), C(5));
    I5: HA port map(A(5), C(5), X(5), C(6));
    I6: HA port map(A(6), C(6), X(6), C(7));
    I7: HA port map(A(7), C(7), X(7), C(8));
    I8: HA port map(A(8), C(8), X(8), C(9));

X(9) <= A(9) xor C(9);

end architecture RTL;