library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Clock divider with 50% duty cycle and active-HIGH asynchronous reset.
-- Output frequency = clk_in_freq / (2 * HALF_PERIOD_CYCLES).
entity clk_div is
    generic (
        clk_in_freq  : natural := 100_000_000;
        clk_out_freq : natural := 500
    );
    port (
        reset   : in  STD_LOGIC;
        clk_in  : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end clk_div;

architecture Behavioral of clk_div is
    constant HALF_PERIOD_CYCLES : natural := clk_in_freq / (2 * clk_out_freq);
    signal count   : natural range 0 to HALF_PERIOD_CYCLES - 1 := 0;
    signal clk_sig : STD_LOGIC := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            count   <= 0;
            clk_sig <= '0';
        elsif rising_edge(clk_in) then
            if count = HALF_PERIOD_CYCLES - 1 then
                count   <= 0;
                clk_sig <= not clk_sig;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_sig;
end Behavioral;
