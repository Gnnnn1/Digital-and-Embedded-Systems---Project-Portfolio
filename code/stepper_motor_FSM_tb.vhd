library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stepper_motor_FSM_tb is
end stepper_motor_FSM_tb;

architecture Behavioral of stepper_motor_FSM_tb is

    constant CLK_PERIOD : time := 10 us;

    signal clk : STD_LOGIC := '0';
    signal dir : STD_LOGIC := '1';
    signal en  : STD_LOGIC := '0';
    signal q   : STD_LOGIC_VECTOR(3 downto 0);

    signal run_clock : boolean := true;

begin

    UUT : entity work.stepper_motor_FSM
        port map (
            clk => clk,
            dir => dir,
            en  => en,
            q   => q
        );

    -- Clock-generation process: 10 us per complete cycle.
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

    -- Input stimuli and automatic output checks.
    stim_proc : process
        procedure check_step(constant expected : in STD_LOGIC_VECTOR(3 downto 0)) is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;  -- Allow state and q to update.
            assert q = expected
                report "Stepper motor output did not match the expected state."
                severity error;
        end procedure;
    begin
        -- Initially disabled: S0 = 0000.
        wait for 1 ns;
        assert q = "0000"
            report "Initial output should be 0000."
            severity error;

        wait until falling_edge(clk);
        en  <= '1';
        dir <= '1';

        -- Four clockwise steps: S1, S2, S3, S4.
        check_step("0001");
        check_step("0010");
        check_step("0100");
        check_step("1000");

        -- Four counterclockwise steps: S3, S2, S1, S4.
        dir <= '0';
        check_step("0100");
        check_step("0010");
        check_step("0001");
        check_step("1000");

        -- Disable: next rising edge returns to S0.
        en <= '0';
        check_step("0000");

        -- Additional check: startup in counterclockwise direction.
        en  <= '1';
        dir <= '0';
        check_step("1000");

        -- Change direction while enabled.
        dir <= '1';
        check_step("0001");

        -- Return to idle.
        en <= '0';
        check_step("0000");

        report "All stepper motor FSM tests completed." severity note;
        run_clock <= false;
        wait;
    end process;

end Behavioral;
