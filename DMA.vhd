LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;
entity DMA is
  port (
    rst,clk,w,r,s:in std_logic;
    dataIn:inout std_logic_vector(15 downto 0);
    dataOut:inout std_logic_vector(447 downto 0);
    address:in std_logic_vector(12 downto 0);
    ack:out std_logic
  ) ;
end DMA;
architecture DMA_arch of DMA is
  signal data1Out,data2Out: std_logic_vector(447 downto 0);
  signal data1In,data2In: std_logic_vector(15 downto 0);
  signal add1,add2: std_logic_vector(12 downto 0);
  signal c1,c2: std_logic_vector(3 downto 0);
  signal ack1,ack2,r1,r2,w1,w2: std_logic;
  begin
    ImgMem1:entity work.RAM generic map (X=>28) port map (rst , clk , w1 , r1 , add1 , data1In , data1Out , ack1 ,c1);
    ImgMem2:entity work.RAM generic map (X=>28) port map (rst , clk , w2 , r2 , add2 , data2In , data2Out , ack2 ,c2);
    
    r1 <= r when s = '0'
    else '0';
    w1 <= w when s = '0'
    else '0';

    r2 <= r when s = '1'
    else '0';
    w2 <= w when s = '1'
    else '0';

    add1 <= address when s = '0';
    add2 <= address when s = '1';

    dataOut <= data1Out when r1 = '1'
    else data2Out;

    data1In <= dataIn when w1 = '1';
    data2In <= dataIn when w2 = '1';

    ack <= ack1 when s ='0'
    else ack2;
    
end DMA_arch;