library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ReadImage is
  port (
    State : in std_logic;
    CLK,RST:in std_logic; 
    ACK : in std_logic_vector(0 downto 0);
    address:in std_logic_vector(9 downto 0);
    ImgAddress : in std_logic_vector(12 downto 0);
    ImgWidth : in std_logic_vector(15 downto 0);
    DATA:inout std_logic_vector(447 downto 0);
    ImgAddRegEn : out std_logic_vector(0 downto 0);
    UpdatedAddress : out std_logic_vector(15 downto 0));
end ReadImage;

architecture archRI of ReadImage is
    	type columnOfRows is array (27 downto 0) of std_logic_vector(15 downto 0);
	type rowOfRegisters is array(0 to 5) of columnOfRows;
	signal column: columnOfRows;
	signal row: rowOfRegisters;
	signal cReset,cEnable:std_logic;
	signal cOutput:std_logic_vector(2 downto 0);
	SIGNAL triStateBufferEN : std_logic;
	SIGNAL filter1EN : std_logic;
	SIGNAL filter2EN : std_logic;
	SIGNAL decoderEN : std_logic;
	SIGNAL DFFCLK : std_logic;
	SIGNAL IndicatorImage : std_logic_vector(0 downto 0);
	SIGNAL Qbar : std_logic_vector(0 downto 0);
	SIGNAL firstOperand : std_logic_vector(15 downto 0);


 -- (here we add the previous full adder) ----
	COMPONENT nBitRegister IS
	GENERIC( n : integer := 16);
	PORT(	D: IN std_logic_vector(n-1 downto 0);	
		CLK,RST,EN : IN std_logic;
		Q : OUT std_logic_vector(n-1 downto 0));
	END COMPONENT;

	COMPONENT triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
	END COMPONENT;

	COMPONENT my_nadder IS
	Generic ( n : integer := 16);
	PORT(a, b : in std_logic_vector(n-1 downto 0);
		cin : in std_logic;
		s : out std_logic_vector(n-1 downto 0);
		cout : out std_logic);
	END COMPONENT;

	COMPONENT Counter is
	generic(n: integer := 16);
	port(
		enable:in std_logic;
		reset:in std_logic;
		clk:in std_logic;
		load:in std_logic;
		output:out std_logic_vector(n-1 downto 0);
		input:in std_logic_vector(n-1 downto 0));
	END COMPONENT;

	BEGIN
    
    	--DFFCLK <= '1' when (State_conv AND ACK) else '0';
	Qbar <= NOT(IndicatorImage);
	DDF0 : nBitRegister generic map (1) port map(Qbar,DFFCLK,RST,'1',IndicatorImage);

	--na2s 7agat kter lsa
	RegCounter0: Counter generic map (3) port map(cEnable,cReset,CLK,'0',cOutput,"001");
	
	-- state needs to be changed

	tsb0 : triStateBuffer generic map (1) port map(ACK,decoderEN,ImgAddRegEn);

	firstOperand <=  "000" & imgAddress;
	adder0: my_nadder port map(firstOperand,ImgWidth,'0',UpdatedAddress);

	--decoderEN <= (State = stateReadIMAGE) or ((State = stateCONV) AND (IndicatorImage = '0'));
	--IF (decoderEN) THEN
		--IF (cOutput = "000") THEN
		--	deccoderOutput <= "000001"

	

	--HANDLE REGISTERS
    	PROCESS(CLK,RST,decoderEN)
    	BEGIN
	    ----------------------RESETTING THE REGISTERS-----------------------
	    IF (RST='1') THEN
		loop1: for i in 0 to 5 loop
		    column <= row(i);
    	            loop2: for j in 0 to 27 loop
    	            	column(j) <= (OTHERS=>'0');	
		    end loop;
		end loop;
	    --------------------------------------------------------------------
	    -------------------------------INPUT--------------------------------
	    ELSIF (CLK'EVENT AND CLK = '1') THEN
		IF decoderEN = '1' THEN 
		    column <= row(to_integer(unsigned(cOutput)));
		    loop3: for i in 0 to 27 loop
		    	column(i) <= DATA((16*(i+1)-1) downto 16*i);
		    end loop;
		END IF;
	    --------------------------------------------------------------------
	    --------------------------------------------------------------------
	    END IF;
    	END PROCESS;
END archRI;