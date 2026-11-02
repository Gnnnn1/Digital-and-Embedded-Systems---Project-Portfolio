library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity car_warnlight is
    Port (
        door_closed      : in  STD_LOGIC;  -- D
        key_in           : in  STD_LOGIC;  -- K
        seat_pressure    : in  STD_LOGIC;  -- P
        seat_belt_closed : in  STD_LOGIC;  -- S

        light_en         : out STD_LOGIC;  -- Warning light W
        STATUS           : out STD_LOGIC_VECTOR(1 downto 0)
    );
end car_warnlight;


architecture Behavioral of car_warnlight is

    -- Internal warning signals
    signal door_warning : STD_LOGIC;
    signal belt_warning : STD_LOGIC;

begin

    -- Door warning:
    -- Key is inserted AND door is open
    door_warning <= key_in AND NOT(door_closed);

    -- Seat-belt warning:
    -- Key is inserted AND person is seated AND belt is not fastened
    belt_warning <= key_in AND seat_pressure AND NOT(seat_belt_closed);

    -- Warning light turns ON whenever either warning is active
    light_en <= door_warning OR belt_warning;

    -- Warning STATUS
    -- 00 = No warning
    -- 01 = Door warning only
    -- 10 = Seat-belt warning only
    -- 11 = Both warnings
    STATUS <= "11" when (door_warning = '1' AND belt_warning = '1') else
              "01" when (door_warning = '1') else
              "10" when (belt_warning = '1') else
              "00";

end Behavioral;