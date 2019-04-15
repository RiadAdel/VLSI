LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;


ENTITY CNN IS
	PORT(	rst , clk:std_logic;
		LayerInfoOut : OUT std_logic_vector(15 downto 0));
END ENTITY CNN;

ARCHITECTURE vlsi OF CNN IS	

-- state decleration-------  
signal next_state:state;
signal current_state:state;

-----Filter address signals--------
signal FilterAddressEN:std_logic;
signal FilterAddressIN: std_logic_vector(12 downto 0);
signal FilterAddressOut: std_logic_vector(12 downto 0);
-------ImgAddReg signals--------
signal ImgAddRegEN:std_logic;
signal ImgAddRegIN: std_logic_vector(12 downto 0);
signal ImgAddRegOut: std_logic_vector(12 downto 0);
-------tristate counter signals--------

signal TriStateCounterEN:std_logic;
signal TriStateCounterOUT: std_logic_vector(12 downto 0);
-------ImgAddACKTri signals-----------
signal ImgAddACKTriEN:std_logic;
signal ImgAddACKTriOUT: std_logic_vector(12 downto 0);
signal zero: std_logic_vector(11 downto 0);
signal ImgAddACKTriIN: std_logic_vector(12 downto 0);
-------Filter memory ------
signal WriteF:std_logic;
signal ReadF:std_logic;
signal AddressF: std_logic_vector(12 downto 0);
signal DataF: std_logic_vector( 400 downto 0 );

signal ACKF:std_logic;
-------Img memory -------
signal WriteI:std_logic;
signal ReadI:std_logic;
signal AddressI:std_logic_vector(12 downto 0);
signal DataI: std_logic_vector( 447 downto 0 );


signal ACKI:std_logic;

------#of layers---------
signal NoOfLayers:std_logic_vector(15 downto 0);
------------------------


BEGIN
---conditions---
FilterAddressEN <= '1' when ((current_state = RI and ACKF = '1' ) or (current_state = RL and ACKF = '1' ));
TriStateCounterEN <= '1' when (current_state = RI and ACKF = '1' ) else '0';
ImgAddRegEN <= '1' when (current_state = RL and ACKI = '1' ) else '0';
ImgAddACKTriEN<='1' when (current_state = RL ) else '0';
zero <= (others=>'0');
ImgAddACKTriIN <= zero&ACKI;
-----------------


--register decliration---


FilterMem:entity work.RAM generic map (X=>25) port map (clk,  WriteF  ,ReadF,AddressF , DataF , ACKF);
ImgMem:entity work.RAM generic map (X=>28) port map (clk,WriteI , ReadI ,AddressI , DataI  ,ACKI );

ReadInf:entity work.ReadInfoState  port map (clk,current_state , rst , ACKF , FilterAddressOut , DataF(15 downto 0) ,ReadF, NoOfLayers , AddressF );


FilterAddress:entity work.nBitRegister generic map (n=>13) port map ( FilterAddressIN , clk , rst ,FilterAddressEN , FilterAddressOut );
CounterTryState:entity work.triStateBuffer generic map (n=>13) port map ( TriStateCounterOUT , TriStateCounterEN,FilterAddressIN );
FilterAddressCounter:entity work.my_nadder generic map (n=>13) port map ( FilterAddressOut ,(others=>'0') ,'1', TriStateCounterOUT);

ImgAddReg:entity work.nBitRegister generic map (n=>13) port map ( ImgAddRegIN , clk , rst ,ImgAddRegEN , ImgAddRegOut );
ImgAddACKTri:entity work.triStateBuffer generic map (n=>13) port map ( ImgAddACKTriIN, ImgAddACKTriEN, ImgAddRegIN );


--------------------------


-- get the next state circuit--
state_decode_proc: process(current_state)
BEGIN

	case current_state is 
		when RI =>
			if ACKF = '1' then 
			next_state<= RL;
			end if ;
		when RL=>

		when Pool_Cal_ReadImg=>
		
		when Pool_Read_Img=>
		when conv_calc_ReadImg_ReadBias=>
		when conv_ReadImg_ReadFilter=>
		when conv_ReadImg=>
		when CONV=>
	
			
	
	end case;
end process ;
	
--end of circuit---

-- update state circuit --
state_proc: process(clk , rst)
begin
	if rst = '1' then
		current_state<=RI;
	elsif clk'event and clk='1' then
		current_state<=next_state;
	end if ;
end process;
-- end of circuit--

--output of process circuit--
output_proc : process(current_state)
begin
	case current_state is
		when RI=>
			ReadF<='1';
		when RL=>

		when Pool_Cal_ReadImg=>
		when Pool_Read_Img=>
		when conv_calc_ReadImg_ReadBias=>
		when conv_ReadImg_ReadFilter=>
		when conv_ReadImg=>
		when  CONV=>
	end case;
end process;


END vlsi;