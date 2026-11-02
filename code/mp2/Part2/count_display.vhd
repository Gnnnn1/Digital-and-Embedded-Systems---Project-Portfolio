
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity count_display is
    generic (
        DEBOUNCE_CYCLES : positive := 2_000_000
    );
    Port (
        clock     : in STD_LOGIC;
        btn_count : in STD_LOGIC;
        btn_reset : in STD_LOGIC;
        leds      : out STD_LOGIC_VECTOR(3 downto 0);
        sevenseg  : out STD_LOGIC_VECTOR(6 downto 0);
        anode     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end count_display;

architecture Behavioral of count_display is

    signal count_sig : STD_LOGIC_VECTOR(3 downto 0)
                       := "0000";

    signal btn_db_sig : STD_LOGIC := '0';

begin

    -- Button debounce module
    U1: entity work.button_debounce
    generic map (
        STABLE_CYCLES => DEBOUNCE_CYCLES
    )
    port map (
        clk_in => clock,
        reset  => btn_reset,
        btn_in => btn_count,
        btn_db => btn_db_sig
    );

    -- 4-bit modulo-16 counter
    U2: entity work.modMCounter
        generic map (
            N => 4
        )
        port map (
            clk   => btn_db_sig,
            reset => btn_reset,
            count => count_sig
        );

    -- Hexadecimal to seven-segment decoder
    U3: entity work.hex_7seg
        port map (
            hexdigit => count_sig,
            seg      => sevenseg
        );

    -- Display binary count on LEDs
    leds <= count_sig;

    -- Enable rightmost seven-segment digit
    anode <= "1110";

end Behavioral;
