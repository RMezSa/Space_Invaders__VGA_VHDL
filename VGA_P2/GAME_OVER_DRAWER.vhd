--Dibujador de GAME OVER en caso de tener que desplegarse en pantalla.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package GAME_OVER_DRAWER is
    procedure GO(
        signal hc, vc, X, Y: in integer;
        signal R, G, B: out std_logic_vector(3 downto 0);
        signal DRAW: out std_logic    
    );
end package GAME_OVER_DRAWER;

package body GAME_OVER_DRAWER is
procedure GO(
        signal hc, vc, X, Y: in integer;
        signal R, G, B: out std_logic_vector(3 downto 0);
        signal DRAW: out std_logic    
    ) is
    variable dibujar : integer := 0;
    variable row : integer;
    variable col : integer;
    
    constant ancho : integer := 25*5;  
    constant alto: integer := 25*5; 
begin
    if (hc >= X and hc < X + ancho and 
        vc >= Y and vc < Y + alto) then
        row := (vc - Y ) / 5;
        col := (hc - X ) / 5 ;
        dibujar := 0;
        if (row = 5 and (col >= 5 and col <= 8)) or                     
           (row = 8 and (col >= 5 and col <= 8)) or                     
           (row = 12 and (col >= 5 and col <= 8)) or                     
           (col = 5 and (row >= 5 and row <= 12)) or                      
           (col = 8 and (row = 9 or row = 10 or row = 11 or row = 12)) then 
            dibujar := 1;
        elsif (row = 5 and (col >= 10 and col <= 12)) or                
              (row = 8 and (col >= 10 and col <= 12)) or                
              (col = 10 and (row >= 5 and row <= 12)) or                
              (col = 12 and (row >= 5 and row <= 12)) then              
            dibujar := 1;
        elsif (col = 14 and (row >= 5 and row <= 12)) or               
              (col = 18 and (row >= 5 and row <= 12)) or                  
              (row = 6 and (col = 15 or col = 17)) or                       
              (row = 7 and (col = 16)) then                                
            dibujar := 1;
        elsif (row = 5 and (col >= 20 and col <= 22)) or                 
              (row = 8 and (col >= 20 and col <= 22)) or                   
              (row = 12 and (col >= 20 and col <= 22)) or               
              (col = 20 and (row >= 5 and row <= 12)) then                
            dibujar := 1;
        elsif (row = 15 and (col >= 5 and col <= 8)) or                    
              (row = 21 and (col >= 5 and col <= 8)) or                    
              (col = 5 and (row >= 15 and row <= 21)) or                    
              (col = 8 and (row >= 15 and row <= 21)) then                  
            dibujar := 1;
        elsif (col = 10 and (row >= 15 and row <= 19)) or                  
              (col = 12 and (row >= 15 and row <= 19)) or                   
              (row = 20 and (col = 11)) or                                  
              (row = 21 and (col = 11)) then                                
            dibujar := 1;
        elsif (row = 15 and (col >= 15 and col <= 17)) or                  
              (row = 18 and (col >= 15 and col <= 17)) or                   
              (row = 21 and (col >= 15 and col <= 17)) or                   
              (col = 15 and (row >= 15 and row <= 21)) then                 
            dibujar := 1;
        elsif (row = 15 and (col >= 19 and col <= 21)) or                   
              (row = 18 and (col >= 19 and col <= 21)) or                   
              (col = 19 and (row >= 15 and row <= 21)) or                   
              (col = 21 and (row >= 15 and row <= 17)) or                   
              (row = 19 and col = 20) or                                    
              (row = 20 and col = 21) or                                    
              (row = 21 and col = 22) then                                  
            dibujar := 1;
        end if;
        
        if dibujar = 1 then
            R <= "0000";
            G <= "0000";
            B <= "1111"; 
            DRAW <= '1';
        else
            R <= "0000";
            G <= "0000";
            B <= "0000";
            DRAW <= '0'; 
        end if;
    else
        DRAW <= '0';
    end if;
end procedure;
end package body GAME_OVER_DRAWER;