library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;  
use work.Alien_Drawer.all;
use work.Spaceship_Drawer.all;
use work.Spaceship_Drawer_Red.all;  
use work.Bullet_Drawer.all;  
use work.GAME_OVER_DRAWER.all;
use work.WIN_DRAWER.all;

entity Estados_VGA is
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
end entity;

architecture RTL of Estados_VGA is

    type EDOS is (IDLE, DISPLAY, FPORCH, BPORCH, SYNC);
    signal EDO, EDOF: EDOS;

    --Registers input output
    signal hcount_reg1, hcount_reg2: std_logic_vector(9 downto 0);
    signal vcount_reg1, vcount_reg2: std_logic_vector(9 downto 0);
    signal vsyncST_reg1, vsyncST_reg2: std_logic_vector(1 downto 0);
    signal R_reg, G_reg, B_reg: std_logic_vector(3 downto 0);
    signal hsync_reg1, hsync_reg2: std_logic;
    
    --  Registers para draw
    signal ch_reg, cv_reg: integer := 0;
    signal xc_reg, yc_reg: integer := 0;
    signal Rd_reg, Gd_reg, Bd_reg: std_logic_vector(3 downto 0);
    signal DRAW_reg: std_logic;
	 signal DRAW_reg_2: std_logic;
	 signal DRAW_reg_3:std_logic;

    -- Coordenadas en enteros
    signal h_int, v_int: integer range 0 to 1023;
    
    -- activos
    signal display_active: std_logic;
	 signal bala_activa: integer := 0;
	 
	--Señales colision con bala
	signal bullet_shot: std_logic := '0';
	signal alien_colision_bullet: std_logic_vector(29 downto 0) := (others => '0');
	signal alien_activo: std_logic_vector(29 downto 0) := (others => '1'); 

    -- Usando record y arrays para mas rapidoo
    type Alien_Rec is record
        x: integer range 0 to 639;
        y: integer range 0 to 479;
    end record;
    
    type Alien_Array is array(0 to 29) of Alien_Rec;
    signal aliens: Alien_Array;
    
    -- Posiciones
    signal SPACESHIP_X: integer := 400;  
    signal SPACESHIP_Y: integer := 470;
	 signal SPACESHIP2_X: integer := 400;  
    signal SPACESHIP2_Y: integer := 50;
	 
	 signal bullet_x: integer := 0;
	 signal bullet_y: integer := 0;
	 signal bullet_x2: integer := 0;
	 signal bullet_y2: integer := 0;
    
    -- Contadores velocidad
    signal contador_nave: integer range 0 to 60 := 0;
    constant velocidad_nave: integer := 2; 
	 signal contador_nave_2: integer range 0 to 60 := 0;
    constant velocidad_nave_2: integer := 4;
    signal contador_alien: integer range 0 to 120 := 0;
    constant velocidad_alien: integer := 1;  
    signal alien_direccion: integer range -1 to 1 := 1;
	 constant velocidad_bullet : integer := 4;
	 
	 --Aliens aún activos
	 signal contador_activos: integer := 30;
    
	 -- Detectar sincronización vertical para actualizar pantalla
    signal vsync_edge: std_logic := '0';
    signal prev_vsync: std_logic_vector(1 downto 0) := "00";
    
	 --Límites
    constant Limite_Izq: integer := 160;
    constant Limite_Der: integer := 750;

	--Steps de los aliens
    signal ALIEN_STEP_HORIZONTAL: integer := 3; 
    constant ALIEN_STEP_VERTICAL: integer := 20;
	 
    signal ship: std_logic;
	 
	 --game over
	 signal x_ini: integer := 400;
	 signal y_ini: integer := 220;
	 signal Game_Over: std_logic := '0';
	 
	 --Win
	 signal WINNER: std_logic := '0';

begin
    -- Coordenadas count a enteros
    h_int <= to_integer(unsigned(hcount));
    v_int <= to_integer(unsigned(vcount));

    
	 --Proces de pipeline para optimizar tiempo de sintesis
    process(CLK)
    begin
        if rising_edge(CLK) then

            hcount_reg1 <= hcount;
            vcount_reg1 <= vcount;
            vsyncST_reg1 <= vsyncST;
            hcount_reg2 <= hcount_reg1;
            vcount_reg2 <= vcount_reg1;
            vsyncST_reg2 <= vsyncST_reg1;
            R <= R_reg;
            G <= G_reg;
            B <= B_reg;
            hsync <= hsync_reg2;
        end if;
    end process;

    
    P0: process(CLK, RST)
    begin 
        if RST = '0' then
            EDO <= IDLE;
        elsif rising_edge(CLK) then    
            EDO <= EDOF;
        end if;
    end process;
	 
	 
--Cambio de estados para maquina horizontal
    P1: process(EDO, hcount, START)
    begin
        case EDO is
            when IDLE => 
                if (START = '1') then
                    EDOF <= SYNC;
                else
                    EDOF <= IDLE;
                end if;

            when SYNC =>
                if (hcount >= "0001011111") then  -- 95
                    EDOF <= BPORCH;
                else
                    EDOF <= SYNC;
                end if;

            when BPORCH =>
                if (hcount >= "0010001111") then  -- 143
                    EDOF <= DISPLAY;
                else
                    EDOF <= BPORCH;
                end if;

            when DISPLAY =>
                if (hcount >= "1100001111") then  -- 783
                    EDOF <= FPORCH;
                else
                    EDOF <= DISPLAY;
                end if;

            when FPORCH =>
                if (hcount = "1100011111") then  -- 799
                    EDOF <= IDLE;
                else
                    EDOF <= FPORCH;
                end if;

            when others => 
                EDOF <= IDLE;
        end case;
    end process P1;

	 --Para ver si el estado es display
    process(EDO)
    begin
        if EDO = DISPLAY then
            display_active <= '1';
        else
            display_active <= '0';
        end if;
    end process;

    -- Register para hsync si el estado es sync
    process(EDO)
    begin
        if EDO = SYNC then
            hsync_reg1 <= '0';
        else
            hsync_reg1 <= '1';
        end if;
    end process;
    
    -- pipeline para hsync
    process(CLK)
    begin
        if rising_edge(CLK) then
            hsync_reg2 <= hsync_reg1;
        end if;
    end process;


-- Process para el movimiento de los aliens además de detección de límites en los bordes para cambiar la dirección de movimiento
-- Actualización tanto del step vertical como del step horizontal de los aliens.
process(CLK, RST)
begin
    if RST = '0' then
        for i in 0 to 9 loop
            aliens(i).x <= 150 + (i * 38);
            aliens(i).y <= 100;
            aliens(i+10).x <= 150 + (i * 38);
            aliens(i+10).y <= 136;
            aliens(i+20).x <= 150 + (i * 38);
            aliens(i+20).y <= 172;
        end loop;
        contador_alien <= 0;
        alien_direccion <= 1;
		  ALIEN_STEP_HORIZONTAL <= 3;
    elsif rising_edge(CLK) then
        if vsync_edge = '1' then
            if contador_alien < velocidad_alien then
                contador_alien <= contador_alien + 1;
            else
                contador_alien <= 0;
                if (alien_direccion = 1 and aliens(9).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(8).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(7).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(6).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(5).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(4).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(3).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(2).x >= Limite_Der) or
                   (alien_direccion = 1 and aliens(1).x >= Limite_Der) or
						 (alien_direccion = 1 and aliens(0).x >= Limite_Der) or
                   (alien_direccion = -1 and aliens(9).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(8).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(7).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(6).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(5).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(4).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(3).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(2).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(1).x <= Limite_Izq) or
                   (alien_direccion = -1 and aliens(0).x <= Limite_Izq) then
                    alien_direccion <= -alien_direccion;
						  if(ALIEN_STEP_HORIZONTAL <= 5) then
								ALIEN_STEP_HORIZONTAL <= ALIEN_STEP_HORIZONTAL + 1;
						  end if;
                    for i in 0 to 29 loop
                        if alien_activo(i) = '1' then
                            aliens(i).y <= aliens(i).y + ALIEN_STEP_VERTICAL;
                        else
                            aliens(i).y <= aliens(i).y;
                        end if;
                    end loop;
                else
                    for i in 0 to 29 loop
                        if alien_activo(i) = '1' then
                            aliens(i).x <= aliens(i).x + (ALIEN_STEP_HORIZONTAL * alien_direccion);
                        else
                            aliens(i).x <= aliens(i).x;
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end if;
end process;


-- Process para mover con un input tipo std_logic a la nave sin exceder límites establecidos
process(CLK, RST)
begin
    if RST = '0' then
        SPACESHIP_X <= 400;
        SPACESHIP_Y <= 470;
        contador_nave <= 0;
		  
        prev_vsync <= "00";
        vsync_edge <= '0';
		  
		  SPACESHIP2_X <= 400;
        SPACESHIP2_Y <= 50;
        contador_nave_2 <= 0;
		  
    elsif rising_edge(CLK) then
        prev_vsync <= prev_vsync(0) & vsyncST(1);
        if prev_vsync = "01" then
            vsync_edge <= '1';
        else
            vsync_edge <= '0';
        end if;
        if vsync_edge = '1' then
		  
            if contador_nave < velocidad_nave then
                contador_nave <= contador_nave + 1;
            else
                contador_nave <= 0;
                if joystick_nave(3) = '1' and SPACESHIP_Y > 380 then
                    SPACESHIP_Y <= SPACESHIP_Y - 6;
                end if;
                if joystick_nave(2) = '1' and SPACESHIP_Y < 490 then
                    SPACESHIP_Y <= SPACESHIP_Y + 6;
                end if;
                if joystick_nave(1) = '1' and SPACESHIP_X < 750 then
                    SPACESHIP_X <= SPACESHIP_X + 6;
                end if;
                if joystick_nave(0) = '1' and SPACESHIP_X > 160 then
                    SPACESHIP_X <= SPACESHIP_X - 6;
                end if;
            end if;
	-- Código de una segunda nave que no se implementó
				if contador_nave_2 < velocidad_nave then
                contador_nave_2 <= contador_nave_2 + 1;
            else
                contador_nave_2 <= 0;
                if joystick_nave_2(1) = '1' and SPACESHIP2_X < 630 then
                    SPACESHIP2_X <= SPACESHIP2_X + 5;
                end if;
                if joystick_nave_2(0) = '1' and SPACESHIP2_X > 160 then
                    SPACESHIP2_X <= SPACESHIP2_X - 5;
                end if;
            end if;
				
        end if;
    end if;
end process;
process(CLK)
begin
    if rising_edge(CLK) then
        ship <= '0';
        
        if display_active = '1' and vsyncST_reg1(1) = '1' then
            for i in 0 to 29 loop
                if alien_activo(i) = '1' then 
                    if h_int >= aliens(i).x and h_int < aliens(i).x + 28 and
                       v_int >= aliens(i).y and v_int < aliens(i).y + 26 then
                        
                        
                        xc_reg <= aliens(i).x;
                        yc_reg <= aliens(i).y;
                    end if;
               end if;
            end loop;
            
            if h_int >= SPACESHIP_X and h_int < SPACESHIP_X + 28 and
               v_int >= SPACESHIP_Y and v_int < SPACESHIP_Y + 26 then
                ship <= '1';
            end if;
        end if;
        
        ch_reg <= h_int;
        cv_reg <= v_int;
    end if;
end process;

-- Process para detección de colision de los aliens con la nave en las condicionales
-- Igualmente es un process de detección de Win o Game over según sea el caso
-- Visualización de aliens activos, además de visualización de la nave y de la bala en caso de ser disparada.
-- Uso de los dibujadores del proyecto, del alien, de la nave y de la bala.
process(CLK, RST)
begin
	if RST = '0' then
        Game_Over <= '0';
		  contador_activos <= 30;
		  WINNER <= '0';
		  
    elsif rising_edge(CLK) then
				R_reg <= "0000"; 
				G_reg <= "0000";
				B_reg <= "0000";
        
        if display_active = '1' and vsyncST_reg2(1) = '1'then
				contador_activos <= 0;
				
			if WINNER = '1' then
			 
				WIN(ch_reg, cv_reg, x_ini, y_ini, Rd_reg, Gd_reg, Bd_reg, DRAW_reg_3);
				if DRAW_reg_3 = '1' then
                    R_reg <= Rd_reg;
                    G_reg <= Gd_reg;
                    B_reg <= Bd_reg;
                end if;
			else
          if  Game_Over = '1' then 
			 
					GO(ch_reg, cv_reg, x_ini, y_ini, Rd_reg, Gd_reg, Bd_reg, DRAW_reg_3);
                if DRAW_reg_3 = '1' then
                    R_reg <= Rd_reg;
                    G_reg <= Gd_reg;
                    B_reg <= Bd_reg;
                end if;
			else
				--Detección de colisión de algun alien con la nave
				if (
					 ((aliens(0).x + 28 >= SPACESHIP_X) and (aliens(0).x <= SPACESHIP_X + 28) and 
					 (aliens(0).y + 26 >= SPACESHIP_Y) and (aliens(0).y <= SPACESHIP_Y + 26)) or
					 ((aliens(1).x + 28 >= SPACESHIP_X) and (aliens(1).x <= SPACESHIP_X + 28) and 
					 (aliens(1).y + 26 >= SPACESHIP_Y) and (aliens(1).y <= SPACESHIP_Y + 26)) or
					 ((aliens(2).x + 28 >= SPACESHIP_X) and (aliens(2).x <= SPACESHIP_X + 28) and
					 (aliens(2).y + 26 >= SPACESHIP_Y) and (aliens(2).y <= SPACESHIP_Y + 26)) or
					 ((aliens(3).x + 28 >= SPACESHIP_X) and (aliens(3).x <= SPACESHIP_X + 28) and
					 (aliens(3).y + 26 >= SPACESHIP_Y) and (aliens(3).y <= SPACESHIP_Y + 26)) or
					 ((aliens(4).x + 28 >= SPACESHIP_X) and (aliens(4).x <= SPACESHIP_X + 28) and
					 (aliens(4).y + 26 >= SPACESHIP_Y) and (aliens(4).y <= SPACESHIP_Y + 26)) or
					 ((aliens(5).x + 28 >= SPACESHIP_X) and (aliens(5).x <= SPACESHIP_X + 28) and
					 (aliens(5).y + 26 >= SPACESHIP_Y) and (aliens(5).y <= SPACESHIP_Y + 26)) or
					 ((aliens(6).x + 28 >= SPACESHIP_X) and (aliens(6).x <= SPACESHIP_X + 28) and
					 (aliens(6).y + 26 >= SPACESHIP_Y) and (aliens(6).y <= SPACESHIP_Y + 26)) or
					 ((aliens(7).x + 28 >= SPACESHIP_X) and (aliens(7).x <= SPACESHIP_X + 28) and
					 (aliens(7).y + 26 >= SPACESHIP_Y) and (aliens(7).y <= SPACESHIP_Y + 26)) or
					 ((aliens(8).x + 28 >= SPACESHIP_X) and (aliens(8).x <= SPACESHIP_X + 28) and
					 (aliens(8).y + 26 >= SPACESHIP_Y) and (aliens(8).y <= SPACESHIP_Y + 26)) or
					 ((aliens(9).x + 28 >= SPACESHIP_X) and (aliens(9).x <= SPACESHIP_X + 28) and 
					 (aliens(9).y + 26 >= SPACESHIP_Y) and (aliens(9).y <= SPACESHIP_Y + 26)) or
					 ((aliens(10).x + 28 >= SPACESHIP_X) and (aliens(10).x <= SPACESHIP_X + 28) and 
					 (aliens(10).y + 26 >= SPACESHIP_Y) and (aliens(10).y <= SPACESHIP_Y + 26)) or
					 ((aliens(11).x + 28 >= SPACESHIP_X) and (aliens(11).x <= SPACESHIP_X + 28) and 
					 (aliens(11).y + 26 >= SPACESHIP_Y) and (aliens(11).y <= SPACESHIP_Y + 26)) or
					 ((aliens(12).x + 28 >= SPACESHIP_X) and (aliens(12).x <= SPACESHIP_X + 28) and
					 (aliens(12).y + 26 >= SPACESHIP_Y) and (aliens(12).y <= SPACESHIP_Y + 26)) or
					 ((aliens(13).x + 28 >= SPACESHIP_X) and (aliens(13).x <= SPACESHIP_X + 28) and
					 (aliens(13).y + 26 >= SPACESHIP_Y) and (aliens(13).y <= SPACESHIP_Y + 26)) or
					 ((aliens(14).x + 28 >= SPACESHIP_X) and (aliens(14).x <= SPACESHIP_X + 28) and
					 (aliens(14).y + 26 >= SPACESHIP_Y) and (aliens(14).y <= SPACESHIP_Y + 26)) or
					 ((aliens(15).x + 28 >= SPACESHIP_X) and (aliens(15).x <= SPACESHIP_X + 28) and
					 (aliens(15).y + 26 >= SPACESHIP_Y) and (aliens(15).y <= SPACESHIP_Y + 26)) or
					 ((aliens(16).x + 28 >= SPACESHIP_X) and (aliens(16).x <= SPACESHIP_X + 28) and
					 (aliens(16).y + 26 >= SPACESHIP_Y) and (aliens(16).y <= SPACESHIP_Y + 26)) or
					 ((aliens(17).x + 28 >= SPACESHIP_X) and (aliens(17).x <= SPACESHIP_X + 28) and
					 (aliens(17).y + 26 >= SPACESHIP_Y) and (aliens(17).y <= SPACESHIP_Y + 26)) or
					 ((aliens(18).x + 28 >= SPACESHIP_X) and (aliens(18).x <= SPACESHIP_X + 28) and
					 (aliens(18).y + 26 >= SPACESHIP_Y) and (aliens(18).y <= SPACESHIP_Y + 26)) or
					 ((aliens(19).x + 28 >= SPACESHIP_X) and (aliens(19).x <= SPACESHIP_X + 28) and 
					 (aliens(19).y + 26 >= SPACESHIP_Y) and (aliens(19).y <= SPACESHIP_Y + 26)) or
					 ((aliens(20).x + 28 >= SPACESHIP_X) and (aliens(20).x <= SPACESHIP_X + 28) and 
					 (aliens(20).y + 26 >= SPACESHIP_Y) and (aliens(20).y <= SPACESHIP_Y + 26)) or
					 ((aliens(21).x + 28 >= SPACESHIP_X) and (aliens(21).x <= SPACESHIP_X + 28) and 
					 (aliens(21).y + 26 >= SPACESHIP_Y) and (aliens(21).y <= SPACESHIP_Y + 26)) or
					 ((aliens(22).x + 28 >= SPACESHIP_X) and (aliens(22).x <= SPACESHIP_X + 28) and
					 (aliens(22).y + 26 >= SPACESHIP_Y) and (aliens(22).y <= SPACESHIP_Y + 26)) or
					 ((aliens(23).x + 28 >= SPACESHIP_X) and (aliens(23).x <= SPACESHIP_X + 28) and
					 (aliens(23).y + 26 >= SPACESHIP_Y) and (aliens(23).y <= SPACESHIP_Y + 26)) or
					 ((aliens(24).x + 28 >= SPACESHIP_X) and (aliens(24).x <= SPACESHIP_X + 28) and
					 (aliens(24).y + 26 >= SPACESHIP_Y) and (aliens(24).y <= SPACESHIP_Y + 26)) or
					 ((aliens(25).x + 28 >= SPACESHIP_X) and (aliens(25).x <= SPACESHIP_X + 28) and
					 (aliens(25).y + 26 >= SPACESHIP_Y) and (aliens(25).y <= SPACESHIP_Y + 26)) or
					 ((aliens(26).x + 28 >= SPACESHIP_X) and (aliens(26).x <= SPACESHIP_X + 28) and
					 (aliens(26).y + 26 >= SPACESHIP_Y) and (aliens(26).y <= SPACESHIP_Y + 26)) or
					 ((aliens(27).x + 28 >= SPACESHIP_X) and (aliens(27).x <= SPACESHIP_X + 28) and
					 (aliens(27).y + 26 >= SPACESHIP_Y) and (aliens(27).y <= SPACESHIP_Y + 26)) or
					 ((aliens(28).x + 28 >= SPACESHIP_X) and (aliens(28).x <= SPACESHIP_X + 28) and
					 (aliens(28).y + 26 >= SPACESHIP_Y) and (aliens(28).y <= SPACESHIP_Y + 26)) or
					 ((aliens(29).x + 28 >= SPACESHIP_X) and (aliens(29).x <= SPACESHIP_X + 28) and
					 (aliens(29).y + 26 >= SPACESHIP_Y) and (aliens(29).y <= SPACESHIP_Y + 26))
				) then
					 Game_Over <= '1';
				else
					 Game_Over <= '0';
				end if;
				
            for i in 0 to 29 loop
					 
                if alien_activo(i) = '1' then
					 contador_activos <= contador_activos + 1;
						if aliens(i).y >= 490 then 
							Game_Over <= '1';		
						elsif ((aliens(i).x >= SPACESHIP_X) and (aliens(i).x <= SPACESHIP_X + 35)
								and (aliens(i).y >= SPACESHIP_Y) and (aliens(i).y <= SPACESHIP_Y + 32)) then 
								Game_Over <= '1';	
						else
                    sq(ch_reg, cv_reg, xc_reg, yc_reg, Rd_reg, Gd_reg, Bd_reg, DRAW_reg);
                  end if; 
						
                    if DRAW_reg = '1' then
                        R_reg <= Rd_reg;
                        G_reg <= Gd_reg;
                        B_reg <= Bd_reg;
                    end if;
                end if;
            end loop;
				
					if contador_activos = 0 then
						WINNER <= '1';		
					end if;
            
            if ship = '1' then
                space(ch_reg, cv_reg, SPACESHIP_X, SPACESHIP_Y, Rd_reg, Gd_reg, Bd_reg, DRAW_reg);
                
                if DRAW_reg = '1' then
                    R_reg <= Rd_reg;
                    G_reg <= Gd_reg;
                    B_reg <= Bd_reg;
                end if;
            end if;
            
            if bala_activa = 1 then
                bullet(ch_reg, cv_reg, bullet_x, bullet_y, Rd_reg, Gd_reg, Bd_reg, DRAW_reg_2);
                if DRAW_reg_2 = '1' then
                    R_reg <= Rd_reg;
                    G_reg <= Gd_reg;
                    B_reg <= Bd_reg;
                end if;
            end if;
        end if;
		  end if;
   end if;
end if;
end process;

--Process de detección de colisiones con la bala, para desactivas aliens y activar balas según la posición de la nave.
process(CLK, RST)
begin
    if RST = '0' then
        alien_activo <= (others => '1');
        bala_activa <= 0;
    elsif rising_edge(CLK) then
        if vsync_edge = '1' then
            if bala_activa = 1 then
                for i in 0 to 29 loop
                    if alien_activo(i) = '1' then
                        if (bullet_x  >= aliens(i).x) and (bullet_x <= aliens(i).x + 25) and
                           (bullet_y <= aliens(i).y + 20) and (bullet_y >= aliens(i).y + 5) then
                            alien_activo(i) <= '0'; 
                            bala_activa <= 0;     
                        end if;
                    end if;
						 
                end loop;
            end if;
            
            if shot = '0' and bala_activa = 0 then
                bullet_x <= SPACESHIP_X + 14;
                bullet_y <= SPACESHIP_Y - 8;
                bala_activa <= 1;
            end if;
        
            if bala_activa = 1 then
                bullet_y <= bullet_y - velocidad_bullet;
        
                if bullet_y < 40 then
                    bala_activa <= 0;
                end if;
            end if;
        end if;
    end if;
end process;

end architecture RTL;