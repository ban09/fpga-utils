library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity baudrate_gen is
    generic(
               CLK_FREQ : natural := 100000000;
               BAUDRATE : natural := 9600);
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            tick : out std_logic);
end entity baudrate_gen;

architecture rtl of baudrate_gen is

    constant TICK_COUNTER_THR : integer 
    := integer(ceil(real(CLK_FREQ)/real(BAUDRATE)));
    constant TICK_COUNTER_WIDTH : integer 
    := integer(ceil(log2(real(TICK_COUNTER_THR))));

    signal tick_counter : unsigned(TICK_COUNTER_WIDTH-1 downto 0);

begin

    process (clk, rst_n) is
    begin
        if rst_n = '0' then
            tick_counter <= (others => '0');
            tick <= '0';
        elsif rising_edge(clk) then
            tick <= '0';
            if tick_counter = to_unsigned(TICK_COUNTER_THR,tick_counter'length) then
                tick_counter <= (others => '0');
                tick <= '1';
            else
                tick_counter <= tick_counter + 1;
            end if;
        end if;
    end process;

end architecture rtl;
