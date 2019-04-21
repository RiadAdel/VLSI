LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY addressCounter IS
	
	PORT(	reset:in std_logic;		
		state: IN state;
		outputAddress : OUT std_logic_vector(12 downto 0)); 
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
BEGIN 
	
	myCounter:  Counter  generic map ( 13 ) port map (enable,reset,enable,'0',outputCounter,input);	
	outOfAddressCounter:  tristatebuffer  generic map ( 13 ) port map (outputCounter,enable,outputAddress);


	Enable <= '1' when state = SAVE else'0'; --enable when depth is not zero
END addressCounterArch;
