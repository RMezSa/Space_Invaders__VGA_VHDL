------------------------------------------
--	 	Materia: Diseño con lógica programable
--		Reto Space Invaders
--		INTEGRANTES:
--		Roberd Otoniel Meza Sainz
-- 	Miguel Bandian Reyes Serrato
--
------------------------------------------

-- Maquina de estados vertical para VGA
library ieee;
use ieee.std_logic_1164.ALL;

entity Estados_VGA_V is
    port(
        CLK, RST: in std_logic;
        START: in std_logic;
        vcount: in std_logic_vector(9 downto 0);
        vsyncST: out std_logic_vector(1 downto 0);
        vsync: out std_logic
    );
end entity;

architecture RTL of Estados_VGA_V is
    type EDOS is (IDLE, DISPLAY, FPORCH, BPORCH, SYNC);
    signal EDO, EDOF: EDOS;
begin

    P0: process(CLK, RST) is
    begin 
        if RST = '0' then
            EDO <= IDLE;
        elsif rising_edge(CLK) then  
            EDO <= EDOF;
        end if;
    end process;

	 --Transicion de estados
    P1: process (EDO, vcount, START) is
    begin
        case EDO is
            when IDLE =>
                if (START = '1') then
                    EDOF <= SYNC;
                else
                    EDOF <= IDLE;
                end if;

            when SYNC =>
                if (vcount = "0000000010") then  -- vcount = 2
                    EDOF <= BPORCH;
                else
                    EDOF <= SYNC;
                end if;

            when BPORCH =>
                if (vcount = "0000100011") then  -- vcount = 35
                    EDOF <= DISPLAY;
                else
                    EDOF <= BPORCH;
                end if;

            when DISPLAY =>
                if (vcount = "1000000011") then  -- vcount = 515
                    EDOF <= FPORCH;
                else
                    EDOF <= DISPLAY;
                end if;

            when FPORCH =>
                if (vcount = "0000000000") then  
                    EDOF <= IDLE;
                else
                    EDOF <= FPORCH;
                end if;

            when others => NULL;
        end case;
    end process;

    -- Salida de vsyncST para saber en que estado está
    P3: process(EDO) is
    begin
        case EDO is
            when SYNC =>
                vsync <= '0';
                vsyncST <= "00";
                
            when BPORCH =>
                vsync <= '1';
                vsyncST <= "01";
                
            when DISPLAY =>
                vsync <= '1';
                vsyncST <= "10";
                
            when FPORCH =>
                vsync <= '1';
                vsyncST <= "11";
                
            when others => NULL;
        end case;
    end process;

end architecture RTL;
