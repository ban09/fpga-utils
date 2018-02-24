library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tb is
    end entity uart_tb;

architecture test of uart_tb is

    signal clk, rst_n : std_logic := '1';
    signal tx, debug : std_logic;

begin

    clk <= not clk after 5 ns;

    DUT : entity work.uart
    port map (
                 clk => clk,
                 rst_n => rst_n,
                 tx_pin => tx,
                 debug => debug);

    process is
    begin
        rst_n <= '1';
        wait until clk = '1';
        rst_n <= '0';
        wait until clk = '1';
        wait until clk = '1';
        wait until clk = '1';
        rst_n <= '1';
        wait until clk = '1';
        wait;
    end process;
        
end architecture test;
