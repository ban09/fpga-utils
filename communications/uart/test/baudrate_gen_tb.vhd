library ieee;
use ieee.std_logic_1164.all;

entity baudrate_gen_tb is
    end entity baudrate_gen_tb;

architecture test of baudrate_gen_tb is
    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal tick : std_logic;
begin

    DUT : entity work.baudrate_gen
    generic map (
                    CLK_FREQ => 100000000,
                    BAUDRATE => 9600)
    port map(
                clk => clk,
                rst_n => rst_n,
                tick => tick);

    clk <= not clk after 5 ns;

    process is
    begin
        rst_n <= '1';
        wait until clk = '1';
        rst_n <= '0';
        wait until clk = '1';
        wait until clk = '1';
        rst_n <= '1';
        wait;
    end process;

end architecture test;
