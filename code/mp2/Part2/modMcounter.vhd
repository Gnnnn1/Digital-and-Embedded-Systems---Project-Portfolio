-- modMCounter.vhd
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modMCounter is
    generic ( N : integer := 3);   -- N bits required to count upto M given by 2^N >= M
    port(
            clk, reset : in std_logic;
            count : out std_logic_vector(N-1 downto 0)
    );
end modMCounter;

architecture arch of modMCounter is
    signal count_reg : unsigned(N-1 downto 0); --count value
begin
    process(clk, reset) --fill sensitivity list for this process
    begin
       --complete the code for counter logic
       -- when reset signal is high, reset the value of count_reg (N bits length) to all 0's. hint: use others <= '0'
       --else on rising edge of clock, increment the count value by 1
       if (reset = '1') then
            count_reg <= (others => '0');

        elsif (rising_edge(clk)) then
            count_reg <= count_reg + 1;
        end if;
         
    end process;
    count <= std_logic_vector (count_reg);
end arch;