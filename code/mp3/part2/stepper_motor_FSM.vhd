library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 4-coil wave-drive sequencer with reset (required for Part II).
-- dir = '1': S1 -> S2 -> S3 -> S4 -> S1
-- dir = '0': S4 -> S3 -> S2 -> S1 -> S4
-- en = '0': enter S0 on the next rising clock edge.
-- reset = '1': immediately enter S0.
entity stepper_motor_FSM is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        dir   : in  STD_LOGIC;
        en    : in  STD_LOGIC;
        q     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end stepper_motor_FSM;

architecture Behavioral of stepper_motor_FSM is
    type state_type is (S0, S1, S2, S3, S4);
    signal state : state_type := S0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= S0;
        elsif rising_edge(clk) then
            if en = '0' then
                state <= S0;
            elsif dir = '1' then
                case state is
                    when S0 => state <= S1;
                    when S1 => state <= S2;
                    when S2 => state <= S3;
                    when S3 => state <= S4;
                    when S4 => state <= S1;
                end case;
            else
                case state is
                    when S0 => state <= S4;
                    when S1 => state <= S4;
                    when S2 => state <= S1;
                    when S3 => state <= S2;
                    when S4 => state <= S3;
                end case;
            end if;
        end if;
    end process;

    with state select
        q <= "0000" when S0,
             "0001" when S1,
             "0010" when S2,
             "0100" when S3,
             "1000" when S4;
end Behavioral;
