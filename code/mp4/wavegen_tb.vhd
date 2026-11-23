library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use work.sine_package.all;

entity wavegen_tb is
end;

architecture bench of wavegen_tb is
    component wavegen
      port( clock, reset, enable: in std_logic;
            wave_out: out std_logic_vector(data_bits - 1 downto 0);
            JA: out std_logic_vector (data_bits - 1 downto 0));
    end component;

    signal clock, reset, enable: std_logic;
    signal wave_out, JA: std_logic_vector (data_bits - 1 downto 0);

    constant clock_period: time := 100 ns;

begin

  uut: wavegen port map ( clock => clock, reset => reset, enable => enable, wave_out => wave_out, JA => JA);

  stimulus: process
  begin
    enable <= '0';
    reset <= '1';
    wait for 10 ns;
    
    reset <= '0';
    wait for 100 ns;
    enable <= '1';
    wait for 1 sec;
  end process;

  clocking: process
  begin
      clock <= '1', '0' after clock_period / 2;
      wait for clock_period;
  end process;

end;
