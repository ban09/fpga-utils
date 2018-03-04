library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package file_utils is

  type binary_file_t is file of character;

  constant BYTE_LENGTH : integer := 8;

  procedure read_byte (file f  : binary_file_t; data : out std_logic_vector);
  procedure read_word (file f  : binary_file_t; n : in integer; data : out std_logic_vector);
  procedure write_byte (file f : binary_file_t; data : in std_logic_vector);

end package file_utils;

package body file_utils is

  procedure read_byte (file f : binary_file_t; data : out std_logic_vector) is
    variable buff : character;
  begin
    read(f, buff);
    data := std_logic_vector(to_unsigned(character'pos(buff), BYTE_LENGTH));
  end procedure read_byte;

  procedure read_word (file f : binary_file_t; n : in integer; data : out std_logic_vector) is
    variable buff : character;
    variable i    : integer;
    variable byte : std_logic_vector(7 downto 0);
  begin
    for i in n downto 1 loop
      read_byte(f, byte);
      data(BYTE_LENGTH*i-1 downto BYTE_LENGTH*(i-1)) := byte;
    end loop;
  end procedure read_word;

  procedure write_byte (file f : binary_file_t; data : in std_logic_vector) is
  begin
    write(f, character'val(to_integer(unsigned(data))));
  end procedure write_byte;

end package body file_utils;
