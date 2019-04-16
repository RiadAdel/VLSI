LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;


ENTITY Main IS
	PORT(rst , clk: IN std_logic);
END ENTITY Main;

ARCHITECTURE vlsi OF Main IS	

signal counterOutF : std_logic_vector(3 downto 0);
signal counterOutI : std_logic_vector(3 downto 0);

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
signal DataF: std_logic_vector( 399 downto 0 );

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
signal LayerInfoOut:std_logic_vector(15 downto 0);
signal ImgWidthOut:std_logic_vector(15 downto 0);
-------------------------
signal WidthSquareOut :  std_logic_vector(5 downto 0);
signal CounterWidthSquare :  std_logic_vector(1 downto 0);


BEGIN
---conditions---
FilterAddressEN <= '1' when ((current_state = RI and ACKF = '1' ) or (current_state = RL and ACKF = '1' )) else '0';
TriStateCounterEN <= '1' when (current_state = RI and ACKF = '1' ) else '0';
ImgAddRegEN <= '1' when (current_state = RL and ACKI = '1' ) else '0';
ImgAddACKTriEN<='1' when (current_state = RL ) else '0';
zero <= (others=>'0');
ImgAddACKTriIN <= zero&ACKI;
-----------------


--register decliration---


FilterMem:entity work.RAM generic map (X=>25) port map (rst,clk,WriteF,ReadF,AddressF , DataF , ACKF ,counterOutF);
ImgMem:entity work.RAM generic map (X=>28) port map (rst,clk,WriteI,ReadI ,AddressI , DataI  ,ACKI ,counterOutI );

ReadInf:entity work.ReadInfoState  port map (clk,current_state , rst , ACKF , FilterAddressOut , DataF(15 downto 0) , NoOfLayers , AddressF );


FilterAddress:entity work.nBitRegister generic map (n=>13) port map ( FilterAddressIN , clk , rst ,FilterAddressEN , FilterAddressOut );
AdderTryState:entity work.triStateBuffer generic map (n=>13) port map ( TriStateCounterOUT , TriStateCounterEN,FilterAddressIN );
FilterAddressAdder:entity work.my_nadder generic map (n=>13) port map ( FilterAddressOut ,(others=>'0') ,'1', TriStateCounterOUT);

ImgAddReg:entity work.nBitRegister generic map (n=>13) port map ( ImgAddRegIN , clk , rst ,ImgAddRegEN , ImgAddRegOut );
ImgAddACKTri:entity work.triStateBuffer generic map (n=>13) port map ( ImgAddACKTriIN, ImgAddACKTriEN, ImgAddRegIN );

ReadLayerInfo:entity work.ReadLayerInfo generic map (n=>13) port map (DataF(15 downto 0 ),DataI(15 downto 0 ),FilterAddressOut,ImgAddRegOut , clk , rst ,ACKF,ACKI,current_state,LayerInfoOut,ImgWidthOut,AddressF,AddressI);


ClacInfo:entity work.CalculateInfo port map (WidthSquareOut,CounterWidthSquare,LayerInfoOut,clk,rst,current_state);

--------------------------


-- get the next state circuit--
state_decode_proc: process(current_state,ACKF)
BEGIN

	case current_state is 
		when RI =>
			if ACKF = '1' then 
			next_state<= RL;
			end if ;
		when RL=>
			if ACKF = '1' then
				if LayerInfoOut(15) = '1' then  
					next_state<= conv_calc_ReadImg_ReadBias;
				else 	next_state<= Pool_Cal_ReadImg;
				end if;
			end if;

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
output_proc : process(current_state,ACKF,ACKI)
begin
	case current_state is
		when RI=>
			ReadF<= '1';
			ReadI<='0';
			WriteF<='0';
			WriteI<='0';
		when RL=>
			ReadF<='1';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';

		when Pool_Cal_ReadImg=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';

		when Pool_Read_Img=>
		when conv_calc_ReadImg_ReadBias=>
		when conv_ReadImg_ReadFilter=>
		when conv_ReadImg=>
		when  CONV=>
	end case;
end process;


END vlsi;