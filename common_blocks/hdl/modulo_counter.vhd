library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity modulo_counter is
    generic(
               THRESHOLD : integer := 16
           );
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            ce : in std_logic;
            thr : out std_logic;
            Q : out std_logic_vector(clog2(THRESHOLD) downto 0)
        );
end entity modulo_counter;


architecture rtl of modulo_counter is

    signal count : unsigned(clog2(THRESHOLD) downto 0);

begin

    process (clk) is
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                count <= (others => '0');
                thr <= '0';
            else
                thr <= '0';
                if count = to_unsigned(THRESHOLD,count'length) then
                    count <= (others => '0');
                    thr <= '1';
                elsif ce = '1' then
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    Q <= std_logic_vector(count);

end architecture rtl;

