----------------------------------------------------------------------------------
-- Company: Humber College
-- Engineer: Raji
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity car_warnlight is
port (
	       door_closed : in STD_LOGIC; -----input D
               key_in : in STD_LOGIC;      -----input K
               seat_pressure : in STD_LOGIC; -----input P
               seat_belt_closed: in STD_LOGIC; ----input S
               light_en : out STD_LOGIC  -----output L
		);	
end car_warnlight;
architecture Behavioral of car_warnlight is 
begin
   light_en <=  (NOT(door_closed)AND key_in) OR (key_in AND seat_pressure AND NOT(seat_belt_closed));
end Behavioral;