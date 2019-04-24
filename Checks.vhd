Library ieee;
Use ieee.std_logic_1164.all;
use work.constants.all;

------------------------------------------------------
ENTITY StateChecks IS
	PORT(	current_state : in state;
		noOfLayers : in std_logic_vector(15 downto 0);
		LayerInfo : in std_logic_vector(15 downto 0);
		CLK,RST : IN std_logic;
		L,D : out std_logic;
		CNDoutput : out std_logic_vector( 3 downto 0);
		CNLoutput: out std_logic_vector(1 downto 0));
END StateChecks;

------------------------------------------------
ARCHITECTURE archCHECKS OF StateChecks IS

	signal DepthClk : std_logic;
	signal SCNDoutput : std_logic_vector( 3 downto 0);
	signal SCNLoutput: std_logic_vector(1 downto 0);
	signal SD : std_logic;
	signal DepthCounterRst : std_logic;
BEGIN
	CNDoutput<=SCNDoutput;
	DepthClk<= '1' when  current_state = CHECKS  else '0';
	DepthCounterRst<= '1' when RST='1' or current_state = WRITE_IMG_WIDTH else '0';
	counterNoDepth0: entity work.Counter generic map(4) port map('1',DepthCounterRst,DepthClk,'0',SCNDoutput,"001");
	SD <=  '0' when (SCNDoutput = LayerInfo( 12 downto 9 ) ) else '1';
	D<=SD;
	CNLoutput<=SCNLoutput;
	counterNoLayer0: entity work.Counter generic map(2) port map('1',RST,SD,'0',SCNLoutput,"01");
	L <=  '0' when (SCNLoutput = noOfLayers( 1 downto 0 ) ) else '1';


END archCHECKS;
