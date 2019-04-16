LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY ReadLayerInfo IS
	PORT(	LayerInfoIn ,ImgWidthIn : IN std_logic_vector(15 downto 0);
		FilterAdd , ImgAdd : IN std_logic_vector(12 downto 0); 
		clk , rst , ACKF , ACKI: IN std_logic;
		current_state: IN state ;
		LayerInfoOut ,ImgWidthOut: OUT std_logic_vector(15 downto 0);
		FilterAddToDMA,ImgAddToDMA: OUT std_logic_vector(12 downto 0)	);
END ENTITY ReadLayerInfo;


ARCHITECTURE LayerInfo OF ReadLayerInfo IS	

signal LayerInfEN :  std_logic;
signal ImgWidthEN :  std_logic;
signal FilterAddTriEN :  std_logic;
signal ImgAddTriEN :  std_logic;

BEGIN 

LayerInfEN <='1' when (current_state = RL and ACKF = '1' ) else '0';
ImgWidthEN <='1' when (current_state = RL and ACKI = '1' )else '0';
FilterAddTriEN<='1' when (current_state = RL  ) else '0';
ImgAddTriEN<='1' when (current_state = RL ) else '0';

LayerInf:entity work.nBitRegister generic map (n=>16) port map ( LayerInfoIn , clk , rst ,LayerInfEN , LayerInfoOut );
ImgWidth:entity work.nBitRegister generic map (n=>16) port map ( ImgWidthIn , clk , rst ,ImgWidthEN , ImgWidthOut );

FilterAddTriDMA:entity work.triStateBuffer generic map (n=>13) port map ( FilterAdd , FilterAddTriEN,FilterAddToDMA );
ImgAddTriDMA:entity work.triStateBuffer generic map (n=>13) port map ( ImgAdd , ImgAddTriEN,ImgAddToDMA );




END LayerInfo;
