library ieee;
use ieee.std_logic_1164.all;

entity parallel2serial is
    generic(
               INPUT_WIDTH : natural := 8);

    port(
            clk : in std_logic;
            rst_n : in std_logic;
            ce : in std_logic;
            load : in std_logic;
            din : in std_logic_vector(INPUT_WIDTH-1 downto 0);
            dout : out std_logic);
end entity parallel2serial;

architecture rtl of parallel2serial is
    signal data : std_logic_vector(INPUT_WIDTH-1 downto 0);
begin
    shift : process (clk,rst_n) is
    begin
        if rst_n = '0' then
            data <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                data <= din;
            elsif ce = '1' then
                data <= '0' & data(INPUT_WIDTH-1 downto 1);
            end if;
        end if;
    end process shift;
    dout <= data(0);
end architecture rtl;


