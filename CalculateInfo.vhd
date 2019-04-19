LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
use work.constants.all;

ENTITY CalculateInfo IS
	PORT(   WSquareOut : OUT std_logic_vector(9 downto 0);
		CounOut : OUT std_logic_vector(1 downto 0);
		LayerInfoIn  : IN std_logic_vector(15 downto 0);
		clk , rst : IN std_logic;
		current_state: IN state; 
		ACK: Out std_logic;
		ACKI : IN std_logic;
		Wmin1: out std_logic_vector(4 downto 0) );

END ENTITY CalculateInfo;


ARCHITECTURE CalInfo OF CalculateInfo IS	
signal CLKEvent : std_logic;
signal ACKW :std_logic;
signal WSquareEN : std_logic;
signal WSquareIN : std_logic_vector(9 downto 0);
signal Wminus1 : std_logic_vector(4 downto 0);
signal CounterOut : std_logic_vector(1 downto 0);
signal CountereEN : std_logic;
signal CountereRST : std_logic;
signal FinishedMulti: std_logic;


BEGIN 

Wmin1<= Wminus1 ;
WSquareEN <= '1' when (current_state = Pool_Cal_ReadImg and ACKW ='1'  ) or (current_state = conv_calc_ReadImg_ReadBias   and ACKW='1'  )     else '0';
CountereEN <= '1' when ((current_state = Pool_Cal_ReadImg ) or (current_state = conv_calc_ReadImg_ReadBias )) and (ACKW = '0')      else '0';
CountereRST <= '1' when (rst = '1') or (CounterOut = "10") or ( ((current_state = Pool_Cal_ReadImg ) or (current_state = conv_calc_ReadImg_ReadBias )) and  ACKI ='1' ) else '0' ;


ACKW <= '1' when( CounterOut = "01") and (CLK'event and CLK = '1') 
else '0' when   (CLK'event and CLK = '1'); 
ACK <=ACKW;

CounOut <=CounterOut;

WSquareOut<=  unsigned(LayerInfoIn(8 downto 4 )) * unsigned(Wminus1);

WSquareMulti:entity work.Multiplier generic map (n=>5) port map ( LayerInfoIn(8 downto 4) , Wminus1 ,WSquareIN );


adder:entity work.my_nadder generic map (n=>5) port map ( LayerInfoIn(8 downto 4) ,'1'&'1'&'1'&'1'&'1' ,'0',Wminus1 );


--WSquareReg:entity work.nBitRegister generic map (n=>10) port map ( WSquareIN(9 downto 0) , clk , rst ,WSquareEN , WSquareOut );



EndCounter:entity work.Counter generic map (n=>2) port map ( CountereEN ,CountereRST , clk , '0' ,CounterOut , "00" );





END CalInfo;