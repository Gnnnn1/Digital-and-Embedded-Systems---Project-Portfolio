library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Updated Part I testbench, adding the reset port and a reset check.
entity stepper_motor_FSM_tb is
end stepper_motor_FSM_tb;

architecture Behavioral of stepper_motor_FSM_tb is
    constant CLK_PERIOD : time := 10 us;
    signal clk   : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal dir   : STD_LOGIC := '1';
    signal en    : STD_LOGIC := '0';
    signal q     : STD_LOGIC_VECTOR(3 downto 0);
    signal run_clock : boolean := true;
begin
    UUT : entity work.stepper_motor_FSM
        port map (
            clk => clk, reset => reset, dir => dir, en => en, q => q
        );

    clk_proc : process
    begin
        while run_clock loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    stim_proc : process
        procedure check_step(
            constant expected : in STD_LOGIC_VECTOR(3 downto 0)
        ) is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;
            assert q = expected
                report "Output did not match expected FSM state."
                severity error;
        end procedure;
    begin
        wait for 1 ns;
        assert q = "0000" report "Initial q must be 0000" severity error;

        wait until falling_edge(clk);
        reset <= '0';
        en <= '1';
        dir <= '1';
        check_step("0001");
        check_step("0010");
        check_step("0100");
        check_step("1000");

        dir <= '0';
        check_step("0100");
        check_step("0010");
        check_step("0001");
        check_step("1000");

        en <= '0';
        check_step("0000");

        en <= '1';
        dir <= '0';
        check_step("1000");

        dir <= '1';
        check_step("0001");

        -- Demonstrate asynchronous reset while the FSM is enabled.
        reset <= '1';
        wait for 1 ns;
        assert q = "0000"
            report "Asynchronous reset must return to S0 immediately"
            severity error;

        report "All Stepper Motor FSM tests passed" severity note;
        run_clock <= false;
        wait;
    end process;
end Behavioral;
