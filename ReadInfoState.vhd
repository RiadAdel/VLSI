library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ReadInfoState is
  port (
    CLK:in std_logic;
    S:in state;
    reset,MFC:in std_logic;
    filterAddressReg_out:in std_logic_vector( 12 downto 0);
    filterRamData:in std_logic_vector( 15 downto 0);
    Read:out std_logic;
    noOfLayersReg_out:out std_logic_vector(15 downto 0);
    filterRamAddress:out std_logic_vector(12 downto 0)
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
signal Enable : std_logic;

begin
Enable <= '1' when (S = RI) else '0';
  noOfLayersReg:nBitRegister
	generic map (16)
  port map (filterRamData,CLK,reset,Enable,noOfLayersReg_out);
  dmaOut:triStateBuffer
	generic map (16)
  port map (filterAddressReg_out,Enable,filterRamAddress);
end archReadInfoState ;