library IEEE;	
use IEEE.STD_LOGIC_1164.ALL;	
use IEEE.STD_LOGIC_ARITH.ALL;	 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
---NOT FINISHED YET
entity memDMA is	
	Port (	
		AddressIn : in std_logic_vector(9 downto 0); -- TODO ABZO: change size to 13 bits address to access memory
		dataIn: in std_logic_vector(15 downto 0);
		switcherEN:in std_logic;		     -- exchange input ram with output ram
		ramSelector:in std_logic;                    -- -0 for input ram(i want to read from) ,1 for output ram(i want to save in)
		readEn,writeEn,CLK: in std_logic;	
		
		Normal: inout std_logic;		     --just set it to 0 when start
		MFC:out std_logic;			
		dataOut : out std_logic_vector(447 downto 0)); 
End Entity  memDMA; 
--------------------------------

architecture DMAmemory of memDMA is	

Component RAM is --TODO RIAD change it to generic
  port (
    CLK,W,R:in std_logic;
    address:in std_logic_vector(9 downto 0); 
    data:inout std_logic_vector(447 downto 0);
    MFC:out std_logic
  ) ;
end Component;

Component D_FF is
PORT( D,CLOCK: in std_logic;
	    Q: out std_logic;
	 Qbar: out std_logic);
end Component;

---------Signals
Signal dataFromTORam1 :std_logic_vector(447 downto 0);
Signal dataFromTORam2 :std_logic_vector(447 downto 0);
Signal mfcOfRam1,mfcOfRam2 :std_logic;
Signal DInput,Qout,Qbarout: std_logic;
--------- 
begin	

Dinput <= Normal XOR RamSelector;

	process(switcherEN)
		begin

		if(switcherEN='1') then
				Normal <= not Normal;
		end if;
	end process;


DFF: D_FF port map (Dinput,clk,Qout,Qbarout);

--handle input output data 
Ram1: RAM port map (CLK,Qout,Qbarout,addressIn,dataFromTORam1,mfcOfRam1);
Ram2: RAM port map (CLK,Qbarout,Qout,addressIn,dataFromTORam2,mfcOfRam2);

--read
dataOut <= 
     dataFromTORam2 when Qout = '1' and readEn ='1' else 
     dataFromToRam1 when Qout = '0' and readEn ='1';

--write
dataFromToRam2 <= dataIn when Qout = '0' and writeEn = '1' ;
dataFromToRam1 <= dataIn when Qout = '1' and writeEn = '1' ;

--mfc happens in both write and read
MFC <=        mfcOfRam1 when ramSelector = '0' and Qout = '0' else --read and no toggle happened(toggle 2 times = no toggle)
	      mfcOfRam1 when ramSelector = '1' and Qout = '1' else --write and toggle happened
	      mfcOfRam2 when ramSelector = '1' and Qout = '0' else --write and no toggle
	      mfcOfRam2; 					   --read with toggle
end DMAmemory;
