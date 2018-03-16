library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package utils_pkg is
    function clog2(x : integer) return integer;
end package utils_pkg;

package body utils_pkg is
    function clog2(x : integer) return integer is
    begin
        return integer(ceil(log2(real(x))));
    end clog2;
end package body utils_pkg;
