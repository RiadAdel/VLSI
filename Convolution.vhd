library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;


entity Convolution is
  port (
    current_state : in state;
    CLK,RST ,QImgStat:in std_logic; 
    ACK : out std_logic;
    LayerInfo : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    ImgAddress : in std_logic_vector(12 downto 0);
    OutputImg0 : in std_logic_vector(79 downto 0 );
    OutputImg1 : in std_logic_vector(79 downto 0 );
    OutputImg2 : in std_logic_vector(79 downto 0 );
    OutputImg3 : in std_logic_vector(79 downto 0 );
    OutputImg4 : in std_logic_vector(79 downto 0 );
    outFilter0,outFilter1 : in STD_LOGIC_VECTOR(399 DOWNTO 0);
    ConvOuput : out STD_LOGIC_VECTOR(15 DOWNTO 0)

       );
end Convolution;


architecture ConvArch of Convolution is

signal Filter : STD_LOGIC_VECTOR(399 DOWNTO 0);
signal FilterToAlu : STD_LOGIC_VECTOR(399 DOWNTO 0);
signal ImgPixels :  STD_LOGIC_VECTOR(399 DOWNTO 0);
signal MultiplierOut :  STD_LOGIC_VECTOR(799 DOWNTO 0);
signal AddOutputLvL1 :  STD_LOGIC_VECTOR(191 DOWNTO 0);
signal AddOutputLvL2 :  STD_LOGIC_VECTOR(95 DOWNTO 0);
signal AddOutputLvL3 :  STD_LOGIC_VECTOR(47 DOWNTO 0);

signal AddOut33 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal AddOut55 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Final55 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal FinalConv :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Relu :  STD_LOGIC_VECTOR(15 DOWNTO 0);
signal pool :  STD_LOGIC_VECTOR(15 DOWNTO 0);

signal MultiplierOut16 : STD_LOGIC_VECTOR(399 DOWNTO 0);

signal CounterOut : std_logic_vector(2 downto 0);
signal CountereEN : std_logic;
signal ACKC : std_logic;
signal CountereRST : std_logic;



Begin

CountereEN <= '1' when (current_state = CONV ) and (ACKC = '0')      else '0';
CountereRST <= '1' when (rst = '1') or (CounterOut = "100")  else '0' ;

ACKC <= '1' when( CounterOut = "011") and (CLK'event and CLK = '1') 
else '0' when   (CLK'event and CLK = '1'); 
ACK <=ACKC;



ImgPixels<= OutputImg4&OutputImg3&OutputImg2&OutputImg1&OutputImg0;
Filter<= outFilter0 when QImgStat='0' else outFilter1;

FilterToAlu<= Filter when LayerInfo(15)='0' else (others=>'1') ;



loop3: FOR i in 0 to 24 Generate

Multip:entity work.Multiplier generic map (n=>16) port map ( FilterToAlu((16*(i+1)-1) downto 16*i) , ImgPixels((16*(i+1)-1) downto 16*i) ,MultiplierOut((32*(i+1)-1) downto 32*i)  );

end generate ;



---- we can make celling for positive numbers
loop2: FOR i in 0 to 24 Generate

MultiplierOut16((16*(i+1)-1) downto 16*i) <= MultiplierOut( ((32*(i+1)-1)-7)   downto  ((32*i) + 9));


end generate ;


--- 3*3 adders
adder1 : entity work.my_nadder generic map (16) port map(MultiplierOut16(15 downto 0 ),MultiplierOut16( 31 downto 16 ),'0',AddOutputLvL1( 15 downto 0));
adder2 : entity work.my_nadder generic map (16) port map(MultiplierOut16(47 downto 32 ),MultiplierOut16( 95 downto 80 ),'0',AddOutputLvL1( 31 downto 16));
adder3 : entity work.my_nadder generic map (16) port map(MultiplierOut16(111 downto 96 ),MultiplierOut16( 127 downto 112 ),'0',AddOutputLvL1( 47 downto 32));
adder4 : entity work.my_nadder generic map (16) port map(MultiplierOut16(175 downto 160 ),MultiplierOut16( 191 downto 176 ),'0',AddOutputLvL1( 63 downto 48));

adder12 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 15 downto 0),AddOutputLvL1( 31 downto 16),'0',AddOutputLvL2( 15 downto 0));
adder13 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 47 downto 32),AddOutputLvL1( 63 downto 48),'0',AddOutputLvL2( 31 downto 16));

adder18 : entity work.my_nadder generic map (16) port map(AddOutputLvL2( 15 downto 0),AddOutputLvL2( 31 downto 16),'0',AddOutputLvL3( 15 downto 0));

adder21 : entity work.my_nadder generic map (16) port map(AddOutputLvL3( 15 downto 0),MultiplierOut16( 207 downto 192 ),'0',AddOut33);




-- 5*5 adders
adder5 : entity work.my_nadder generic map (16) port map(MultiplierOut16(63 downto 48 ),MultiplierOut16( 79 downto 64 ),'0',AddOutputLvL1( 79 downto 64));
adder6 : entity work.my_nadder generic map (16) port map(MultiplierOut16(143 downto 128 ),MultiplierOut16( 159 downto 144 ),'0',AddOutputLvL1( 95 downto 80));
adder7 : entity work.my_nadder generic map (16) port map(MultiplierOut16(223 downto 208 ),MultiplierOut16( 239 downto 224 ),'0',AddOutputLvL1( 111 downto 96));

adder8 : entity work.my_nadder generic map (16) port map(MultiplierOut16(255 downto 240 ),MultiplierOut16( 271 downto 256 ),'0',AddOutputLvL1( 127 downto 112));
adder9 : entity work.my_nadder generic map (16) port map(MultiplierOut16(287 downto 272 ),MultiplierOut16( 303 downto 288 ),'0',AddOutputLvL1( 143 downto 128));
adder10 : entity work.my_nadder generic map (16) port map(MultiplierOut16(319 downto 304 ),MultiplierOut16( 335 downto 320 ),'0',AddOutputLvL1( 159 downto 144));
adder11 : entity work.my_nadder generic map (16) port map(MultiplierOut16(351 downto 336 ),MultiplierOut16( 367 downto 352 ),'0',AddOutputLvL1( 175 downto 160));
adder0 : entity work.my_nadder generic map (16) port map(MultiplierOut16(383 downto 368 ),MultiplierOut16( 399 downto 384 ),'0',AddOutputLvL1( 191 downto 176));

adder14 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 79 downto 64),AddOutputLvL1( 95 downto 80),'0',AddOutputLvL2( 47 downto 32));
adder15 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 111 downto 96),AddOutputLvL1( 127 downto 112),'0',AddOutputLvL2( 63 downto 48));
adder16 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 143 downto 128),AddOutputLvL1( 159 downto 144),'0',AddOutputLvL2( 79 downto 64));
adder17 : entity work.my_nadder generic map (16) port map(AddOutputLvL1( 175 downto 160),AddOutputLvL1( 191 downto 176),'0',AddOutputLvL2( 95 downto 80));

adder19 : entity work.my_nadder generic map (16) port map(AddOutputLvL2( 47 downto 32),AddOutputLvL2( 63 downto 48),'0',AddOutputLvL3( 31 downto 16));
adder20 : entity work.my_nadder generic map (16) port map(AddOutputLvL2( 79 downto 64),AddOutputLvL2( 95 downto 80),'0',AddOutputLvL3( 47 downto 32));

adder22 : entity work.my_nadder generic map (16) port map(AddOutputLvL3( 31 downto 16),AddOutputLvL3( 47 downto 32),'0',AddOut55);



adder23 : entity work.my_nadder generic map (16) port map(AddOut55 ,AddOut33,'0',Final55);

FinalConv<= Final55 when LayerInfo(14) = '1' else AddOut33;

Relu<= FinalConv when FinalConv(15)='0' else (others=>'0');


pool<= FinalConv(15)&FinalConv(15)&FinalConv(15)&FinalConv(15 downto 3)  when LayerInfo(14) = '0' else FinalConv(15)&FinalConv(15)&FinalConv(15)&FinalConv(15)&FinalConv(15)&FinalConv(15 downto 5 ) ; 

ConvOuput<= Relu when LayerInfo(15)='0' else pool;



EndCounter:entity work.Counter generic map (n=>3) port map ( CountereEN ,CountereRST , clk , '0' ,CounterOut , "000" );









END ConvArch ;