LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY ImageState IS
	PORT(
		STATE : in state;
		WSquared : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		AddresCounterIN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		AddresCounterLoad : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		NoOfShiftsCounter: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		LayerInfoIn  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK , RST : IN STD_LOGIC;
		Q: Out STD_LOGIC);

END ENTITY ImageState;


ARCHITECTURE archImgState OF ImageState IS	

	SIGNAL DffOutput : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL DFFCLK : STD_LOGIC;
	SIGNAL X : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL Y : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL Z : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL K : STD_LOGIC;
	SIGNAL Qbar : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL YBar : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL newSliceRegRST : STD_LOGIC;
	SIGNAL cnhRST : STD_LOGIC;
	SIGNAL cnfCLK : STD_LOGIC;
	SIGNAL triStateBuffer0EN : STD_LOGIC;
	SIGNAL triStateBuffer1EN : STD_LOGIC;
	SIGNAL CNHoutput : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL newSliceRegOUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL adder0Out : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL adder1Out : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
BEGIN

	X <= (LayerInfoIn XOR NoOfShiftsCounter);	--if X = 0 --> Finished width --> shift left
	Y <= (LayerInfoIn(3 DOWNTO 0) XOR Z);	--if Y = 0 --> Finished all filters
	YBar <= not Y;
	K <= '1' WHEN ((LayerInfoIn(3 DOWNTO 0) XOR CNHoutput) = "1111") else '0';


	DFFCLK <= '1' when ((STATE = ImgState) AND (X = '0')) else '0';
	Qbar <= NOT(DffOutput);
	DDF0 :entity work.nBitRegister generic map (1) port map(Qbar,DFFCLK,RST,'1',DffOutput);
	Q <= DffOutput;

	cnhRST <= '1' when ((RST = '1') OR ((State = CHECK) AND (K = '0'))) else '0';
	counterNoHeight0: entity work.Counter generic map(4) port map('1',cnhRST,YBar,'0',CNHoutput,"0001");

	cnfCLK <= '1' WHEN ((NOT x) AND (STATE = ImgState)) else '0';
	counterNoFilters0: entity work.Counter generic map(4) port map('1',RST,cnfCLK,'0',Z,"0001");

	newSliceRegRST <= '1' WHEN ((STATE = CHECK) OR (RST = '1')) else '0';
	newSliceReg0: entity work.nBitRegister port map(adder0Out,CLK,newSliceRegRST,YBar,newSliceRegOUT);

	adder0: entity work.my_nadder generic map(4) port map(newSliceRegOUT,LayerInfoIn(3 DOWNTO 0),'0',adder0Out);
	triStateBuffer0EN <= '1' WHEN ((Ybar = "1") AND (STATE = ImgState)) else '0';
	triStateBuffer0: entity work.triStateBuffer generic map(4) port map(adder0Out,triStateBuffer0EN,AddresCounterLoad);

	adder1: entity work.my_nadder generic map(4) port map(AddresCounterIN,WSquared,'0',adder1Out);
	triStateBuffer1EN <= '1' WHEN ((X = "0") AND (Y = "1") AND (STATE = ImgState)) else '0';
	triStateBuffer1: entity work.triStateBuffer generic map(4) port map(adder1Out,triStateBuffer1EN,AddresCounterLoad);

END archImgState;