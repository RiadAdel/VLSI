Library ieee;
Use ieee.std_logic_1164.all;
 
------------------------------------------------------
ENTITY ReadFilter IS
	PORT(	STATE : in std_logic;
		FILTER : IN STD_LOGIC_VECTOR(447 DOWNTO 0);
		FilterAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		msbNoOfFilters,CLK,RST,QImgStat,ACK : IN std_logic;
		DMAAddress,UpdatedAddress,outFilter0,outFilter1 : out STD_LOGIC_VECTOR(15 DOWNTO 0));
END ReadFilter;

------------------------------------------------
ARCHITECTURE DATA_FLOW OF ReadFilter IS
	
	SIGNAL triStateBufferEN : std_logic;
	SIGNAL filter1EN : std_logic;
	SIGNAL filter2EN : std_logic;
	SIGNAL DFFCLK : std_logic;
	SIGNAL IndicatorFilter : std_logic_vector(0 downto 0);
	SIGNAL Qbar : std_logic_vector(0 downto 0);
	SIGNAL secOperand: std_logic_vector(15 downto 0);


 -- (here we add the previous full adder) ----
	COMPONENT nBitRegister IS
		generic( n : integer := 16);
		PORT(	D: IN std_logic_vector(n-1 downto 0);	
			CLK,RST,EN : IN std_logic;
			Q : OUT std_logic_vector(n-1 downto 0));
	END COMPONENT;

	COMPONENT triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
	END COMPONENT;

	COMPONENT my_nadder IS
	Generic ( n : integer := 16);
	PORT(a, b : in std_logic_vector(n-1 downto 0);
		cin : in std_logic;
		s : out std_logic_vector(n-1 downto 0);
		cout : out std_logic);
	END COMPONENT;
		
BEGIN
	
	filter1EN <= '1' when ((STATE = '1') AND (QImgStat = '0')) or ((STATE = '0') AND (IndicatorFilter = "0") AND (QImgStat = '1')) else '0';
	filter2EN <= '1' when ((STATE = '1') AND (QImgStat = '1')) or ((STATE = '0') AND (IndicatorFilter = "0") AND (QImgStat = '0')) else '0';

	F0 : nBitRegister generic map (400) port map(FILTER(399 DOWNTO 0),CLK,RST,filter1EN,outFilter0);
	F1 : nBitRegister generic map (400) port map(FILTER(399 DOWNTO 0),CLK,RST,filter2EN,outFilter1);
	
	--DFFCLK <= '1' when (State_conv AND ACK) else '0';
	Qbar <= NOT(IndicatorFilter);
	DDF0 : nBitRegister generic map (1) port map(Qbar,DFFCLK,RST,'1',IndicatorFilter);

	-- state needs to be changed
	triStateBufferEN <= '1' when (STATE = '1') or ((STATE = '0') AND (IndicatorFilter = "0")) else '0';

	tsb0 : triStateBuffer port map(FilterAddress,triStateBufferEN,DMAAddress);
	
	-- needs revision
	secOperand <= "0000000000001001" when msbNoOfFilters = '0' else "0000000000011001";

	adder0: my_nadder port map(FilterAddress,secOperand,'0',UpdatedAddress);

END DATA_FLOW;