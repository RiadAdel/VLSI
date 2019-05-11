library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity RAM is
generic(X: integer := 28);
  port (
    reset:in std_logic;
    CLK,W,R:in std_logic;
    address:in std_logic_vector(12 downto 0);
    dataIn:in std_logic_vector( 15 downto 0);
    dataOut:out std_logic_vector(((X*16)-1) downto 0);
    MFC:out std_logic;
    counterOut:out std_logic_vector(3 downto 0)
  ) ;
end RAM;
architecture archRAM of RAM is
    type ram_type is array( 0 to 5000) of std_logic_vector(15 downto 0);
    signal ram: ram_type;
    signal mfc_m:std_logic;

begin
	counterOut <= "0001" when clk = '1' and reset = '1' and w = '1' and address = "0000001111110"
	else "0110" when clk = '0' and r = '1'
	else dataIn(3 downto 0);
	MFC <= '1' when reset = '1' and r = '1' and w = '0'
	else '0';
	dataOut <= (others => '0') when r = '1' and clk ='1'
	else (others => '1') when r = '0' and dataIn = "0001001010111111";
end archRAM ;
