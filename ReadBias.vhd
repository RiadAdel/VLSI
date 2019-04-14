Library ieee;
Use ieee.std_logic_1164.all;
 
------------------------------------------------------
ENTITY ReadBias IS
	PORT(	STATE : in std_logic;
		BIAS : IN STD_LOGIC_VECTOR(447 DOWNTO 0);
		FilterAddress,NOofFilters : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK,RST : IN std_logic;
		DMAAddress,UpdatedAddress,outBias0,outBias1,outBias2 : out STD_LOGIC_VECTOR(15 DOWNTO 0);
		outBias3,outBias4,outBias5,outBias6,outBias7 : out STD_LOGIC_VECTOR(15 DOWNTO 0));
END ReadBias;

------------------------------------------------
ARCHITECTURE DATA_FLOW OF ReadBias IS
 
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

	B0 : nBitRegister port map(BIAS(15  DOWNTO  0), CLK,RST,STATE,outBias0);
	B1 : nBitRegister port map(BIAS(31  DOWNTO  16),CLK,RST,STATE,outBias1);
	B2 : nBitRegister port map(BIAS(47  DOWNTO  32),CLK,RST,STATE,outBias2);
	B3 : nBitRegister port map(BIAS(63  DOWNTO  48),CLK,RST,STATE,outBias3);
	B4 : nBitRegister port map(BIAS(79  DOWNTO  64),CLK,RST,STATE,outBias4);
	B5 : nBitRegister port map(BIAS(95  DOWNTO  80),CLK,RST,STATE,outBias5);
	B6 : nBitRegister port map(BIAS(111 DOWNTO  96),CLK,RST,STATE,outBias6);
	B7 : nBitRegister port map(BIAS(127 DOWNTO 112),CLK,RST,STATE,outBias7);

	tsb0 : triStateBuffer port map(FilterAddress,STATE,DMAAddress);
	
	adder0: my_nadder port map(FilterAddress,NOofFilters,'0',UpdatedAddress);

END DATA_FLOW;
