library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity modulo_counter_tb is
    end entity modulo_counter_tb;

architecture test of modulo_counter_tb is

    constant THRESHOLD : integer := 7;

    signal clk :  std_logic := '0';
    signal rst_n :  std_logic := '1';
    signal ce :  std_logic := '0';
    signal thr :  std_logic;
    signal Q :  std_logic_vector(clog2(THRESHOLD)-1 downto 0);

    signal start_sim : std_logic := '0';

    procedure wait_ncycles(n : in integer) is
    begin
        for i in 0 to n loop
            wait until clk = '1';
        end loop;
    end procedure wait_ncycles;

begin

    clk <= not clk after 5 ns;

    DUT : entity work.modulo_counter
    generic map(
        THRESHOLD => THRESHOLD)
    port map(
        clk => clk,
        rst_n => rst_n,
        ce => ce,
        thr => thr,
        Q => Q);

    process is
    begin
        rst_n <= '1';
        wait_ncycles(1);
        rst_n <= '0';
        wait_ncycles(2);
        rst_n <= '1';
        start_sim <= '1';
        wait;        
    end process;

    process is
    begin
        if start_sim = '1' then
            ce <= '1';
            for i in 0 to THRESHOLD loop
           --     assert to_integer(unsigned(Q)) = i report "Q != i" severity failure;
                wait_ncycles(1);
            end loop;
            for i in 0 to THRESHOLD loop
                ce <= '0';
                wait_ncycles(1);
                ce <= '1';
                wait_ncycles(1);
            end loop;
        else
            wait_ncycles(1);
        end if;
    end process;

end architecture test;


