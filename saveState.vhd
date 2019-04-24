LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY saveState IS
	
	PORT(	DMAOutput,RegisterOutput : IN std_logic_vector(15 downto 0);
		bias1,bias2,bias3,bias4,bias5,bias6,bias7,bias8: In std_logic_vector(15 downto 0);
		Depth,NumberOfFiltersCounter: IN std_logic_vector(2 downto 0); --selector of the mux 
		resetCounter: IN std_logic;
		stateinput: IN state;
		clk : in std_logic;
		outputCounterToDma: out std_logic_vector(12 downto 0);
		RealOutputCounter:  out std_logic_vector(12 downto 0);
		output : OUT std_logic_vector(15 downto 0);
		ShiftLeftCounterOutput: out std_logic_vector(4 downto 0) ;
		ShiftCounterRst: In std_logic ); --no carry 
END ENTITY saveState;

ARCHITECTURE saveStateArch OF saveState IS	

--components
component depthZero IS
	
	PORT(	fromOutReg : IN std_logic_vector(15 downto 0);
		bias1,bias2,bias3,bias4,bias5,bias6,bias7,bias8: In std_logic_vector(15 downto 0);
		counterNumber,Depth: IN std_logic_vector(2 downto 0); --selector of the mux (filter counter)
		current_state: IN state;
		
		output : OUT std_logic_vector(15 downto 0)); --no carry 
END component;
-------
component depthNotZero IS
	
	PORT(	fromOutDMA,fromOutReg : IN std_logic_vector(15 downto 0);
		
		Depth: IN std_logic_vector(2 downto 0); --selector of the mux (filter counter)
		
		current_state: IN state;
		output : OUT std_logic_vector(15 downto 0)); --no carry 
END component;
-------
component addressCounter IS
	
	PORT(	reset:in std_logic;		
		current_state: IN state;
		outputAddress : OUT std_logic_vector(12 downto 0);
		RealOutputCounter:  out std_logic_vector(12 downto 0)); 
END component;


--end components

Signal outputMux,outputAdder :std_logic_vector(15 downto 0);
Signal cout,Enable , ShiftRegClk:std_logic;
BEGIN 
	
	Scounter: entity work.Counter  generic map ( 5 ) port map (enable,ShiftCounterRst,ShiftRegClk,'0',ShiftLeftCounterOutput , "00000");	
	first:addressCounter port map (resetCounter,stateinput,outputCounterToDma , RealOutputCounter );	
	second:depthNotZero  port map (DMAOutput,RegisterOutput,depth,stateinput,output);
	third: depthZero    port map (RegisterOutput,bias1,bias2,bias3,bias4,bias5,bias6,bias7,bias8,NumberOfFiltersCounter,depth,stateinput,output);
	
	Enable <= '1' when stateinput = SAVE or stateinput= SHLEFT else'0';
	ShiftRegClk <= '1' when  stateinput = SAVE 
			else clk when stateinput = SHLEFT
			else '0';
END saveStateArch;
