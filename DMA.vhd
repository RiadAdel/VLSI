library ieee;
use ieee.std_logic_1164.all;
entity DMA is
  port (
    data:in std_logic_vector(2239 downto 0);
    output1:out std_logic_vector(2239 downto 0)
  ) ;
end DMA;
architecture DMA_arch of DMA is
    begin
    output1 <= data1 and data2;
	    process(CLK)
    begin
        if  (W = '1')then
            if (CLK'event and CLK = '1') then
                
            end if ;
        elsif  (R = '1')then
            if (CLK'event and CLK = '1') then
                
            end if ;
        end if ;
    end process;
end DMA_arch ;