library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use STD.textio.all;
use IEEE.std_logic_textio.all;

Entity car_warnlight_tb Is
end car_warnlight_tb;

Architecture behavior of car_warnlight_tb Is
	Component car_warnlight is
	port (
	       door_closed : in STD_LOGIC;
               key_in : in STD_LOGIC;
               seat_pressure : in STD_LOGIC;
               seat_belt_closed: in STD_LOGIC;
               light_en : out STD_LOGIC
		);	
	End Component;
	Signal count : STD_LOGIC_VECTOR(3 downto 0) := X"0";
	Signal D, K, P, S, L : STD_LOGIC;
               		
begin
	uut: car_warnlight PORT MAP (
			door_closed => D, key_in => K, seat_pressure => P, seat_belt_closed => S, light_en => L);
		 
	process
	begin
        for i in 0 to 15 loop   	         	  
		  D <= count (3);
		  K <= count (2);
		  P <= count (1);
		  S <= count (0);
		  count <= count + 1;
		   wait for 50 ns;
        end loop;		 
       
	end process;
end behavior;
