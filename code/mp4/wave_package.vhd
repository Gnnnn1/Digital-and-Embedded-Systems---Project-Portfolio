library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all; 
use ieee.std_logic_textio.all;

package sine_package is
    constant addr_bits : integer range 1 to 30 := 8;
    constant data_bits : integer range 1 to 31 := 8;
    subtype addr_range is integer range 0 to 2**addr_bits - 1;
    constant max_address: integer := 2**addr_bits - 1;

	--1. declare a type named "rom_type" which is array with range of addr_range and of type unsigned (vector size = data_bits)
    type rom_type is array (addr_range) of unsigned(data_bits-1 downto 0);
	--3. declare function prototype for sine_rom function
    function sine_rom return rom_type;
 
end;

package body sine_package is

    --2. fill in the blank
    function sine_rom return rom_type is
          variable sine_table : rom_type;
          variable angle : real;
          variable sin_scaled : real;
    begin
         for i in addr_range loop
		    --4. write VHDL expression for angle, given by angle = i * (2 * PI/ 2 ^ addr_bits). Note that i must be typecast to real. 
                    --you can see the next statement below to get an idea of how to use the operations.
             angle := real(i) * (2.0 * MATH_PI / (2.0**addr_bits));
			 
            sin_scaled := (1.0 + sin(angle)) * (2.0**data_bits - 1.0) / 2.0;
            sine_table(i) := to_unsigned(integer(round(sin_scaled)), data_bits);
           end loop;
       return sine_table;
    end ;
end;