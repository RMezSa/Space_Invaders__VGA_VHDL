library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity Dibujador_VGA is
    port(
        cv: in std_logic_vector(9 downto 0);
        ch: in std_logic_vector(9 downto 0);
        R, G, B: out std_logic_vector(3 downto 0)
    );
end entity;

architecture RTL of Dibujador_VGA is
begin
    P0: process(cv, ch) is
        variable cv_int : integer;
        variable ch_int : integer;
    begin
        cv_int := to_integer(unsigned(cv));
        ch_int := to_integer(unsigned(ch));

        -- Escalar la imagen: cada "pixel" original se convierte en un bloque de 2x2 pixeles
        if ((cv_int / 2 = 2 and (ch_int / 2 = 4 or ch_int / 2 = 10)) or
            (cv_int / 2 = 3 and (ch_int / 2 = 5 or ch_int / 2 = 9)) or
            (cv_int / 2 = 4 and (ch_int / 2 = 5 or ch_int / 2 = 9)) or
            (cv_int / 2 = 5 and (ch_int / 2 >= 4 and ch_int / 2 <= 12)) or
            (cv_int / 2 = 6 and ((ch_int / 2 >= 3 and ch_int / 2 <= 5) or (ch_int / 2 >= 7 and ch_int / 2 <= 9) or (ch_int / 2 >= 11 and ch_int / 2 <= 13))) or
            (cv_int / 2 = 7 and (ch_int / 2 >= 2 and ch_int / 2 <= 13)) or
            (cv_int / 2 = 8 and ((ch_int / 2 = 2 or ch_int / 2 = 4) or (ch_int / 2 >= 6 and ch_int / 2 <= 12))) or
            (cv_int / 2 = 9 and ((ch_int / 2 = 2 or ch_int / 2 = 4) or (ch_int / 2 >= 6 and ch_int / 2 <= 12))) or
            (cv_int / 2 = 10 and (ch_int / 2 = 4 or ch_int / 2 = 5 or ch_int / 2 = 11 or ch_int / 2 = 12)) or
            (cv_int / 2 = 11 and (ch_int / 2 = 4 or ch_int / 2 = 5 or ch_int / 2 = 11 or ch_int / 2 = 12)) or
            (cv_int / 2 = 12 and (ch_int / 2 = 5 or ch_int / 2 = 6 or ch_int / 2 = 11 or ch_int / 2 = 12))) then
            R <= "0000";
            G <= "1111";
            B <= "0000";
        else
            R <= "0000";
            G <= "0000";
            B <= "0000";
        end if;
    end process;
end architecture;
