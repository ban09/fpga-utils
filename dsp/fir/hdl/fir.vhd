library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fir is 
    generic(
               DATA_WIDTH : natural := 8;
               DECIMATION_FACTOR : natural := 10
           );
    port(
            clk : in std_logic;
    --TODO: Check dsp48 rst level.
            rst_n : in std_logic;
            din : in std_logic_vector(DATA_WIDTH-1 downto 0);
            din_valid : in std_logic;
            dout : out std_logic_vector(DATA_WIDTH-1 downto 0);
            dout_valid : out std_logic
        );
end entity fir;

-- TODO: think about a better architectural name, maybe split them by resources used.
architecture rtl of fir is
    -- TODO Move clog2 to a package
    function clog2(x : integer) return integer is
    begin
        return integer(ceil(log2(real(x))));
    end clog2;

    -- TODO: keep filter coeffs in a separate package that can be generated from python/octave.
    constant NCOEFFS : natural := 30;
    constant COEFFS_WIDTH : natural := 14;

    -- TODO: Exploit coefficient simmetry.
    type coeffs_t is array (natural range <>) of integer range -37 to 1672;
    signal coeffs : coeffs_t(NCOEFFS-1 downto 0) := (-29 ,-32 ,-37 ,-36 ,-19 ,28 ,119 ,260 ,451 ,683 ,938 ,1192 ,1416 ,1583 ,1672 ,1672 ,1583 ,1416 ,1192 ,938 ,683 ,451 ,260 ,119 ,28 , -19 ,-36 ,-37 ,-32 ,-29);

    constant MULT_A_WIDTH : natural := 25;
    constant MULT_B_WIDTH : natural := 18;
    constant MULT_OUT_WIDTH : natural := MULT_A_WIDTH+MULT_B_WIDTH;
    constant ACC_WIDTH : natural := 48;

    type acc_t is array (natural range <>) of signed(ACC_WIDTH-1 downto 0);
    signal acc : acc_t(NCOEFFS-1 downto 0) := (others => (others => '0'));

    signal count : unsigned(clog2(DECIMATION_FACTOR)-1 downto 0);
    signal din_r : signed (DATA_WIDTH-1 downto 0);
    signal din_valid_r : std_logic;
    signal dout_valid_d : std_logic;

    attribute use_dsp48 : string;
    attribute use_dsp48 of acc : signal is "yes";
    attribute use_dsp48 of coeffs : signal is "yes";

begin

    process(clk, rst_n) is
    begin
        if rst_n = '0' then
            din_valid_r <= '0';
        elsif rising_edge(clk) then
            din_valid_r <= din_valid;
        end if;
    end process;

    process(clk, rst_n) is
    begin
        if rst_n = '0' then
            din_r <= (others => '0');
        elsif rising_edge(clk) then
            din_r <= signed(din);
        end if;
    end process;

    filter_gen : for i in 0 to NCOEFFS-1 generate

        first_stage : if (i = 0) generate
            process (clk,rst_n) is
                variable mul : signed(MULT_OUT_WIDTH-1 downto 0);
            begin
                if rst_n = '0' then
                    acc(i) <= (others => '0');
                    mul := (others => '0');
                elsif rising_edge(clk) then
                    if din_valid_r = '1' then
                        mul := resize(din_r,MULT_B_WIDTH)*to_signed(coeffs(i),MULT_A_WIDTH);
                        acc(i) <= resize(mul,ACC_WIDTH);
                    end if;
                end if;
            end process;
        end generate first_stage;

        intermediate_stage : if (i > 0) generate
            process (clk,rst_n) is
                variable mul : signed(MULT_OUT_WIDTH-1 downto 0);
            begin
                if rst_n = '0' then
                    acc(i) <= (others => '0');
                    mul := (others => '0');
                elsif rising_edge(clk) then
                    if din_valid_r = '1' then
                        mul := resize(din_r,MULT_B_WIDTH)*to_signed(coeffs(i),MULT_A_WIDTH);
                        acc(i) <= acc(i-1) + resize(mul,ACC_WIDTH);
                    end if;
                end if;
            end process;
        end generate intermediate_stage;

    end generate filter_gen;

        -- TODO: should dout_valid be asserted 1 cycle or until the next valid sample is read?
    process (clk, rst_n) is
    begin
        if rst_n = '0' then
            count <= (others => '0');
            dout_valid_d <= '0';
        elsif rising_edge(clk) then
            dout_valid_d <= '0';
            if (count = DECIMATION_FACTOR-1) then
                count <= (others => '0');
                dout_valid_d <= '1';
            elsif din_valid_r = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;

   -- NOTE: First NCOEFF/DECIMATION_FACTOR samples are not really valid but
   -- discarding them implies additional logic to tell when the pipeline
   -- is full.
    process(clk, rst_n) is
    begin
        if rst_n = '0' then
            dout_valid <= '0';
        elsif rising_edge(clk) then
            dout_valid <= dout_valid_d;
        end if;
    end process;

    process (clk, rst_n) is
    begin
        if rst_n = '0' then
            dout <= (others => '0');
        elsif rising_edge(clk) then
            dout <= std_logic_vector(acc(NCOEFFS-1)(21 downto 14));
        end if;
    end process;

end architecture rtl;
