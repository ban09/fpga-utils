library ieee;
use ieee.std_logic_1164.all;

entity parallel2serial_tb is
    end entity parallel2serial_tb;

architecture test of parallel2serial_tb is

    -- DUT signals and parameters.
    constant INPUT_WIDTH : natural := 10;

    signal clk : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal ce : std_logic := '0';
    signal load : std_logic := '0';
    signal din : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal dout : std_logic;

    -- Test signals.
    constant CLK_HALF_PERIOD : time := 5 ns;
    signal start_sim, stop_sim : std_logic := '0';
    signal dummy_signal : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal data_valid : std_logic := '0';
    signal buff : std_logic_vector(INPUT_WIDTH-1 downto 0) := (others => 'U');
    -- Test vector.
    type test_vector_t is array (0 to 3) of std_logic_vector(INPUT_WIDTH-1 downto 0);
    signal test_vector : test_vector_t := ("1111100000", "1101010100", "1111111110", "1000000000");

begin
    DUT : entity work.parallel2serial  
    generic map(INPUT_WIDTH => INPUT_WIDTH)
    port map(clk => clk, 
             rst_n => rst_n, 
             ce => ce, 
             load => load,
             din => din, 
             dout => dout);

    -- Clock gen.
    clk <= not clk after CLK_HALF_PERIOD;

    -- Reset gen.
    reset_gen : process is
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
    end process reset_gen;

    -- Producer.
    producer : process is
        variable i,j : integer := 0;
    begin
        if start_sim = '1' and stop_sim = '0' then
            din <= test_vector(i);
            load <= '1';
            wait until clk = '1';
            load <= '0';
            data_valid <= '1';
            -- Generate load signal 1 clock cycle before the end.
            while (j < INPUT_WIDTH-1) loop
                ce <= '1';
                j := j + 1;
                wait until clk = '1';
            end loop;
            j := 0;
            if i < 3 then
                i := i + 1;
            else
                i := 0;
                data_valid <= '0';
                stop_sim <= '1';
            end if;
        else
            wait until clk = '1';
        end if;
    end process producer;

    -- Consumer
    consumer : process is
        variable i : integer := 0;
    begin
        if start_sim = '1' and stop_sim = '0' then
            while (i < INPUT_WIDTH) loop
                if data_valid = '1' then
                    buff <= dout & buff(INPUT_WIDTH-1 downto 1);
                    i := i+1;
                    wait until clk = '1';
                else
                    wait until clk = '1';
                end if;
            end loop;
            i := 0;
            dummy_signal <= buff;
        else
            wait until clk = '1';
        end if;
    end process;


    process is
    begin
        if stop_sim = '1' then
            assert false report "End of simulation" severity failure;
        else
            wait until clk = '1';
        end if;
    end process;
end architecture test;
