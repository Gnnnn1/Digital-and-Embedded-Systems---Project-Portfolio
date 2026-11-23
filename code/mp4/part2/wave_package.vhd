-- Mini Project 4 - Part II
-- Shared 256 x 8-bit sine lookup-table package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package wave_package is
    constant addr_bits : integer range 1 to 30 := 8;
    constant data_bits : integer range 1 to 31 := 8;
    subtype addr_range is integer range 0 to 2**addr_bits - 1;
    constant max_address : integer := 2**addr_bits - 1;

    type rom_type is array (addr_range) of unsigned(data_bits - 1 downto 0);
    function sine_rom return rom_type;
end package wave_package;

package body wave_package is
    function sine_rom return rom_type is
        variable sine_table : rom_type;
        variable angle : real;
        variable sin_scaled : real;
    begin
        for i in addr_range loop
            angle := real(i) * (2.0 * MATH_PI / (2.0**addr_bits));
            sin_scaled := (1.0 + sin(angle)) * (2.0**data_bits - 1.0) / 2.0;
            sine_table(i) := to_unsigned(integer(round(sin_scaled)), data_bits);
        end loop;
        return sine_table;
    end function sine_rom;
end package body wave_package;
