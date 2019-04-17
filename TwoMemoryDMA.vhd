library IEEE;	
use IEEE.STD_LOGIC_1164.ALL;	
use IEEE.STD_LOGIC_ARITH.ALL;	 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
---NOT FINISHED YET
entity memDMA is	
	Port (	
		AddressIn : in std_logic_vector(9 downto 0); -- TODO ABZO: change size to 13 bits address to access memory
		dataIn: in std_logic_vector(15 downto 0);
		switcherEN:in std_logic;		     -- exchange input with output ram
		ramSelector:in std_logic;                    -- selects either Input ram or output ram(D of flipflop)
		readEn,writeEn,CLK: in std_logic;	
		
		Normal: in std_logic;			     --just set it to 0 when start
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
Signal dataFromRam :std_logic_vector(447 downto 0);
Signal mfcOfRam :std_logic;
Signal DInput,Qout,Qbarout: std_logic;
--------- 
begin	

Dinput <= Normal XOR RamSelector;

	process(switcherEN)
		begin

		if(switcherEN='1') then
				Normal <= !Normal;
		end if;
	end process;


DFF: D_FF port map (Dinput,clk,Qout,Qbarout);

--handle input output data 
Ram1: RAM port map (CLK,writeeneable,readEn,addressIn,dataFromRlam,mfcOfRam);
Ram2: RAM port map (CLK,,readEn,addressIn,dataFromRam,mfcOfRam);

FilterMFC <=  mfcOfRam;
valueOut <= dataFromRam(399 downto 0);

end DMAmemory;

