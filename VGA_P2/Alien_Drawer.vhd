------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------

--Package drawer para dibujar a los aliens mediante el uso de condicionales dentro de un recuadro de 28x26 pixeles
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Alien_Drawer is
    procedure sq(
        signal hc, vc, X, Y: in integer;
        signal R, G, B: out std_logic_vector(3 downto 0);
        signal DRAW: out std_logic    
    );
end package Alien_Drawer;

package body Alien_Drawer is

procedure sq(
        signal hc, vc, X, Y: in integer;
        signal R, G, B: out std_logic_vector(3 downto 0);
        signal DRAW: out std_logic    
    ) is
begin
    if (hc > X and hc <= (X + 28) and vc > Y and vc <= (Y + 26)) then
        if ( (vc = Y + 3 and (hc = X + 7 or hc = X + 8 or hc = X + 21 or hc = X + 22)) or
             (vc = Y + 4 and (hc = X + 7 or hc = X + 8 or hc = X + 21 or hc = X + 22)) or
             (vc = Y + 5 and (hc = X + 9 or hc = X + 10 or hc = X + 17 or hc = X + 18)) or
             (vc = Y + 6 and (hc = X + 9 or hc = X + 10 or hc = X + 17 or hc = X + 18)) or
             (vc = Y + 7 and (hc = X + 9 or hc = X + 10 or hc = X + 17 or hc = X + 18)) or
             (vc = Y + 8 and (hc = X + 9 or hc = X + 10 or hc = X + 17 or hc = X + 18)) or
             (vc = Y + 9 and (hc >= X + 7 and hc <= X + 22)) or
             (vc = Y + 10 and (hc >= X + 7 and hc <= X + 22)) or
             (vc = Y + 11 and (hc >= X + 7 and hc <= X + 22)) or
             (vc = Y + 12 and (hc >= X + 7 and hc <= X + 22)) or
             (vc = Y + 13 and ((hc >= X + 5 and hc <= X + 8) or (hc >= X + 11 and hc <= X + 16) or (hc >= X + 19 and hc <= X + 24))) or
             (vc = Y + 14 and ((hc >= X + 5 and hc <= X + 8) or (hc >= X + 11 and hc <= X + 16) or (hc >= X + 19 and hc <= X + 24))) or
             (vc = Y + 15 and (hc >= X + 3 and hc <= X + 26)) or
             (vc = Y + 16 and (hc >= X + 3 and hc <= X + 26)) or
             (vc = Y + 17 and ((hc >= X + 2 and hc <= X + 3) or (hc >= X + 7 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 18 and ((hc >= X + 2 and hc <= X + 3) or (hc >= X + 7 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 19 and ((hc >= X + 2 and hc <= X + 3) or (hc >= X + 7 and hc <= X + 10) or 
				 (hc >= X + 19 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 20 and ((hc >= X + 2 and hc <= X + 3) or (hc >= X + 7 and hc <= X + 10) or 
				 (hc >= X + 19 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 21 and ((hc >= X + 7 and hc <= X + 10) or (hc >= X + 19 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 22 and ((hc >= X + 7 and hc <= X + 10) or (hc >= X + 19 and hc <= X + 22) or (hc >= X + 26 and hc <= X + 27))) or
             (vc = Y + 23 and ((hc >= X + 7 and hc <= X + 10) or (hc >= X + 19 and hc <= X + 22))) or
             (vc = Y + 24 and ((hc >= X + 7 and hc <= X + 10) or (hc >= X + 19 and hc <= X + 22))) or
             (vc = Y + 25 and (hc = X + 9 or hc = X + 12 or hc = X + 18 or hc = X + 19 or hc = X + 20 or hc = X + 21)) or
             (vc = Y + 26 and (hc >= X + 9 or hc <= X + 12 or hc = X + 18 or hc = X + 19 or hc = X + 20 or hc = X + 21))
           ) then
            R <= "0000";
            G <= "1111";
            B <= "0000";
            DRAW <= '1';
        else
            R <= "0000";
            G <= "0000";
            B <= "0000";
            DRAW <= '1';
        end if;
    else
        DRAW <= '0';
    end if;
end procedure;

end package body Alien_Drawer;
