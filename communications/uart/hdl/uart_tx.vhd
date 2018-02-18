-- Simple uart tx module with 8 bits data, no parity and 1 stop bit.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            ce : in std_logic;
            load : in std_logic;
            ready : out std_logic;
            din : in std_logic_vector(7 downto 0);
            dout : out std_logic);
end entity uart_tx;

architecture rtl of uart_tx is
    signal tx_counter : unsigned(3 downto 0) := (others => '0');
    constant TX_THR : unsigned(3 downto 0) := to_unsigned(9,tx_counter'length);
    signal tx_done : std_logic := '0';
begin

    shiftreg : entity work.parallel2serial
    generic map(
                   INPUT_WIDTH => 10)
    port map(
                clk => clk,
                rst_n => rst_n,
                ce => ce,
                load => load,
                din => ('1' & din & '0'), -- Append start and stop bits.
                dout => dout);

    tx_count : process(clk, rst_n) is
    begin
        if rst_n = '0' then
            tx_counter <= (others => '0');
            tx_done <= '0';
        elsif rising_edge(clk) then
            tx_done <= '0';
            if load = '1' then
                tx_counter <= (others => '0');
            elsif ce = '1' then
                if tx_counter < TX_THR then
                    tx_counter <= tx_counter + 1;
                else
                    tx_done <= '1';
                end if;
            end if;
        end if;
    end process tx_count;

    ready_gen : process(clk, rst_n) is
    begin
        if rst_n = '0' then
            ready <= '1';
        elsif rising_edge(clk) then
            if load = '1' then
                ready <= '0';
            end if;
            if tx_done = '1' then
                ready <= '1';
            end if;
        end if;
    end process ready_gen;

end architecture rtl;
