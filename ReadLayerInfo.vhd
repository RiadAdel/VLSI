LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY ReadLayerInfo IS
	PORT(	LayerInfoIn ,ImgWidthIn : IN std_logic_vector(15 downto 0);
		FilterAdd , ImgAdd : IN std_logic_vector(12 downto 0); 
		EN ,clk , rst , ACKF , ACKI: IN std_logic;
		current_state: IN state ;
		LayerInfoOut ,ImgWidthOut: OUT std_logic_vector(15 downto 0);
		FilterAddToDMA,ImgAddToDMA: OUT std_logic_vector(12 downto 0)	);
END ENTITY ReadLayerInfo;


ARCHITECTURE LayerInfo OF ReadLayerInfo IS	

signal LayerInfEN :  std_logic;
signal ImgWidthEN :  std_logic;
signal FilterAddTriEN :  std_logic;
signal ImgAddTriEN :  std_logic;



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

BEGIN 

LayerInfEN <='1' when (current_state = RL and ACKF = '1' );
ImgWidthEN <='1' when (current_state = RL and ACKF = '1' );
FilterAddTriEN<='1' when (current_state = RI  );
ImgAddTriEN<='1' when (current_state = RL );

LayerInf:nBitRegister generic map (n=>16) port map ( LayerInfoIn , clk , rst ,LayerInfEN , LayerInfoOut );
ImgWidth:nBitRegister generic map (n=>16) port map ( ImgWidthIn , clk , rst ,ImgWidthEN , ImgWidthOut );

FilterAddTriDMA:triStateBuffer generic map (n=>13) port map ( FilterAdd , FilterAddTriEN,FilterAddToDMA );
ImgAddTriDMA:triStateBuffer generic map (n=>13) port map ( ImgAdd , ImgAddTriEN,ImgAddToDMA );



END LayerInfo;
