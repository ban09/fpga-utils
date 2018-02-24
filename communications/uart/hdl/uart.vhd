-- UART top level
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
    port(
            clk : in std_logic;
            rst_n : in std_logic 
        );
end entity uart;

architecture rtl of uart is

begin		
    process (clk, rst_n)
    begin

        if a = '1' then
            f <= '1';
        end if;

    end process;
end architecture rtl;
