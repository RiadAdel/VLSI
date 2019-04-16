Library ieee;
Use ieee.std_logic_1164.all;

------------------------------------------------------
ENTITY Checks IS
	PORT(	STATE : in std_logic;
		noOfLayers : in std_logic_vector(1 downto 0);
		FILTER : IN STD_LOGIC_VECTOR(447 DOWNTO 0);
		FilterAddress : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK,RST,ACK : IN std_logic;
		L,D : out std_logic;
		CNHoutput : out std_logic_vector(3 downto 0);
		DMAAddress,UpdatedAddress,outFilter0,outFilter1 : out STD_LOGIC_VECTOR(15 DOWNTO 0));
END Checks;

------------------------------------------------
ARCHITECTURE archCHECKS OF Checks IS

	SIGNAL CNDoutput : std_logic;
	SIGNAL CNLoutput : std_logic;
	SIGNAL addCounterRST : std_logic;
	SIGNAL CNHRST : std_logic;

	COMPONENT Counter is
	generic(n: integer := 16);
	port(
		enable:in std_logic;
		reset:in std_logic;
		clk:in std_logic;
		load:in std_logic;
		output:out std_logic_vector(n-1 downto 0);
		input:in std_logic_vector(n-1 downto 0));
	END COMPONENT;

BEGIN
	
	--CNHRST <= '1' when ((RST = '1') or ((State = stateCHECK) and (k = '0'))) else '0';
	counterNoHeight0: Counter generic map(4) port map('1',CNHRST,State,'0',CNHoutput,"0001");
	
	counterNoDepth0: Counter generic map(4) port map('1',RST,State,'0',CNDoutput,"0001");
	D <= CNDoutput xor noOfLayers;

	counterNoLayer0: Counter generic map(4) port map('1',RST,D,'0',CNLoutput,"0001");
	L <= CNLoutput xor noOfLayers;

	--addCounterRST <= '1' when ((State = stateCHECK) or (RST = 1)) else '0';
	Address0: Counter generic map(4) port map('1',addCounterRST,CLK,'0',cOutput,"0001");
	newSliceReg0: nBitRegister port map(BIAS(15  DOWNTO   0),CLK,RST,STATE,outBias0);

END archCHECKS;
