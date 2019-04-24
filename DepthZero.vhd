LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY depthZero IS
	
	PORT(	fromOutReg : IN std_logic_vector(15 downto 0);
		bias1,bias2,bias3,bias4,bias5,bias6,bias7,bias8: In std_logic_vector(15 downto 0);
		counterNumber,Depth: IN std_logic_vector(2 downto 0); --selector of the mux (filter counter)
		current_state: IN state;
		
		output : OUT std_logic_vector(15 downto 0)); --no carry 
END ENTITY depthZero;

ARCHITECTURE DepthZeroArch OF depthZero IS	

--components
Component my_nadder IS

Generic ( n : integer := 16);
PORT(a, b : in std_logic_vector(n-1 downto 0);
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END Component;

Component mux7 is --8 inputs mux
port(
  a1      : in  std_logic_vector(15 downto 0);
  a2      : in  std_logic_vector(15 downto 0);
  a3      : in  std_logic_vector(15 downto 0);
  a4      : in  std_logic_vector(15 downto 0);
  a5      : in  std_logic_vector(15 downto 0);
  a6      : in  std_logic_vector(15 downto 0);
  a7      : in  std_logic_vector(15 downto 0);
  a8      : in  std_logic_vector(15 downto 0);

  sel     : in  std_logic_vector(2 downto 0);
  output  : out std_logic_vector(15 downto 0));
end Component;

component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END component;

Signal outputMux,outputAdder :std_logic_vector(15 downto 0);
Signal cout,Enable:std_logic;
BEGIN 
	myMux:  mux7 port map (bias1,bias2,bias3,bias4,bias5,bias6,bias7,bias8,counterNumber,outputMux);
	myNadder:  my_nadder  generic map ( 16 ) port map (fromOutReg,outputMux,'0',outputAdder,cout);	
	depth0:  tristatebuffer  generic map ( 16 ) port map (outputAdder,enable,output);


	Enable <= '1' when current_state = SAVE  and depth = "000" else'0';
END DepthZeroArch;
