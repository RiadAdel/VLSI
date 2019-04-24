library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity ReadImage is
  port (
    WI : in std_logic;
    current_state : in state;
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
	signal ImgReg0IN : std_logic_vector(447 downto 0 );
	signal ImgReg1IN : std_logic_vector(447 downto 0 );
	signal ImgReg2IN : std_logic_vector(447 downto 0 );
	signal ImgReg3IN : std_logic_vector(447 downto 0 );
	signal ImgReg4IN : std_logic_vector(447 downto 0 );
	signal ImgReg5IN : std_logic_vector(447 downto 0 );
	signal TriImgUpEn : std_logic ; 
	signal TriImgLeftEn : std_logic;
	signal ImgLastEn : std_logic_vector(5 downto 0); 
	signal IndRst : std_logic;
	
	

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

	TriAddEn <= '1' when (current_state = Pool_Cal_ReadImg) or (current_state =Pool_Read_Img ) or (current_state=conv_calc_ReadImg_ReadBias)
	or (current_state =conv_ReadImg_ReadFilter ) or (current_state = conv_ReadImg) or ((current_state = CONV) and (IndicatorImage = "0") ) else '0' ;

	adder0: entity work.my_nadder generic map (16) port map(firstOperand,ImgWidth,'0',newAdd16);
	triStateAdd : entity work.triStateBuffer generic map (13) port map(newAdd16(12 downto 0),TriAddEn,UpdatedAddress);
	
	TriAddToDMaEn<='1' when (current_state = Pool_Cal_ReadImg) or (current_state =Pool_Read_Img ) or (current_state=conv_calc_ReadImg_ReadBias)
	or (current_state =conv_ReadImg_ReadFilter ) or (current_state = conv_ReadImg) or ((current_state = CONV) and IndicatorImage = "0" ) else '0';


	TriStateAddToDma : entity work.triStateBuffer generic map (13) port map(ImgAddress,TriAddToDMaEn,ImgAddToDma);


    	DFFCLK <= '1' when ((current_state = CONV) AND (ACK='1') and (CLK'event and CLK='1')  ) else '0';
	Qbar <= NOT(IndicatorImage);
	
	IndRst<= '1' when current_state = SHUP  or  RST = '1' else '0';
	DDF0 :entity work.nBitRegister generic map (1) port map(Qbar,DFFCLK,IndRst,'1',IndicatorImage);


	cEnable<='1' when (((current_state = Pool_Cal_ReadImg) or (current_state =Pool_Read_Img ) or (current_state=conv_calc_ReadImg_ReadBias)
	or (current_state =conv_ReadImg_ReadFilter ) or (current_state = conv_ReadImg)) and (ACK = '1') )  else '0';

	cReset<= '1' when ( (RST = '1')  or   (current_state = CHECKS )   ) else '0';
-----------------------------------------------------
	RegCounter0: entity work.Counter generic map (3) port map(cEnable,cReset, CLK,'0',cOutput,"001");
	
	dec : entity work.Decoder port map (cOutput ,DecOutput );

	TriImgRegEn <= '1' when (((current_state = Pool_Cal_ReadImg) or (current_state =Pool_Read_Img ) or (current_state=conv_calc_ReadImg_ReadBias)
	or (current_state =conv_ReadImg_ReadFilter ) or (current_state = conv_ReadImg)) and (ACK = '1') ) or ((current_state = CONV) and (IndicatorImage = "0") and (ACK = '1') ) else '0';  
	
	TriImgReg : entity work.triStateBuffer generic map (6) port map(DecOutput,TriImgRegEn,ImgRegEN);
	
	ImgEn<= ImgRegEN ;

	TriImgUpEn <= '1' when current_state =SHUP   else '0';
	TriImgLeftEn<= '1' when (current_state= SHLEFT) or ((current_state=SAVE)and ( ACK = '1' ) and ( WI = '1') )    else '0';

	loop10: FOR i in 0 to 4 Generate

	ImgLastEn(i)<= '1' when ( (TriImgUpEn = '1') or (TriImgLeftEn = '1') or (ImgRegEN(i)='1' ) ) else '0';

	end Generate;
	
	ImgLastEn(5)<= '1' when ( (TriImgLeftEn = '1') or (ImgRegEN(5)='1' ) ) else '0';

	loop3: FOR i in 0 to 26 Generate
	
	TriState0L : entity work.triStateBuffer generic map (16) port map(ImgReg0((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg0IN((16*(i+1)-1) downto 16*i));
	TriState1L : entity work.triStateBuffer generic map (16) port map(ImgReg1((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg1IN((16*(i+1)-1) downto 16*i));
	TriState2L : entity work.triStateBuffer generic map (16) port map(ImgReg2((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg2IN((16*(i+1)-1) downto 16*i));
	TriState3L : entity work.triStateBuffer generic map (16) port map(ImgReg3((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg3IN((16*(i+1)-1) downto 16*i));
	TriState4L : entity work.triStateBuffer generic map (16) port map(ImgReg4((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg4IN((16*(i+1)-1) downto 16*i));
	TriState5L : entity work.triStateBuffer generic map (16) port map(ImgReg5((16*(i+2)-1) downto 16*(i+1)),TriImgLeftEn,ImgReg5IN((16*(i+1)-1) downto 16*i));
	
	TriState0N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(0),ImgReg0IN((16*(i+1)-1) downto 16*i));
	TriState1N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(1),ImgReg1IN((16*(i+1)-1) downto 16*i) );
	TriState2N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(2),ImgReg2IN((16*(i+1)-1) downto 16*i) );
	TriState3N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(3),ImgReg3IN((16*(i+1)-1) downto 16*i) );
	TriState4N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(4),ImgReg4IN((16*(i+1)-1) downto 16*i) );
	TriState5N : entity work.triStateBuffer generic map (16) port map(Data((16*(i+1)-1) downto 16*i),ImgRegEN(5),ImgReg5IN((16*(i+1)-1) downto 16*i) );

	TriState0U : entity work.triStateBuffer generic map (16) port map(ImgReg1((16*(i+1)-1) downto 16*i),TriImgUpEn,ImgReg0IN((16*(i+1)-1) downto 16*i));
	TriState1U : entity work.triStateBuffer generic map (16) port map(ImgReg2((16*(i+1)-1) downto 16*i),TriImgUpEn,ImgReg1IN((16*(i+1)-1) downto 16*i));
	TriState2U : entity work.triStateBuffer generic map (16) port map(ImgReg3((16*(i+1)-1) downto 16*i),TriImgUpEn,ImgReg2IN((16*(i+1)-1) downto 16*i));
	TriState3U : entity work.triStateBuffer generic map (16) port map(ImgReg4((16*(i+1)-1) downto 16*i),TriImgUpEn,ImgReg3IN((16*(i+1)-1) downto 16*i));
	TriState4U : entity work.triStateBuffer generic map (16) port map(ImgReg5((16*(i+1)-1) downto 16*i),TriImgUpEn,ImgReg4IN((16*(i+1)-1) downto 16*i));
	
	

        reg1:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg0IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(0) , ImgReg0((16*(i+1)-1) downto 16*i) );
	reg2:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg1IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(1) , ImgReg1((16*(i+1)-1) downto 16*i) );
	reg3:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg2IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(2) , ImgReg2((16*(i+1)-1) downto 16*i) );
	reg4:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg3IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(3) , ImgReg3((16*(i+1)-1) downto 16*i) );
	reg5:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg4IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(4) , ImgReg4((16*(i+1)-1) downto 16*i) );
	reg6:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg5IN((16*(i+1)-1) downto 16*i)  , CLK , RST ,  ImgLastEn(5) , ImgReg5((16*(i+1)-1) downto 16*i) );
	
	end Generate;



	TriState00L : entity work.triStateBuffer generic map (16) port map(ImgReg0( 15 downto 0),TriImgLeftEn,ImgReg0IN(447 downto 432));
	TriState11L : entity work.triStateBuffer generic map (16) port map(ImgReg1( 15 downto 0),TriImgLeftEn,ImgReg1IN(447 downto 432));
	TriState22L : entity work.triStateBuffer generic map (16) port map(ImgReg2( 15 downto 0),TriImgLeftEn,ImgReg2IN(447 downto 432));
	TriState33L : entity work.triStateBuffer generic map (16) port map(ImgReg3( 15 downto 0),TriImgLeftEn,ImgReg3IN(447 downto 432));
	TriState44L : entity work.triStateBuffer generic map (16) port map(ImgReg4( 15 downto 0),TriImgLeftEn,ImgReg4IN(447 downto 432));
	TriState55L : entity work.triStateBuffer generic map (16) port map(ImgReg5( 15 downto 0),TriImgLeftEn,ImgReg5IN(447 downto 432));
	
	TriState00N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(0),ImgReg0IN(447 downto 432) );
	TriState11N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(1),ImgReg1IN(447 downto 432) );
	TriState22N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(2),ImgReg2IN(447 downto 432) );
	TriState33N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(3),ImgReg3IN(447 downto 432) );
	TriState44N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(4),ImgReg4IN(447 downto 432) );
	TriState55N : entity work.triStateBuffer generic map (16) port map(Data(447 downto 432),ImgRegEN(5),ImgReg5IN(447 downto 432) );

	TriState00U : entity work.triStateBuffer generic map (16) port map(ImgReg1(447 downto 432),TriImgUpEn,ImgReg0IN(447 downto 432));
	TriState11U : entity work.triStateBuffer generic map (16) port map(ImgReg2(447 downto 432),TriImgUpEn,ImgReg1IN(447 downto 432));
	TriState22U : entity work.triStateBuffer generic map (16) port map(ImgReg3(447 downto 432),TriImgUpEn,ImgReg2IN(447 downto 432));
	TriState33U : entity work.triStateBuffer generic map (16) port map(ImgReg4(447 downto 432),TriImgUpEn,ImgReg3IN(447 downto 432));
	TriState44U : entity work.triStateBuffer generic map (16) port map(ImgReg5(447 downto 432),TriImgUpEn,ImgReg4IN(447 downto 432));
	
	

	reg11:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg0IN(447 downto 432)  , CLK , RST ,  ImgLastEn(0) , ImgReg0(447 downto 432) );
	reg22:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg1IN(447 downto 432)  , CLK , RST ,  ImgLastEn(1) , ImgReg1(447 downto 432) );
	reg33:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg2IN(447 downto 432)  , CLK , RST ,  ImgLastEn(2) , ImgReg2(447 downto 432) );
	reg44:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg3IN(447 downto 432)  , CLK , RST ,  ImgLastEn(3) , ImgReg3(447 downto 432) );
	reg55:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg4IN(447 downto 432)  , CLK , RST ,  ImgLastEn(4) , ImgReg4(447 downto 432) );
	reg66:entity work.nBitRegister generic map(16) PORT MAP ( ImgReg5IN(447 downto 432)  , CLK , RST ,  ImgLastEn(5) , ImgReg5(447 downto 432) );
	


END archRI;