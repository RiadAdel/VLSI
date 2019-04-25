library IEEE;	
use IEEE.STD_LOGIC_1164.ALL;	
use IEEE.STD_LOGIC_ARITH.ALL;	 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
---NOT FINISHED YET
entity memoryDMA is	
	Port (	
		resetEN: in std_logic;
		AddressIn : in std_logic_vector(12 downto 0); -- TODO ABZO: change size to 13 bits address to access memory
		dataIn: in std_logic_vector(15 downto 0);
		switcherEN:in std_logic;		     -- exchange input ram with output ram
		ramSelector:in std_logic;                    -- -0 for input ram(i want to read from) ,1 for output ram(i want to save in)
		readEn,writeEn,CLK: in std_logic;	
		Normal: inout std_logic;		     --just set it to 0 when start
		MFC:out std_logic;		
		counterOut:out std_logic_vector(3 downto 0);
		dataOut : out std_logic_vector(447 downto 0)); 
End Entity  memoryDMA; 
--------------------------------

architecture DMAmemory of memoryDMA is	


Component RAM is
generic(X: integer := 28);
  port (
    reset:in std_logic;
    CLK,W,R:in std_logic;
    address:in std_logic_vector(12 downto 0);
    dataIn:in std_logic_vector( 15 downto 0);
    dataOut:out std_logic_vector(((X*16)-1) downto 0);
    MFC:out std_logic;
    counterOut:out std_logic_vector(3 downto 0)
  ) ;
end Component;

Component D_FF is
PORT( D,CLOCK: in std_logic;
	    Q: out std_logic;
	 Qbar: out std_logic);
end Component;

Component triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
end Component;
---------Signals
Signal dataFromRam1,dataFromRam2     :std_logic_vector(447 downto 0);
Signal dataToRam1,dataToRam2	     :std_logic_vector(15 downto 0);
Signal counterOut1,counterOut2       :std_logic_vector(3 downto 0);
Signal mfcOfRam1,mfcOfRam2 	     :std_logic;
Signal DInput,Qout,Qbarout           :std_logic;
Signal reset1,reset2	             :std_logic;
Signal testout :std_logic_vector(15 downto 0);

Signal ram1Read,ram1Write,ram2Read,ram2Write :std_logic;
--------- 
begin	

Dinput <= Normal XOR RamSelector;

	process(switcherEN)
		begin

		if(switcherEN='1') then
				Normal <= not Normal;
		else Normal <= Normal;
		end if;
	end process;


DFF: D_FF port map (Dinput,clk,Qout,Qbarout);

Ram1Rd:  tristatebuffer  generic map ( 448 ) port map (dataFromRam1,ram1Read,dataOut);

Ram1Wr: tristatebuffer  generic map ( 16 )  port map (dataIn,ram1Write,dataToRam1); --dataFromTORam1(15 downto 0)

Ram2Rd:  tristatebuffer  generic map ( 448 ) port map (dataFromRam2,ram2Read,dataOut);

Ram2Wr: tristatebuffer  generic map ( 16 )  port map (dataIn,ram2Write,dataToRam2);

--handle input output data 
Ram1: RAM port map (reset1,CLK,ram1Write,ram1Read,addressIn,dataToRam1,dataFromRam1,mfcOfRam1,counterOut1);
Ram2: RAM port map (reset2,CLK,ram2Write,ram2Read,addressIn,dataToRam2,dataFromRam2,mfcOfRam2,counterOut2);

--read
ram2Read <=  '1' when Qout = '1' and readEn ='1' else '0';
ram1Read <= '1' when Qout = '0' and readEn ='1' else '0';

--reset
reset1 <= resetEN ;--when (Qout XNOR ramSelector)  = '1' else '0';
reset2 <= resetEN ;--when (Qout XOR ramSelector)   = '1' else '0';

--write
  ram2Write <= '1' when Qout = '1' and writeEn = '1' else '0' ;
  ram1Write <= '1' when Qout = '0' and writeEn = '1' else '0' ;

--mfc happens in both write and read
MFC <=        mfcOfRam1 when ramSelector = '0' and Qout = '0' else --read and no toggle happened(toggle 2 times = no toggle)
	      mfcOfRam1 when ramSelector = '1' and Qout = '0' else --write and toggle happened
	      mfcOfRam2 when ramSelector = '1' and Qout = '1' else --write and no toggle
	      mfcOfRam2 when ramSelector = '0' and Qout = '1'; 	   --read with toggle
end DMAmemory;

