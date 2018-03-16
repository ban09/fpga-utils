library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg is
    generic(
               DEPTH : integer := 10;
               WIDTH : integer := 2
);
port(
        clk : in std_logic;
        ce : in std_logic;
        din : in std_logic_vector(WIDTH-1 downto 0);
        dout : out std_logic_vector(WIDTH-1 downto 0)
    );

end entity shift_reg;

architecture rtl of shift_reg is

    type data_t is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);
    signal data : data_t(DEPTH-1 downto 0) := (others => (others => '0')); 

begin

    shift : for i in 0 to DEPTH-1 generate

        first_stage : if i = 0 generate

            process (clk) is
            begin
                if rising_edge(clk) then
                    if ce = '1' then
                        data(i) <= din;
                    end if;
                 end if;
            end process;

            end generate first_stage;

            remaining : if i > 0 generate

                process (clk) is
                begin
                    if rising_edge(clk) then
                        if ce = '1' then
                            data(i) <= data(i-1);
                        end if;
                    end if;
                end process;

            end generate remaining;

        end generate shift;

        dout <= data(DEPTH-1);

end architecture rtl;
