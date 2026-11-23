-- Mini Project 4 - Part II: self-checking testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wave_package.all;

entity wavegen_tb is
end entity wavegen_tb;

architecture bench of wavegen_tb is
    constant clock_period : time := 10 ns;
    constant HALF_CYCLE  : integer := (max_address + 1) / 2;
    constant SINE_VALUES : rom_type := sine_rom;

    signal clock    : std_logic := '0';
    signal reset    : std_logic := '1';
    signal enable   : std_logic := '0';
    signal wave_sel : std_logic_vector(1 downto 0) := "00";
    signal sine_out : std_logic_vector(data_bits - 1 downto 0);
    signal JA       : std_logic_vector(data_bits - 1 downto 0);
begin
    clock <= not clock after clock_period / 2;

    uut : entity work.wavegen
        generic map (SAMPLE_DIV => 1) -- Fast simulation: one address per clock
        port map (
            clock    => clock,
            reset    => reset,
            enable   => enable,
            wave_sel => wave_sel,
            sine_out => sine_out,
            JA       => JA
        );

    stim_proc : process
        variable expected : std_logic_vector(data_bits - 1 downto 0);
        variable held     : std_logic_vector(data_bits - 1 downto 0);
    begin
        -- Reset the address before the first waveform.
        reset  <= '1';
        enable <= '0';
        wave_sel <= "00";
        wait for 20 ns;
        reset  <= '0';
        enable <= '1';

        -- Test ALL 256 addresses for each of the four switch settings.
        for mode in 0 to 3 loop
            if mode > 0 then
                wait until falling_edge(clock);
                reset  <= '1';
                enable <= '0';
                wave_sel <= std_logic_vector(to_unsigned(mode, 2));
                wait for clock_period;
                reset  <= '0';
                enable <= '1';
            end if;

            for i in 0 to max_address loop
                wait until rising_edge(clock);
                wait for 1 ns; -- allow registered outputs to update

                case mode is
                    when 0 => -- Sine wave
                        expected := std_logic_vector(SINE_VALUES(i));
                    when 1 => -- Square wave
                        if i < HALF_CYCLE then
                            expected := (others => '1');
                        else
                            expected := (others => '0');
                        end if;
                    when 2 => -- Triangle wave
                        if i = HALF_CYCLE - 1 or i = HALF_CYCLE then
                            expected := (others => '1');
                        elsif i < HALF_CYCLE then
                            expected := std_logic_vector(to_unsigned(i * 2, data_bits));
                        else
                            expected := std_logic_vector(
                                to_unsigned((max_address - i) * 2, data_bits)
                            );
                        end if;
                    when others => -- Zero output
                        expected := (others => '0');
                end case;

                assert sine_out = expected
                    report "sine_out mismatch, mode=" & integer'image(mode) &
                           " address=" & integer'image(i)
                    severity error;
                assert JA = expected
                    report "JA mismatch, mode=" & integer'image(mode) &
                           " address=" & integer'image(i)
                    severity error;
            end loop;
        end loop;

        -- Verify that enable='0' freezes a nonzero output.
        wait until falling_edge(clock);
        reset  <= '1';
        enable <= '0';
        wave_sel <= "01";
        wait for clock_period;
        reset  <= '0';
        enable <= '1';
        wait until rising_edge(clock);
        wait for 1 ns;
        assert sine_out = std_logic_vector(to_unsigned(255, data_bits))
            report "Square wave did not start HIGH" severity error;
        held := sine_out;
        wait until falling_edge(clock);
        enable <= '0';
        wait for 50 ns;
        assert sine_out = held and JA = held
            report "Outputs changed while disabled" severity error;

        -- Verify asynchronous reset clears both outputs immediately.
        reset <= '1';
        wait for 1 ns;
        assert sine_out = std_logic_vector(to_unsigned(0, data_bits)) and
               JA = std_logic_vector(to_unsigned(0, data_bits))
            report "Asynchronous reset did not clear outputs" severity error;

        report "PASS: sine, square, triangle, zero, enable hold, and reset" severity note;
        wait;
    end process;
end architecture bench;
