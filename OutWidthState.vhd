LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY outWidthState IS
	PORT(currentState : IN state;
	infoReg : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	address : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
	outWidth: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY outWidthState;

ARCHITECTURE archOutWidthState OF outWidthState IS


signal outwidthbefore : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN

	address <= (others=>'0') WHEN currentState = WRITE_IMG_WIDTH
	else (others=>'Z');
	outwidthbefore <= infoReg(4 DOWNTO 0) WHEN currentState = WRITE_IMG_WIDTH
	else (others=>'Z');
	outWidth<="00000000000"&outwidthbefore;

END archOutWidthState;

