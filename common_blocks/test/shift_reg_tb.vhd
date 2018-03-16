library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg_tb is
    end entity shift_reg_tb;

architecture test of shift_reg_tb is

    constant DEPTH : integer := 10;
    constant WIDTH : integer := 2;

    signal clk :  std_logic := '0';
    signal ce :  std_logic := '0';
    signal din :  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal dout :  std_logic_vector(WIDTH-1 downto 0);

    procedure wait_ncycles(n : in integer) is
    begin
        for i in 0 to n loop
            wait until clk = '1';
        end loop;
    end procedure wait_ncycles;

begin

    DUT : entity work.shift_reg 
    generic map(
                   DEPTH => DEPTH,
                   WIDTH => WIDTH
               )
    port map(
                clk => clk,
                ce => ce,
                din => din,
                dout => dout);

    process is
    begin
        wait_ncycles(5);
        ce <= '1';
        din <= (others => '1');
        wait_ncycles(1);
        din <= (others => '0');
        wait;
    end process;

    clk <= not clk after 5 ns;


end architecture test;
