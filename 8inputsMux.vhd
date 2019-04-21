library IEEE;
use IEEE.std_logic_1164.all;

entity mux7 is --7 inputs mux
port(
  a1      : in  std_logic_vector(15 downto 0);
  a2      : in  std_logic_vector(15 downto 0);
  a3      : in  std_logic_vector(15 downto 0);
  a4      : in  std_logic_vector(15 downto 0);
  a5      : in  std_logic_vector(15 downto 0);
  a6      : in  std_logic_vector(15 downto 0);
  a7      : in  std_logic_vector(15 downto 0);
  a8      : in  std_logic_vector(15 downto 0);

  sel     : in  std_logic_vector(2 downto 0);
  output       : out std_logic_vector(15 downto 0));
end mux7;

architecture mux7Arch of mux7 is
  -- declarative part: empty
begin

output  <= a1 when sel = "000" 
      else a2 when sel = "001"
      else a3 when sel = "010"
      else a4 when sel = "011"
      else a5 when sel = "100"
      else a6 when sel = "101"
      else a7 when sel = "110"
      else a8;


end mux7Arch;
