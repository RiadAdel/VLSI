Library ieee;
Use ieee.std_logic_1164.all;
use work.constants.all;
------------------------------------------------------
ENTITY ReadFilter IS
	PORT(	current_state : in state;
		FILTER : IN STD_LOGIC_VECTOR(399 DOWNTO 0);
		FilterAddress : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		msbNoOfFilters,CLK,RST,QImgStat,ACKF : IN std_logic;
		IndicatorFilter : out std_logic_vector(0 downto 0);
		DMAAddress,UpdatedAddress :  out STD_LOGIC_VECTOR(12 DOWNTO 0);
		outFilter0,outFilter1 : out STD_LOGIC_VECTOR(399 DOWNTO 0));
END ReadFilter;

------------------------------------------------
ARCHITECTURE DATA_FLOW OF ReadFilter IS
	signal IndicatorF :  std_logic_vector(0 downto 0);
	SIGNAL triStateBufferEN : std_logic;
	signal tristateAddEn : std_logic;
	SIGNAL filter1EN : std_logic;
	SIGNAL filter2EN : std_logic;
	SIGNAL DFFCLK : std_logic;
	SIGNAL Qbar : std_logic_vector(0 downto 0);
	SIGNAL secOperand: std_logic_vector(12 downto 0);
	signal newAddress:STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal IndRst: std_logic;
		
BEGIN
	IndicatorFilter <=IndicatorF;
	filter1EN <= '1' when ((current_state = conv_ReadImg_ReadFilter) AND (QImgStat = '0') and (ACKF = '1') ) or ((current_state = CONV) AND (IndicatorF = "0") AND (QImgStat = '1') and (ACKF = '1') ) else '0';
	filter2EN <= '1' when ((current_state = conv_ReadImg_ReadFilter) AND (QImgStat = '1')and (ACKF = '1')) or ((current_state = CONV) AND (IndicatorF = "0") AND (QImgStat = '0')and (ACKF = '1')) else '0';

	F0 : entity work.nBitRegister generic map (400) port map(FILTER,CLK,RST,filter1EN,outFilter0);
	F1 : entity work.nBitRegister generic map (400) port map(FILTER,CLK,RST,filter2EN,outFilter1);
	
	DFFCLK <= '1' when (current_state = CONV AND ACKF='1' and (CLK'event and CLK='1')  ) else '0';
	Qbar <= NOT(IndicatorF);
	
	IndRst<= '1' when current_state = SHLEFT  or  RST = '1' else '0';
	DDF0 : entity work.nBitRegister generic map (1) port map(Qbar,DFFCLK,IndRst,'1',IndicatorF);

	
	triStateBufferEN <= '1' when (current_state = conv_ReadImg_ReadFilter) or ((current_state = CONV) AND (IndicatorF = "0")) else '0';

	tsb0 : entity work.triStateBuffer generic map (13) port map(FilterAddress,triStateBufferEN,DMAAddress);
	
	-- needs revision
	secOperand <= "0000000001001" when msbNoOfFilters = '0' else "0000000011001";

	adder0: entity work.my_nadder generic map (13) port map(FilterAddress,secOperand,'0',newAddress);
	
	tristateAddEn <='1' when ((current_state = conv_ReadImg_ReadFilter) or ((current_state = CONV) AND (IndicatorF = "0"))) else '0';

	tsb2 : entity work.triStateBuffer generic map (13)port map(newAddress,tristateAddEn,UpdatedAddress);
	
	
END DATA_FLOW;