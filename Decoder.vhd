LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;


entity Decoder is
	port(
		input : in  std_logic_vector(2 downto 0);
		output : out std_logic_vector(5 downto 0)
		);
end Decoder;

ARCHITECTURE dec OF Decoder IS	
BEGIN

decodeProcess: process(input)
begin
	if input="000" then
		output<="000001";
	elsif input="001" then
		output<="000010";
	elsif input="010" then
		output<="000100";
	elsif input="011" then
		output<="001000";
	elsif input="100" then
		output<="010010";
	elsif input="101" then
		output<="100010";
	end if ;
end process;


end dec ;