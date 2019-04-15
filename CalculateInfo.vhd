LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;

ENTITY CalculateInfo IS
	PORT(   WSquareOut : OUT std_logic_vector(5 downto 0);
		LayerInfoIn  : IN std_logic_vector(15 downto 0);
		EN ,clk , rst : IN std_logic;
		current_state: IN state );
END ENTITY CalculateInfo;


ARCHITECTURE CalInfo OF CalculateInfo IS	

signal WSquareEN : std_logic;
signal WSquareIN : std_logic_vector(5 downto 0);
signal Wminus1 : std_logic_vector(2 downto 0);
signal CounterOut : std_logic_vector(2 downto 0);
signal CountereEN : std_logic_vector(2 downto 0);
signal FinishedMulti: std_logic;

component Multiplier is
   generic(n:integer :=15);
    port( A,B :in std_logic_vector(n-1 downto 0);
          F  :out std_logic_vector(n+n-1 downto 0)
	);
end component;

component my_nadder IS

Generic ( n : integer := 8);
PORT(a, b : in std_logic_vector(n-1 downto 0);
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END component;

component nBitRegister IS
	generic( n : integer := 16);
	PORT(	D: IN std_logic_vector(n-1 downto 0);	
		CLK,RST,EN : IN std_logic;
		Q : OUT std_logic_vector(n-1 downto 0));
END component;

component Counter is
	generic(n: integer := 16);
	port(
		enable:in std_logic;
		reset:in std_logic;
		clk:in std_logic;
		load:in std_logic;
		output:out std_logic_vector(n-1 downto 0);
		input:in std_logic_vector(n-1 downto 0));
end component;


BEGIN 

WSquareEN <= '0' when (current_state = RI ) or ((current_state = RL ))     else '1';

--WSquareEN <= '1' when (current_state = Pool_Cal_ReadImg ) or ((current_state = conv_calc_ReadImg_ReadBias ))     else '0';

-- layerInforIn dont know where exacly is the size of filter
WSquareMulti:Multiplier generic map (n=>3) port map ( LayerInfoIn(2 downto 0) , Wminus1 ,WSquareIN );
---values here is also wrong in LayerInfoIn cause i dont know index and its length and second parameter i must send -1
--- but i dont know the legth and if our adder handle signed or not and that shittttttt
adder:my_nadder generic map (n=>3) port map ( LayerInfoIn(2 downto 0) ,'1'&'0'&'1' ,'0',Wminus1 );


WSquareReg:nBitRegister generic map (n=>6) port map ( WSquareIN , clk , rst ,WSquareEN , WSquareOut );


--- want to know the value to stop at and when to rest it  and EN there is still alot to do 
EndCounter:Counter generic map (n=>6) port map ( CountereEN ,rst , clk , '0' ,CounterOut );





END CalInfo;