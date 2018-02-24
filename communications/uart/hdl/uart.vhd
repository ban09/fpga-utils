-- UART top level
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
    port(
            clk : in std_logic;
            rst_n : in std_logic; 
            tx_pin : out std_logic;
            debug : out std_logic
        );
end entity uart;

architecture rtl of uart is


    signal ch_index : unsigned(2 downto 0);
    signal ch_index_end : std_logic;

    signal m_count : unsigned(26 downto 0);
    signal m_count_end, m_count_en : std_logic;

    type message_t is array (0 to 7) of std_logic_vector(7 downto 0);
    signal message : message_t := (x"48", x"65", x"6c", x"6c", x"6f", x"20", x"0a", x"0a");

    type state_t is (idle, load_byte, transmit);
    signal state : state_t := idle;

    signal uart_ready, uart_load : std_logic;
    signal uart_din : std_logic_vector(7 downto 0);
    signal uart_ce, uart_tick : std_logic;
    signal tx : std_logic;
    signal debug_led : std_logic;
begin

    next_state_logic : process (clk, rst_n) is
    begin
    if rst_n = '0' then
    state <= idle;
    elsif rising_edge(clk) then
        case state is
            when idle =>
                if m_count_end = '1' then
                    state <= load_byte;
                end if;
            when load_byte =>
                state <= transmit;
            when transmit =>
                if ch_index_end = '1' then
                    state <= idle;
                elsif uart_ready = '1' then 
                    state <= load_byte;
                end if;
        end case;
        end if;
    end process next_state_logic;

    output : process (state, uart_tick,ch_index) is
    begin
        m_count_en <= '0';
        uart_ce <= '0';
        uart_load <= '0';
        case state is
            when idle =>
                m_count_en <= '1';
            when load_byte =>
                uart_load <= '1';
            when transmit => 
                uart_ce <= uart_tick;
        end case;
    end process output;
    uart_din <= message(to_integer(ch_index));

    uart_control : process (clk, rst_n) is
    begin
        if rst_n = '0' then
            ch_index <= (others => '0');
        elsif rising_edge(clk) then
            ch_index_end <= '0';
            if to_integer(ch_index) = 7 then
                ch_index <= (others => '0');
                ch_index_end <= '1';
            elsif state = load_byte then  
                ch_index <= ch_index + 1;
            end if;
        end if;
    end process uart_control;

    message_delay : process (clk, rst_n) is
    begin
        if rst_n = '0' then
            m_count <= (others => '0');
        elsif rising_edge(clk) then
            m_count_end <= '0';
            if to_integer(m_count) = 100000000 then
                m_count <= (others => '0');
                m_count_end <= '1';
            elsif m_count_en = '1' then
                m_count <= m_count + 1;
            end if;
        end if;
    end process message_delay;

    uart_transmit_inst : entity work.uart_tx
    port map(
                clk => clk,
                rst_n => rst_n,
                ce => uart_ce,
                load => uart_load,
                ready => uart_ready,
                din => uart_din,
                dout => tx);

    baudrate_generator_inst : entity work.baudrate_gen
    generic map (CLK_FREQ => 100000000, BAUDRATE => 9600)
    port map(
                clk => clk,
                rst_n => rst_n,
                tick => uart_tick);

    process (clk, rst_n) is
    begin
        if rst_n = '0' then
            debug_led <= '0';
            tx_pin <= '1';
        elsif rising_edge(clk) then
            tx_pin <= tx;
            debug_led <= debug_led xor m_count_end;
        end if;
    end process;

    debug <= debug_led;


end architecture rtl;
