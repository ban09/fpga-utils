library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fir_pkg is

    constant MIN_COEFF : integer := -95;
    constant MAX_COEFF : integer := 5759;

    constant TAPS : integer := 3;
    constant STAGES : integer := 3;

    -- TODO: Can signed be used painlessly?
    type coeff_t is array(natural range <>, natural range <>) of integer; -- range (MIN_COEFF to MAX_COEFF);
    constant coeff : coeff_t(0 to STAGES-1, 0 to TAPS-1) := 
    ( (1286, 4121, -95),
      (0,    5759,   0),
      (-95,  4121,   1286)
  );

    constant MULT_A_WIDTH : natural := 18;
    constant MULT_B_WIDTH : natural := 18;
    constant MULT_OUT_WIDTH : natural := MULT_A_WIDTH+MULT_B_WIDTH;
    constant ACC_WIDTH : natural := 48;

    type acc_t is array (natural range <>) of signed (ACC_WIDTH-1 downto 0);
    type mul_t is array (natural range <>) of signed (MULT_OUT_WIDTH-1 downto 0);

end package fir_pkg;



