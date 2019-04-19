Library ieee;
Use ieee.std_logic_1164.all;
use work.constants.all;
------------------------------------------------------
ENTITY ReadBias IS
	PORT(	current_state : in state;
		BIAS : IN STD_LOGIC_VECTOR(399 DOWNTO 0);
		FilterAddress: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		DMAAddressToFilter,UpdatedAddress: OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		CLK,RST : IN std_logic;
		LayerInfo : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		outBias0,outBias1,outBias2 : out STD_LOGIC_VECTOR(15 DOWNTO 0);
		outBias3,outBias4,outBias5,outBias6,outBias7 : out STD_LOGIC_VECTOR(15 DOWNTO 0);
		ACKF: IN std_logic);
END ReadBias;

------------------------------------------------
ARCHITECTURE DATA_FLOW OF ReadBias IS

signal Zeros : STD_LOGIC_VECTOR(8 DOWNTO 0);
signal NewAddress: STD_LOGIC_VECTOR(12 DOWNTO 0);
signal upAddress: STD_LOGIC_VECTOR(12 DOWNTO 0);
signal BiasEnable : std_logic;
signal triEnable : std_logic;

BEGIN

Zeros <= (others=>'0') ;
NewAddress <= Zeros&LayerInfo( 3 downto 0 );    -- get number of filters from layer info 
BiasEnable <= '1' when (current_state=conv_calc_ReadImg_ReadBias and ACKF = '1' )  else '0';
triEnable <= '1' when (current_state=conv_calc_ReadImg_ReadBias )  else '0';
	B0 : entity work.nBitRegister port map(BIAS(15  DOWNTO   0),CLK,RST,BiasEnable,outBias0);
	B1 : entity work.nBitRegister port map(BIAS(31  DOWNTO  16),CLK,RST,BiasEnable,outBias1);
	B2 : entity work.nBitRegister port map(BIAS(47  DOWNTO  32),CLK,RST,BiasEnable,outBias2);
	B3 : entity work.nBitRegister port map(BIAS(63  DOWNTO  48),CLK,RST,BiasEnable,outBias3);
	B4 : entity work.nBitRegister port map(BIAS(79  DOWNTO  64),CLK,RST,BiasEnable,outBias4);
	B5 : entity work.nBitRegister port map(BIAS(95  DOWNTO  80),CLK,RST,BiasEnable,outBias5);
	B6 : entity work.nBitRegister port map(BIAS(111 DOWNTO  96),CLK,RST,BiasEnable,outBias6);
	B7 : entity work.nBitRegister port map(BIAS(127 DOWNTO 112),CLK,RST,BiasEnable,outBias7);

	tsb0 : entity work.triStateBuffer generic map (13) port map(FilterAddress,triEnable,DMAAddressToFilter);
	
	adder0: entity work.my_nadder generic map (13) port map(FilterAddress,NewAddress,'0',upAddress);

	TriStateAdd : entity work.triStateBuffer generic map (13) port map(upAddress,triEnable,UpdatedAddress);
	

END DATA_FLOW;
