library IEEE;	
use IEEE.STD_LOGIC_1164.ALL;	
use IEEE.STD_LOGIC_ARITH.ALL;	 
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
entity FilterDMA is	
	Port (	
		addressIn : in std_logic_vector(9 downto 0); -- TODO ABZO: change size to 11 bits address to access filter register
		readEn,CLK: in std_logic;			--No write , MEMORY FILTER IS 1600*3(layers)
		FIlterMFC:out std_logic;			--memory fn complete
		valueOut : out std_logic_vector(399 downto 0)); --value out 25*16 = 400 represented by 11 bits
End Entity  FilterDMA; 
--------------------------------

architecture DMAFILTER of FilterDMA is	

Component RAM is --TODO RIAD change it to generic
  port (
    CLK,W,R:in std_logic;
    address:in std_logic_vector(9 downto 0); 
    data:inout std_logic_vector(447 downto 0);
    MFC:out std_logic
  ) ;
end Component;

---------Signals
Signal dataFromRam :std_logic_vector(447 downto 0);
Signal mfcOfRam :std_logic;
--------- 
begin	

FILTER: RAM port map (CLK,'0',readEn,addressIn,dataFromRam,mfcOfRam);

FilterMFC <=  mfcOfRam;
valueOut <= dataFromRam(399 downto 0);

end DMAFIlTER;

