library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ReadImage is
  port (
    STATE : in state;
    CLK,RST:in std_logic; 
    ACK : in std_logic;
    ImgAddress : in std_logic_vector(12 downto 0);
    ImgWidth : in std_logic_vector(15 downto 0);
    DATA: in std_logic_vector(447 downto 0);
    OutputImg0 : out std_logic_vector(447 downto 0 );
    OutputImg1 : out std_logic_vector(447 downto 0 );
    OutputImg2 : out std_logic_vector(447 downto 0 );
    OutputImg3 : out std_logic_vector(447 downto 0 );
    OutputImg4 : out std_logic_vector(447 downto 0 );
    OutputImg5 : out std_logic_vector(447 downto 0 );
    ImgCounterOuput: out std_logic_vector(2 downto 0);
    ImgAddToDma : out std_logic_vector(12 downto 0);
    UpdatedAddress : out std_logic_vector(12 downto 0);
    ImgIndic: out std_logic_vector(0 downto 0);
    ImgEn : out std_logic_vector(5 downto 0) );
end ReadImage;

architecture archRI of ReadImage is
	SIGNAL firstOperand : std_logic_vector(15 downto 0);
	signal newAdd16: std_logic_vector(15 downto 0);
	signal TriAddEn : std_logic;
	signal TriAddToDMaEn : std_logic;
	SIGNAL DFFCLK : std_logic;
	SIGNAL IndicatorImage : std_logic_vector(0 downto 0);
	SIGNAL Qbar : std_logic_vector(0 downto 0);
        signal cReset,cEnable:std_logic;
	signal cOutput:std_logic_vector(2 downto 0);
    	signal DecOutput :  std_logic_vector(5 downto 0);
	signal ImgRegEN : std_logic_vector(5 downto 0); 
	signal TriImgRegEn : std_logic;
	signal ImgReg0 : std_logic_vector(447 downto 0 );
	signal ImgReg1 : std_logic_vector(447 downto 0 );
	signal ImgReg2 : std_logic_vector(447 downto 0 );
	signal ImgReg3 : std_logic_vector(447 downto 0 );
	signal ImgReg4 : std_logic_vector(447 downto 0 );
	signal ImgReg5 : std_logic_vector(447 downto 0 );

	
	type columnOfRows is array (27 downto 0) of std_logic_vector(15 downto 0);
	type rowOfRegisters is array(0 to 5) of columnOfRows;
	signal column: columnOfRows;
	signal row: rowOfRegisters;
	
	

	BEGIN
	OutputImg0 <= ImgReg0;
    	OutputImg1 <= ImgReg1;
    	OutputImg2 <= ImgReg2;
    	OutputImg3 <= ImgReg3;
    	OutputImg4 <= ImgReg4;
    	OutputImg5 <= ImgReg5;
	
 	ImgCounterOuput<=cOutput;
        ImgIndic <= IndicatorImage ; 
	firstOperand <=  "000" & imgAddress;

	TriAddEn <= '1' when (STATE = Pool_Cal_ReadImg) or (STATE =Pool_Read_Img ) or (STATE=conv_calc_ReadImg_ReadBias)
	or (STATE =conv_ReadImg_ReadFilter ) or (STATE = conv_ReadImg) or ((STATE = CONV) and (IndicatorImage = "0") ) else '0' ;

	adder0: entity work.my_nadder generic map (16) port map(firstOperand,ImgWidth,'0',newAdd16);
	triStateAdd : entity work.triStateBuffer generic map (13) port map(newAdd16(12 downto 0),TriAddEn,UpdatedAddress);
	
	TriAddToDMaEn<='1' when (STATE = Pool_Cal_ReadImg) or (STATE =Pool_Read_Img ) or (STATE=conv_calc_ReadImg_ReadBias)
	or (STATE =conv_ReadImg_ReadFilter ) or (STATE = conv_ReadImg) or ((STATE = CONV) and IndicatorImage = "0" ) else '0';


	TriStateAddToDma : entity work.triStateBuffer generic map (13) port map(ImgAddress,TriAddToDMaEn,ImgAddToDma);


    	DFFCLK <= '1' when ((STATE = CONV) AND (ACK='1') and (CLK'event and CLK='1')  ) else '0';
	Qbar <= NOT(IndicatorImage);
	DDF0 :entity work.nBitRegister generic map (1) port map(Qbar,DFFCLK,RST,'1',IndicatorImage);


	cEnable<='1' when (((STATE = Pool_Cal_ReadImg) or (STATE =Pool_Read_Img ) or (STATE=conv_calc_ReadImg_ReadBias)
	or (STATE =conv_ReadImg_ReadFilter ) or (STATE = conv_ReadImg)) and (ACK = '1') )  else '0';

	RegCounter0: entity work.Counter generic map (3) port map(cEnable,RST, CLK,'0',cOutput,"001");
	
	dec : entity work.Decoder port map (cOutput ,DecOutput );

	TriImgRegEn <= '1' when (((STATE = Pool_Cal_ReadImg) or (STATE =Pool_Read_Img ) or (STATE=conv_calc_ReadImg_ReadBias)
	or (STATE =conv_ReadImg_ReadFilter ) or (STATE = conv_ReadImg)) and (ACK = '1') ) or ((STATE = CONV) and (IndicatorImage = "0") and (ACK = '1') ) else '0';  
	
	TriImgReg : entity work.triStateBuffer generic map (6) port map(DecOutput,TriImgRegEn,ImgRegEN);
	
	ImgEn<= ImgRegEN ;


	loop3: FOR i in 0 to 27 Generate

        reg1:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(0) , ImgReg0((16*(i+1)-1) downto 16*i) );
	reg2:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(1) , ImgReg1((16*(i+1)-1) downto 16*i) );
	reg3:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(2) , ImgReg2((16*(i+1)-1) downto 16*i) );
	reg4:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(3) , ImgReg3((16*(i+1)-1) downto 16*i) );
	reg5:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(4) , ImgReg4((16*(i+1)-1) downto 16*i) );
	reg6:entity work.nBitRegister generic map(16) PORT MAP ( Data((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgRegEN(5) , ImgReg5((16*(i+1)-1) downto 16*i) );
	
	end Generate;


END archRI;