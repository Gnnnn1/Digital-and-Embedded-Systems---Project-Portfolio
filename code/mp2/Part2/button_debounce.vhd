
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debounce is
    generic (
        STABLE_CYCLES : positive := 2_000_000
    );
    port (
        clk_in : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        btn_in : in  STD_LOGIC;
        btn_db : out STD_LOGIC
    );
end button_debounce;

architecture Behavioral of button_debounce is

    signal btn1, btn2 : STD_LOGIC := '0';
    signal btn_stable : STD_LOGIC := '0';

    signal count : integer range 0 to STABLE_CYCLES := 0;

begin

    process(clk_in, reset)
    begin

        if reset = '1' then
            btn1 <= '0';
            btn2 <= '0';
            btn_stable <= '0';
            count <= 0;

        elsif rising_edge(clk_in) then

            -- Read button input into internal signals
            btn1 <= btn_in;
            btn2 <= btn1;

            -- If the button matches the accepted state,
            -- there is no new press or release to check.
            if btn2 = btn_stable then
                count <= 0;

            else
                -- The button has changed, count how long it stays at the new value.
                if count < STABLE_CYCLES - 1 then
                    count <= count + 1;

                else
                    -- The new value has remained stable for enough cycles
                    btn_stable <= btn2;
                    count <= 0;

                end if;
            end if;

        end if;
    end process;

    -- Send the clean button signal to the counter.
    btn_db <= btn_stable;

end Behavioral;