
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_tx_tb is
    end entity uart_tx_tb;

architecture test of uart_tx_tb is

    signal clk : std_logic := '0';
    signal rst_n :  std_logic := '0';
    signal ce : std_logic := '0';
    signal load : std_logic := '0';
    signal ready : std_logic;
    signal din : std_logic_vector(7 downto 0) := (others => '0');
    signal dout : std_logic;


    type test_vector_t is array (0 to 3) of std_logic_vector(7 downto 0);
    signal test_vector : test_vector_t := (x"FF", x"00", x"AA", x"EE");
    signal enable : std_logic := '0';

    signal start_sim, stop_sim : std_logic := '0';
begin

    clk <= not clk after 5 ns;
    -- Reset generation.
    process is
    begin
        rst_n <= '1';
        wait until clk = '1';
        rst_n <= '0';
        wait until clk = '1';
        wait until clk = '1';
        rst_n <= '1';
        wait until clk = '1';
        start_sim <= '1'; 
        wait;
    end process;

    DUT : entity work.uart_tx 
    port map(
                clk => clk,
                rst_n => rst_n,
                ce => ce,
                load => load,
                ready => ready,
                din => din,
                dout => dout); 

    -- Producer
    producer : process is 
        variable i : integer := 0;
    begin
        if start_sim = '1' and stop_sim = '0' then
            wait until clk = '1';
            if ready = '1' then
                while i < 4 loop
                    load <= '1';
                    din <= test_vector(i);
                    i := i + 1;
                    wait until clk = '1';
                    load <= '0';
                    wait until ready = '1';
                    wait until clk = '1';
                end loop;
                stop_sim <= '1';
            else
                wait until clk = '1';
            end if;
        else
            wait until clk = '1';
        end if;
    end process producer;

-- Consumer
    consumer : process is 
    begin
        wait until clk = '1';
    end process consumer;

-- Clock enable generation:
    process is
    begin
        enable <= '0';
        wait until clk = '1';
        wait until clk = '1';
        wait until clk = '1';
        enable <= '1';
        wait until clk = '1';
    end process;
    ce <= enable and (not ready);
end architecture test; 
