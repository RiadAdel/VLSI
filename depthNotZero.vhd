LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY depthNotZero IS
	
	PORT(	fromOutDMA,fromOutReg : IN std_logic_vector(15 downto 0);
		
		Depth: IN std_logic_vector(2 downto 0); --selector of the mux (filter counter)
		state:IN std_logic;
		
		output : OUT std_logic_vector(15 downto 0)); --no carry 
END ENTITY depthNotZero;

ARCHITECTURE DepthNotZeroArch OF depthNotZero IS	

--components
Component my_nadder IS

Generic ( n : integer := 16);
PORT(a, b : in std_logic_vector(n-1 downto 0);
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END Component;


component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END component;

Signal outputMux,outputAdder :std_logic_vector(15 downto 0);
Signal cout,Enable:std_logic;
BEGIN 
	
	myNadder:  my_nadder  generic map ( 16 ) port map (fromOutReg,fromOutDMA,'0',outputAdder,cout);	
	depth0:  tristatebuffer  generic map ( 16 ) port map (outputAdder,enable,output);


	Enable <= '1' when state = '1' and depth /= "000" else'0'; --enable when depth is not zero
END DepthNotZeroArch;
