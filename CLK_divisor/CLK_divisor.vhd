------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------


-- Divisor de CLK de 50mhz a 25mhz
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_divisor is
    Port ( clk_50  : in  std_logic;  
           RST  : in  std_logic;  
           clk_25 : out std_logic); 
end CLK_divisor;

architecture RTL of CLK_divisor is
    signal clk_div : std_logic := '0'; 
begin

    process(clk_50, RST)
    begin
        if RST = '0' then
            clk_div <= '0'; 
        elsif rising_edge(clk_50) then
            clk_div <= not clk_div; 
        end if;
    end process;

    clk_25 <= clk_div;

end architecture;
