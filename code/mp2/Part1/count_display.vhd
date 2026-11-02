library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity count_display is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           leds : out STD_LOGIC_VECTOR (3 downto 0);
           sevenseg : out STD_LOGIC_VECTOR (6 downto 0);
           anode: out STD_LOGIC_VECTOR (3 downto 0));
end count_display;

architecture Behavioral of count_display is
 signal count_sig: STD_LOGIC_VECTOR (3 downto 0) := "0000";
 signal slow_clk: STD_LOGIC := '0';
begin
    --complete the architecture
    -- instantiate and port map the three components - clk_div, modMcounter and hex_7seg modules
    --refer to the block diagram in lab handout
    -- use the signals declared above in this architecture to wire between components (internally)
    --dont forget to include the generic map in addition to port map
    -- Clock divider: 100 MHz to 1 Hz
    U1: entity work.clk_div
        generic map (
            clk_in_freq  => 100000000,
            clk_out_freq => 1
        )
        port map (
            reset   => reset,
            clk_in  => clock,
            clk_out => slow_clk
        );

    -- 4-bit modulo-16 counter
    U2: entity work.modMCounter
        generic map (
            N => 4
        )
        port map (
            clk   => slow_clk,
            reset => reset,
            count => count_sig
        );

    -- Hexadecimal to 7-segment decoder
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
