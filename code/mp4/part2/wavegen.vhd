-- Mini Project 4 - Part II: sine, square, triangle, or zero
-- Physical board: SAMPLE_DIV=400 -> 100 MHz / 400 = 250 ksample/s
-- Testbench: override SAMPLE_DIV=1 for quick simulation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wave_package.all;

entity wavegen is
    generic (
        SAMPLE_DIV : positive := 400
    );
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        enable   : in  std_logic;
        wave_sel : in  std_logic_vector(1 downto 0);
        sine_out : out std_logic_vector(data_bits - 1 downto 0);
        JA       : out std_logic_vector(data_bits - 1 downto 0)
    );
end entity wavegen;

architecture arch1 of wavegen is
    constant HALF_CYCLE : integer := (max_address + 1) / 2; -- 128

    signal addr           : integer range 0 to max_address := 0;
    signal sample_counter : integer range 0 to SAMPLE_DIV - 1 := 0;
    signal sine_table     : rom_type;
    signal selected_wave  : std_logic_vector(data_bits - 1 downto 0) := (others => '0');
begin
    -- Generate the same sine lookup table used in Part I.
    sine_table <= sine_rom;

    process (clock, reset)
    begin
        if reset = '1' then
            addr           <= 0;
            sample_counter <= 0;
            selected_wave  <= (others => '0');
        elsif rising_edge(clock) then
            if enable = '1' then
                if sample_counter = SAMPLE_DIV - 1 then
                    sample_counter <= 0;

                    case wave_sel is
                        when "00" => -- Sine: lookup table
                            selected_wave <= std_logic_vector(sine_table(addr));

                        when "01" => -- Square: first 128 high, next 128 low
                            if addr < HALF_CYCLE then
                                selected_wave <= (others => '1');
                            else
                                selected_wave <= (others => '0');
                            end if;

                        when "10" => -- Triangle: ramp up, then ramp down
                            -- For the 8-bit ROM, address 0..127 rises to 255,
                            -- then 128..255 falls back to 0.
                            if addr = HALF_CYCLE - 1 or addr = HALF_CYCLE then
                                selected_wave <= (others => '1'); -- full-scale peak
                            elsif addr < HALF_CYCLE then
                                selected_wave <= std_logic_vector(
                                    to_unsigned(addr * 2, data_bits)
                                );
                            else
                                selected_wave <= std_logic_vector(
                                    to_unsigned((max_address - addr) * 2, data_bits)
                                );
                            end if;

                        when others => -- "11": output zero
                            selected_wave <= (others => '0');
                    end case;

                    -- Same 256-address progression for all waveforms.
                    if addr = max_address then
                        addr <= 0;
                    else
                        addr <= addr + 1;
                    end if;
                else
                    sample_counter <= sample_counter + 1;
                end if;
            end if; -- enable='0': hold address, counter, and output
        end if;
    end process;

    JA       <= selected_wave;
    sine_out <= selected_wave;
end architecture arch1;
