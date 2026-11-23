library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--1. include the wave_package
use work.sine_package.all; 
 

entity wavegen is
  port( clock, reset, enable: in std_logic;
        wave_out: out std_logic_vector(data_bits - 1 downto 0);
        JA: out std_logic_vector (data_bits - 1 downto 0));
end;

architecture arch1 of wavegen is
      signal addr: integer range 0 to max_address;
	  --2. declare a signal sine_table of type ROM_type
      signal sine_table: rom_type;
	   
      signal sine_vector: std_logic_vector(data_bits - 1 downto 0);
begin
    --3. call the function sine_rom defined in the package and store results in signal sine_table
    sine_table <= sine_rom; 
	 
    process (clock)
    begin
        if (reset = '1') then
            sine_vector <= (others => '0');
            addr <= 0;
        elsif (rising_edge (clock)) then
            if (enable = '1') then 
			    --4. sine_vector = the value in the "sine_table" at location "addr". Note data types must be matched between LHS and RHS
                sine_vector <= std_logic_vector(sine_table(addr));
                 
                if (addr = max_address)then
                      addr <= 0;
                else
                      addr <= addr + 1;
                end if;
            end if;
        end if;
    end process;
    JA <= sine_vector;
    wave_out <= sine_vector;
end;

