library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level module for the Basys3 stepper motor controller.
entity Stepper_Controller is
    Port (
        clk   : in  STD_LOGIC;  -- 100 MHz Basys3 board clock
        reset : in  STD_LOGIC;  -- active HIGH, center pushbutton
        en    : in  STD_LOGIC;  -- enable, SW1
        dir   : in  STD_LOGIC;  -- direction, SW0
        q     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Stepper_Controller;

architecture Behavioral of Stepper_Controller is
    signal slow_clk : STD_LOGIC;
begin

    U_CLK_DIV : entity work.clk_div
        generic map (
            clk_in_freq  => 100_000_000,
            clk_out_freq => 500
        )
        port map (
            reset   => reset,
            clk_in  => clk,
            clk_out => slow_clk
        );

    U_STEPPER_FSM : entity work.stepper_motor_FSM
        port map (
            clk   => slow_clk,
            reset => reset,
            en    => en,
            dir   => dir,
            q     => q
        );

end Behavioral;
