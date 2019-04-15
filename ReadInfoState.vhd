library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ReadInfoState is
  port (
    CLK,state,reset,MFC:in std_logic;
    filterAddressReg_out,filterRamData:in std_logic_vector( 15 downto 0);
    Read:out std_logic;
    noOfLayersReg_out:out std_logic_vector(15 downto 0);
    filterRamAddress:out std_logic_vector(15 downto 0)
  ) ;
end ReadInfoState;
architecture archReadInfoState of ReadInfoState is
component nBitRegister IS
generic( n : integer := 16);
PORT(	D: IN std_logic_vector(n-1 downto 0);	
  CLK,RST,EN : IN std_logic;
  Q : OUT std_logic_vector(n-1 downto 0));
END component;

component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END component;

signal addressPlusOne: std_logic_vector(15 downto 0);
signal writeFilterAddressReg: std_logic;
begin
  noOfLayersReg:nBitRegister
	generic map (16)
  port map (filterRamData,CLK,reset,state,noOfLayersReg_out);
  dmaOut:triStateBuffer
	generic map (16)
  port map (filterAddressReg_out,state,filterRamAddress);
end archReadInfoState ;