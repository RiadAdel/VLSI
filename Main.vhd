LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY CNN IS
	PORT(	rst , clk:std_logic;
		LayerInfoOut : OUT std_logic_vector(15 downto 0));
END ENTITY CNN;

ARCHITECTURE vlsi OF CNN IS	

-- state decleration-------
type state is (RI ,RL); 
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
-------------------
signal ACKF:std_logic;
signal ACKI:std_logic;


---components---
component nBitRegister IS
	generic( n : integer := 16);
	PORT(	D: IN std_logic_vector(n-1 downto 0);	
		CLK,RST,EN : IN std_logic;
		Q : OUT std_logic_vector(n-1 downto 0));
END component;

component my_nadder IS

Generic ( n : integer := 8);
PORT(a, b : in std_logic_vector(n-1 downto 0);
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
END component;

component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END component;

---------------


BEGIN
---conditions---
FilterAddressEN <= '1' when (current_state = RI and ACKF = '1' ) or (current_state = RL and ACKF = '1' );
TriStateCounterEN <= '1' when (current_state = RI and ACKF = '1' );
ImgAddRegEN <= '1' when (current_state = RL and ACKI = '1' );
ImgAddACKTriEN<='1' when (current_state = RL );
zero <= (others=>'0');
ImgAddACKTriIN <= zero&ACKI;
-----------------


--register decliration---
FilterAddress:nBitRegister generic map (n=>13) port map ( FilterAddressIN , clk , rst ,FilterAddressEN , FilterAddressOut );
CounterTryState:triStateBuffer generic map (n=>13) port map ( TriStateCounterOUT , TriStateCounterEN,FilterAddressIN );
FilterAddressCounter:my_nadder generic map (n=>13) port map ( FilterAddressOut ,(others=>'0') ,'1', TriStateCounterOUT);

ImgAddReg:nBitRegister generic map (n=>13) port map ( ImgAddRegIN , clk , rst ,ImgAddRegEN , ImgAddRegOut );
ImgAddACKTri:triStateBuffer generic map (n=>13) port map ( ImgAddACKTriIN, ImgAddACKTriEN, ImgAddRegIN );


--------------------------

-- get the next state circuit--
state_decode_proc: process(current_state)
BEGIN

	case current_state is 
		when RI=>
			next_state<=RL;
		when RL=>
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
			-- some shit
		when RL=>
	end case;
end process;


END vlsi;