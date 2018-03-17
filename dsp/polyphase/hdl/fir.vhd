library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fir_pkg.all;
use work.utils_pkg.all;

entity fir is
    generic(
               DATA_WIDTH : natural := 8
           );
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            din : in std_logic_vector(DATA_WIDTH-1 downto 0);
            din_v : in std_logic;
            dout : out std_logic_vector(DATA_WIDTH-1 downto 0);
            dout_v : out std_logic
        );
end entity fir;

architecture impl of fir is

    type mul_in_t is array (natural range <>) of signed(MULT_A_WIDTH-1 downto 0);
    type din_t is array (natural range <>) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal mul : mul_t(STAGES-1 downto 0) := (others => (others => '0'));
    signal acc : acc_t(STAGES-1 downto 0) := (others => (others => '0'));

    signal coeff_idx : integer := 0;
    signal coeff_idx_map : std_logic_vector(clog2(TAPS-1)-1 downto 0);

    signal din_q : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal din_valid : std_logic := '0';

    signal data : din_t(STAGES-2 downto 0) := (others => (others => '0'));
    signal mul_data_in : mul_in_t(STAGES-1 downto 0) := (others => (others => '0'));

    signal out_acc : signed(ACC_WIDTH-1 downto 0) := (others => '0');
    signal acc_rst, acc_rst_q : std_logic := '0';

    attribute use_dsp : string;
    attribute use_dsp of mul : signal is "yes";
    attribute use_dsp of acc : signal is "yes";
    attribute use_dsp of out_acc : signal is "yes";

begin

    coeff_idx <= to_integer(unsigned(coeff_idx_map));
    coeff_rotation_counter : entity work.modulo_counter 
    generic map  (
                     THRESHOLD => TAPS-1 
                 )
    port map (
                 clk => clk , 
                 rst_n =>rst_n,
                 ce => din_valid,
                 thr => open,
                 Q => coeff_idx_map
             );

    din_flop : process(clk) is
    begin
        if rising_edge(clk) then
            din_q <= din;
        end if;
    end process din_flop;

    din_v_flop : process(clk) is
    begin
        if rising_edge(clk) then
            din_valid <= din_v;
        end if;
    end process din_v_flop;

    delay_fifo : for i in 0 to STAGES-2 generate

        first_stage : if i = 0 generate
            fifo : entity work.shift_reg
            generic map(
                           DEPTH => STAGES+1,
                           WIDTH => DATA_WIDTH)
            port map(
                        clk => clk,
                        ce => din_valid,
                        din => din_q,
                        dout => data(i));
        end generate first_stage;

        remaining_stages : if i > 0 generate

            fifo : entity work.shift_reg
            generic map(
                           DEPTH => STAGES+1,
                           WIDTH => DATA_WIDTH)
            port map(
                        clk => clk,
                        ce => din_valid,
                        din => data(i-1),
                        dout => data(i));

        end generate remaining_stages;

    end generate delay_fifo;


    filter_stages : for i in 0 to STAGES-1 generate

        first_stage : if i = 0 generate
            process (clk) is
            begin
                if rising_edge(clk) then
                    if din_valid = '1' then
                        mul_data_in(i) <= resize(signed(din_q),MULT_A_WIDTH);
                        mul(i) <= mul_data_in(i) * to_signed(coeff(i,coeff_idx),MULT_B_WIDTH);
                        acc(i) <= resize(mul(i),ACC_WIDTH);
                    end if;
                end if;
            end process;         
        end generate first_stage;

        remaining_stages : if i > 0 generate
            process (clk) is
            begin
                if rising_edge(clk) then
                    if din_valid = '1' then
                        mul_data_in(i) <= resize(signed(data(i-1)),MULT_A_WIDTH);
                        mul(i) <= mul_data_in(i) * to_signed(coeff(i,coeff_idx),MULT_B_WIDTH);
                        acc(i) <= acc(i-1) + resize(mul(i),ACC_WIDTH);
                    end if;
                end if;
            end process;         
        end generate remaining_stages;

    end generate filter_stages;

    acc_rst <= '1' when coeff_idx = 1 else '0';

    process (clk) is
    begin
        if rising_edge(clk) then
            acc_rst_q <= acc_rst;
        end if;
    end process;

    dout_v <= acc_rst and (not acc_rst_q);  

    output_accumulator : process (clk) is
    begin
        if rising_edge(clk) then
            if din_valid = '1' then
                if acc_rst = '1' then
                    out_acc <= acc(STAGES-1);
                else
                    out_acc <= out_acc + acc(STAGES-1);
                end if;
            end if;
        end if;
    end process output_accumulator;

    dout <= std_logic_vector(out_acc(21 downto 14));

end architecture impl;



