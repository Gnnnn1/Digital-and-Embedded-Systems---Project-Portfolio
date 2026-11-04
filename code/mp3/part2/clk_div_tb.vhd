library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Optional divider test. Part II does not require top-level simulation.
entity clk_div_tb is
end clk_div_tb;

architecture Behavioral of clk_div_tb is
    constant CLK_PERIOD : time := 10 ns;
    signal reset   : STD_LOGIC := '1';
    signal clk_in  : STD_LOGIC := '0';
    signal clk_out : STD_LOGIC;
    signal run_clock : boolean := true;
begin
    UUT : entity work.clk_div
        generic map (
            clk_in_freq  => 100_000_000,
            clk_out_freq => 500
        )
        port map (
            reset => reset,
            clk_in => clk_in,
            clk_out => clk_out
        );

    clk_proc : process
    begin
        while run_clock loop
            clk_in <= '0';
            wait for CLK_PERIOD/2;
            clk_in <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc : process
        variable first_rise : time;
    begin
        wait for 20 ns;
        reset <= '0';
        wait until rising_edge(clk_out);
        first_rise := now;
        wait until rising_edge(clk_out);
        assert now - first_rise = 2 ms
            report "Divider output is not 500 Hz" severity error;
        report "Divider frequency test passed (500 Hz)" severity note;
        run_clock <= false;
        wait;
    end process;
end Behavioral;
