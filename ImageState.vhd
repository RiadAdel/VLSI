LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY ImageState IS
	PORT(
		current_state : in state;
		WSquared : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		AddresCounterIN : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		AddresCounterLoad : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		NoOfShiftsCounter: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		LayerInfoIn  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK , RST : IN STD_LOGIC;
		Q: Out STD_LOGIC ; 
		NumOfFilters : out std_logic_vector(3 downto 0 ) ;
		NumOfHeight : out STD_LOGIC_VECTOR(4 DOWNTO 0) ;
		X1 : out std_logic ;
		Y1 : out  std_logic ;
		K1 : out  std_logic );

END ENTITY ImageState;


ARCHITECTURE archImgState OF ImageState IS	

	SIGNAL DffOutput : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL DFFCLK : STD_LOGIC;
	SIGNAL X : STD_LOGIC;
	SIGNAL Y : STD_LOGIC;
	SIGNAL Z : STD_LOGIC_vector(3 downto 0);
	SIGNAL K : STD_LOGIC;
	SIGNAL Qbar : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL YBar : STD_LOGIC ;
	SIGNAL newSliceRegRST : STD_LOGIC;
	SIGNAL cnhRST : STD_LOGIC;
	SIGNAL cnfCLK : STD_LOGIC;
	SIGNAL triStateBuffer0EN : STD_LOGIC;
	SIGNAL triStateBuffer1EN : STD_LOGIC;
	SIGNAL CNHoutput : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL newSliceRegOUT : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL adder0Out : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL adder1Out : STD_LOGIC_VECTOR(12 DOWNTO 0);


 	signal adder0b : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal adder1b : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal FilterCounterRst : std_logic;
	signal QRST : std_logic;

	
BEGIN


	X1<=X;
	Y1<=Y;
	K1<=K;
	NumOfFilters<=Z;
	NumOfHeight<=CNHoutput;

	X<= '0' when (LayerInfoIn(8 downto 4) = NoOfShiftsCounter) else '1';
	Y<='0' when (LayerInfoIn(3 downto 0) = Z) else '1';

	YBar <= not Y;
	K<= '0' when LayerInfoIn(8 downto 4) = CNHoutput else '1';


	DFFCLK <= '1' when ( current_state = IMGSTAT and X = '0' ) else '0';
	Qbar <= NOT(DffOutput);
	QRST<='1' when RST='1' or current_state= WRITE_IMG_WIDTH     else '0';
	DDF0 :entity work.nBitRegister generic map (1) port map(Qbar,DFFCLK,QRST,'1',DffOutput);
	Q <= DffOutput(0);

	cnhRST <= '1' when ((RST = '1') OR ((current_state = CHECKS) AND (K = '0'))) else '0';
	counterNoHeight0: entity work.Counter generic map(5) port map('1',cnhRST,YBar,'0',CNHoutput,"00001");

	cnfCLK <= '1' WHEN (( x = '0') AND (current_state = IMGSTAT)) else '0';
	FilterCounterRst<= '1' when (RST= '1') or ( (Y='0') and (current_state = SHUP)) else '0';
	counterNoFilters0: entity work.Counter generic map(4) port map('1',FilterCounterRst,cnfCLK,'0',Z,"0001");

	newSliceRegRST <= '1' WHEN ((current_state = CHECKS) OR (RST = '1')) else '0';
	newSliceReg0: entity work.nBitRegister generic map(13) port map(adder0Out,CLK,newSliceRegRST,YBar,newSliceRegOUT);



	adder0b<="00000000"&LayerInfoIn(8 downto 4);
	adder0: entity work.my_nadder generic map(13) port map(newSliceRegOUT,adder0b,'0',adder0Out);
	triStateBuffer0EN <= '1' WHEN ((Ybar = '1') AND (current_state = IMGSTAT)) else '0';
	triStateBuffer0: entity work.triStateBuffer generic map(13) port map(adder0Out,triStateBuffer0EN,AddresCounterLoad);

	adder1b<="000"&WSquared;
	adder1: entity work.my_nadder generic map(13) port map(AddresCounterIN,adder1b,'0',adder1Out);
	triStateBuffer1EN <= '1' WHEN ((X = '0') AND (Y = '1') AND (current_state = IMGSTAT)) else '0';
	triStateBuffer1: entity work.triStateBuffer generic map(13) port map(adder1Out,triStateBuffer1EN,AddresCounterLoad);

END archImgState;