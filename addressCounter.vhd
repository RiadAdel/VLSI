LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY addressCounter IS
	
	PORT(	reset:in std_logic;		
		current_state: IN state;
		outputAddress : OUT std_logic_vector(12 downto 0); 
		RealOutputCounter : out std_logic_vector(12 downto 0);
		AddresCounterLoad : in STD_LOGIC_VECTOR(12 DOWNTO 0);
		X , Y , clk  : in std_logic 
	);
END ENTITY addressCounter;

ARCHITECTURE addressCounterArch OF addressCounter IS	

--components
component Counter is
	generic(n: integer := 13);
	port(
		enable:in std_logic;
		reset:in std_logic;
		clk:in std_logic;
		load:in std_logic;
		output:out std_logic_vector(n-1 downto 0);
		input:in std_logic_vector(n-1 downto 0));
end component;

component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END component;

signal outputCounter,input : std_logic_vector(12 downto 0);
signal enable : std_logic;
signal counterLoad : std_logic_vector(12 downto 0);
signal Load : std_logic;
signal CounterClk : std_logic;
BEGIN 
	
	RealOutputCounter<=outputCounter;
	counterLoad<=AddresCounterLoad;
	Load<= '1' when    (current_state =IMGSTAT )  and ((X = '0' and Y='1')  or ( Y ='0'))        else '0';
	myCounter:  Counter  generic map ( 13 ) port map (enable,reset,CounterClk,Load,outputCounter,counterLoad);	
	outOfAddressCounter:  tristatebuffer  generic map ( 13 ) port map (outputCounter,enable,outputAddress);


	--Enable <= '1' when current_state = SAVE  or  ((current_state =IMGSTAT )  and ((X = '0' and Y='1')  or ( Y ='0')) )   else'0'; --enable when depth is not zero
	Enable <= '1' when current_state = SAVE  else'0'; --enable when depth is not zero
	CounterClk<= '1' when current_state = SAVE   else clk  when   current_state = IMGSTAT  else '0';
END addressCounterArch;
