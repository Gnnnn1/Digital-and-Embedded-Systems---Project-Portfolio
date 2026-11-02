library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_div is
    generic (clk_in_freq : natural;  clk_out_freq : natural);
    port ( reset : in std_logic;
        clk_in : in std_logic;
        clk_out: out std_logic);
end clk_div;

architecture behav of clk_div is
    constant MAX_COUNT : integer := (clk_in_freq/clk_out_freq)-1;
    signal clk_sig: std_logic := '0';
begin
    process(clk_in, reset)
        variable count : integer range 0 to MAX_COUNT; 
    begin
        if(reset = '1') then
            count := 0;
            clk_sig <= '0';
        elsif(rising_edge(clk_in)) then --rising edge
        --complete the code by including another if..else statement (nested)--------
        --if maximum count is reached, reset the count value and toggle the clk_sig
        --else increment the count value
           if count = MAX_COUNT then
                count := 0;
                clk_sig <= not clk_sig;
            else
                count := count + 1;
            end if;
        end if;
    end process;

    clk_out <= clk_sig;
end behav;