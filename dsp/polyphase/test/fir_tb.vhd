library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.file_utils.all;



entity fir_tb is
    end entity fir_tb;

architecture test of fir_tb is

    constant DATA_WIDTH : natural := 8;
    constant DECIMATION_FACTOR : natural := 10;

    signal clk, rst_n : std_logic := '1';
    signal din : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal din_v: std_logic := '0';
    signal dout : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dout_v : std_logic;

    signal start_sim : std_logic := '0';
    signal stop_sim : std_logic := '0';


begin

    clk <= not clk after 5 ns;

    DUT : entity work.fir 
    generic map(DATA_WIDTH)
    port map(clk,rst_n,din,din_v,dout,dout_v);

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
        start_sim <= '1';
        wait;
    end process;

    -- Producer
    process is
        file fin : binary_file_t open read_mode is "test_data";
        variable buff : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        if start_sim = '1' then
            if not endfile(fin) then
                read_word(fin,1,buff);
                din <= buff;
                din_v <= '1';
            else
                stop_sim <= '1';
            end if;
        end if;
        wait until clk = '1';
    end process;

    -- Consumer
    process is
        file fout : binary_file_t open write_mode is "../../../../../../model/out_fpga";
    begin
        if stop_sim = '0' then
            if dout_v = '1' then
                write_byte(fout,dout);
            end if;
        else
            file_close(fout);
            assert false report "End of file" severity failure;
        end if;
        wait until clk = '1';
    end process;




end architecture test;
