LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use work.constants.all;


ENTITY Main IS
	PORT(rst , cl , dmaStartSignal , start : IN std_logic;
		 done:out std_logic);
END ENTITY Main;

ARCHITECTURE vlsi OF Main IS	

signal counterOutF : std_logic_vector(3 downto 0);
signal counterOutI : std_logic_vector(3 downto 0);

-- state decleration-------  
signal next_state:state;
signal current_state:state;

-----Filter address signals--------
signal FilterAddressEN:std_logic;
signal FilterAddressIN: std_logic_vector(12 downto 0);
signal FilterAddressOut: std_logic_vector(12 downto 0);
-------ImgAddReg signals--------
signal ImgAddRegEN:std_logic;
signal ImgAddRegIN: std_logic_vector(12 downto 0);
signal ImgAddRegOut: std_logic_vector(12 downto 0);
-------tristate counter signals--------

signal TriStateCounterEN:std_logic;
signal TriStateCounterOUT: std_logic_vector(12 downto 0);
-------ImgAddACKTri signals-----------
signal ImgAddACKTriEN:std_logic;
signal zero: std_logic_vector(11 downto 0);
signal ImgAddACKTriIN: std_logic_vector(12 downto 0);
-------Filter memory ------
signal WriteF:std_logic;
signal ReadF:std_logic;
signal AddressF: std_logic_vector(12 downto 0);
signal DataFIn: std_logic_vector( 15 downto 0 );
signal DataFOut: std_logic_vector( 399 downto 0 );

signal ACKF:std_logic;
-------Img memory -------
signal WriteI:std_logic;
signal ReadI:std_logic;
signal AddressI:std_logic_vector(12 downto 0);
signal DataIIn: std_logic_vector( 15 downto 0 );
signal DataIOut: std_logic_vector( 447 downto 0 );


signal ACKI:std_logic;

------#of layers---------
signal NoOfLayers:std_logic_vector(15 downto 0);
------------------------
signal LayerInfoOut:std_logic_vector(15 downto 0);
signal ImgWidthOut:std_logic_vector(15 downto 0);
-------------------------
signal Wmin1: std_logic_vector(4 downto 0);
signal WidthSquareOut :  std_logic_vector(9 downto 0);
signal CounterWidthSquare :  std_logic_vector(1 downto 0);
signal ACKWidth : std_logic;
----------------------------------
signal Bias0: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias1: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias2: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias3: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias4: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias5: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias6: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal Bias7: STD_LOGIC_VECTOR(15 DOWNTO 0);
------------------------------------------
signal IndicatorF : std_logic_vector(0 downto 0);
signal Filter2 : STD_LOGIC_VECTOR(399 DOWNTO 0);
signal Filter1 : STD_LOGIC_VECTOR(399 DOWNTO 0);
------------------------------------------------
signal IndicatorI : std_logic_vector(0 downto 0);
------------------------------------------------
signal ImgCounterOuput: std_logic_vector(2 downto 0);
signal OutputImg0 :  std_logic_vector(447 downto 0 );
signal OutputImg1 :  std_logic_vector(447 downto 0 );
signal OutputImg2 :  std_logic_vector(447 downto 0 );
signal OutputImg3 :  std_logic_vector(447 downto 0 );
signal OutputImg4 :  std_logic_vector(447 downto 0 );
signal OutputImg5 :  std_logic_vector(447 downto 0 );
signal ImgRegEN : std_logic_vector(5 downto 0);

--------------------------------------------------
signal ACKC : std_logic;
signal ConvOuput : std_logic_vector(15 downto 0); 
-------------------------------------------------
signal ReadAddressCounter: std_logic_vector(12 downto 0); 
signal ShiftLeftCounterOutput:  std_logic_vector(4 downto 0) ;
signal ShiftCounterRst:std_logic;
signal RealOutputCounter:   std_logic_vector(12 downto 0);
-----------------------------------------------------
signal OutputCounterLoad:   std_logic_vector(12 downto 0);
signal Q : std_logic ;
signal NumOfFilters :std_logic_vector(3 downto 0 ); 
signal NumOfHeight:std_logic_vector(4 downto 0 );
signal X :  std_logic ;
signal Y :   std_logic ;
signal K :   std_logic ;

--------------------------------------------------------
signal B : std_logic;
signal L : std_logic;
signal D : std_logic;
signal ImgAddRST : std_logic;

signal CNDepthoutput :  std_logic_vector( 3 downto 0);
signal CNLayersoutput:  std_logic_vector(1 downto 0);

signal ReadSave : std_logic;
signal WriteSave: std_logic;
signal SaveAckLatch :std_logic;
signal DepthGreatZero :std_logic;

signal SwitchMEM : std_logic;
signal CLK : std_logic;

BEGIN
---conditions---




CLK<= cl and start ;
SwitchMEM<= '1' when current_state = WRITE_IMG_WIDTH  and ACKI = '1'  else '0';

FilterAddressEN <= '1' when ((current_state = RI and ACKF = '1' ) or (current_state = RL and ACKF = '1' )
 or (current_state = conv_calc_ReadImg_ReadBias  and ACKF = '1' )
or ((current_state = conv_ReadImg_ReadFilter and ACKF = '1') or ((current_state = CONV) AND (IndicatorF = "0") and ACKF = '1'))  ) else '0';

TriStateCounterEN <= '1' when ((current_state = RI and ACKF = '1' ) or (current_state = RL and ACKF = '1' )) else '0';
ImgAddRegEN <= '1' when (current_state = RL and ACKI = '1' ) or (((current_state = Pool_Cal_ReadImg) or (current_state =Pool_Read_Img ) or (current_state=conv_calc_ReadImg_ReadBias)
	or (current_state =conv_ReadImg_ReadFilter ) or (current_state = conv_ReadImg)) and ACKI = '1') 
	or ((current_state = CONV) and (IndicatorI = "0") and (ACKI = '1') )  else '0';


ImgAddACKTriEN<='1' when (current_state = RL ) else '0';
zero <= (others=>'0');
ImgAddACKTriIN <= zero&ACKI;

ShiftCounterRst<= '1' when (rst='1') or (current_state = SHUP) or ((current_state =CONV) and (B = '0')) else '0'; 
B<= '0' when ShiftLeftCounterOutput ="11100"  else '1';
-----------------








FilterMem:entity work.RAM generic map (X=>25) port map (rst,clk,WriteF,ReadF,AddressF , DataFIn , DataFOut , ACKF ,counterOutF );

ImgMem:entity work.RAM generic map (X=>28) port map (rst,clk,WriteI,ReadI ,AddressI , DataIIn , DataIOut ,ACKI ,counterOutI);
--ImgMem:entity work.memoryDMA port map (rst,AddressI,DataIIn,,,);

ReadInf:entity work.ReadInfoState  port map (clk,current_state , rst , ACKF , FilterAddressOut , DataFOut(15 downto 0) , NoOfLayers , AddressF );


FilterAddress:entity work.nBitRegister generic map (n=>13) port map ( FilterAddressIN , clk , rst ,FilterAddressEN , FilterAddressOut );
AdderTryState:entity work.triStateBuffer generic map (n=>13) port map ( TriStateCounterOUT , TriStateCounterEN,FilterAddressIN );
FilterAddressAdder:entity work.my_nadder generic map (n=>13) port map ( FilterAddressOut ,"0000000000000" ,'1', TriStateCounterOUT);


ImgAddRST<='1' when rst='1' or current_state=CHECKS else '0';

ImgAddReg:entity work.nBitRegister generic map (n=>13) port map ( ImgAddRegIN , clk , ImgAddRST ,ImgAddRegEN , ImgAddRegOut );
ImgAddACKTri:entity work.triStateBuffer generic map (n=>13) port map ( ImgAddACKTriIN, ImgAddACKTriEN, ImgAddRegIN );
--error done
ReadLayerInfo:entity work.ReadLayerInfo port map (DataFOut(15 downto 0 ),DataIOut(15 downto 0 ),FilterAddressOut,ImgAddRegOut , clk , rst ,ACKF,ACKI,current_state,LayerInfoOut,ImgWidthOut,AddressF,AddressI);


ClacInfo:entity work.CalculateInfo port map (WidthSquareOut,CounterWidthSquare,LayerInfoOut,clk,rst,current_state , ACKWidth , ACKI ,Wmin1);

RBias:entity work.ReadBias port map (current_state,DataFOut,FilterAddressOut,AddressF,FilterAddressIN,clk,rst,LayerInfoOut,Bias0,Bias1,Bias2,Bias3,Bias4,Bias5,Bias6,Bias7 , ACKF);

Rfilter:entity work.ReadFilter port map (current_state,LayerInfoOut ,CNDepthoutput ,NumOfHeight  ,DataFOut ,FilterAddressOut ,LayerInfoOut(14) , clk , rst , Q , ACKF , IndicatorF ,AddressF,FilterAddressIN ,Filter1 , Filter2 );


RImg : entity work.ReadImage port map (WriteI, current_state , clk , rst , ACKI ,ImgAddRegOut, ImgWidthOut ,  DataIOut ,OutputImg0 , OutputImg1 , OutputImg2,OutputImg3,OutputImg4,OutputImg5,ImgCounterOuput,AddressI,ImgAddRegIN , IndicatorI , ImgRegEN);

Sconv : entity work.Convolution port map (current_state , clk , rst ,Q, ACKC ,LayerInfoOut, ImgAddRegOut ,OutputImg0(79 downto 0) , OutputImg1(79 downto 0) , OutputImg2(79 downto 0),OutputImg3(79 downto 0),OutputImg4(79 downto 0),Filter1 , Filter2,ConvOuput);


Ssave : entity work.saveState port map (DataIOut(15 downto 0) , ConvOuput ,Bias0,Bias1,Bias2,Bias3,Bias4,Bias5,Bias6,Bias7 , CNDepthoutput ,NumOfFilters , rst,current_state , clk , AddressI,RealOutputCounter ,DataIIn , ShiftLeftCounterOutput , ShiftCounterRst);


Istate: entity work.ImageState port map (current_state, WidthSquareOut ,RealOutputCounter, OutputCounterLoad  , ShiftLeftCounterOutput , LayerInfoOut , clk , rst , Q  , NumOfFilters , NumOfHeight , X , Y , K);


ChState: entity work.StateChecks port map (current_state ,NoOfLayers, LayerInfoOut , clk , rst , L , D , CNDepthoutput , CNLayersoutput );



Owidth : entity work.outWidthState port map (current_state , LayerInfoOut  ,  AddressI ,DataIIn    );

--------------------------

-- get the next state circuit--
state_decode_proc: process(current_state,ACKF,ACKWidth  , ACKI,clk , ImgCounterOuput , ACKC ,SaveAckLatch , X , B,Y,K , D,LayerInfoOut , L )
BEGIN

	case current_state is 
		when RI =>
			if (ACKF'EVENT AND ACKF = '1') then 
			next_state<= RL;
			end if ;
		when RL=>
			  if (clk'EVENT AND clk = '0')  then
				if ACKF = '1' then
					if DataFOut(15) = '0' then  
						next_state<= conv_calc_ReadImg_ReadBias;
					else 	next_state<= Pool_Cal_ReadImg;
					end if;
				end if;
			end if;

		when Pool_Cal_ReadImg=>
			if (ACKI'EVENT AND ACKI = '1') then 
			next_state<= Pool_Read_Img;
			end if ;
		-- error done
		when Pool_Read_Img=>
			if  (ImgCounterOuput = "100") then 
					if (ACKI'EVENT AND ACKI = '1') then
						next_state<= CONV;
					end if ;
			end if ;

		when conv_calc_ReadImg_ReadBias=>
			if (ACKF'EVENT AND ACKF = '1') then 
			   next_state<=conv_ReadImg_ReadFilter;
			end if ;
		when conv_ReadImg_ReadFilter=>
			if (ACKF'EVENT AND ACKF = '1') then 
			   next_state<=conv_ReadImg;
			end if ;
		-- error done
		when conv_ReadImg=>
			if (ImgCounterOuput = "100") then 
						if (ACKI'EVENT AND ACKI = '1') then
							next_state<=CONV;
						end if ;
			end if ;

		when CONV=>
			if (ACKC'EVENT AND ACKC = '1') then   --- will change before i read img or filter
			   next_state<=SAVE;
			end if ;
		-- error done
		when SAVE=>
			if(WriteI = '1') then   --- will change before i read img or filter
				if (ACKI'EVENT AND ACKI = '1') then
					next_state<=IMGSTAT;
				end if ;
			end if ;
			
		
		when IMGSTAT=>
			if X='0' then   --- will change before i read img or filter
			   next_state<=SHLEFT;
			else  next_state<=CONV;
			end if ;
		

		when SHLEFT=>
			if B='0' and Y='0' then   --- will change before i read img or filter
			   next_state<=SHUP;
			elsif B='0' and Y='1' then
			  next_state<=CONV;
			else   next_state<=SHLEFT;
			end if ;

		when SHUP=>
			if K='0' then   --- will change before i read img or filter
			   next_state<=CHECKS;
			else next_state<=CONV;

			end if ;
	

		when CHECKS=>
			if L = '0' then
				next_state<=FIN;
			elsif D='0' then   --- will change before i read img or filter
			   next_state<=WRITE_IMG_WIDTH;
			elsif D='1'and LayerInfoOut(15) = '0'  then
			next_state<=conv_ReadImg;
			else
			next_state<=Pool_Read_Img;
			end if ;

		 when WRITE_IMG_WIDTH=>
			if (ACKI'EVENT AND ACKI = '1') then 
			   next_state<=RL;
			end if ;
		 when FIN=>
			
	
			
	
	end case;
end process ;
	
--end of circuit---

-- update state circuit --
state_proc: process(clk , rst)
begin
	if rst = '1' then
		current_state<=RI;
	elsif clk'event and clk='1' then
		current_state<=next_state;
	end if ;
end process;
-- end of circuit--

--output of process circuit--

DepthGreatZero<= not (CNDepthoutput(0) and CNDepthoutput(1) and CNDepthoutput(2) and  CNDepthoutput(3));


--error done
process (current_state,ACKI,CLK)
	begin
	if (current_state=SAVE) and (ACKI = '1' ) then
		if CLK'event and CLK = '0' then
			SaveAckLatch <= '1';
		end if;
	elsif (current_state=IMGSTAT or current_state = CONV) then
		SaveAckLatch <= '0';
	end if;
	end process;



---SaveAckLatch<= '1'  when  ((current_state=SAVE) and (ACKI = '1' ) and ( clk'event and clk='0')) else '0' when  (current_state=IMGSTAT or current_state = CONV) ;

ReadSave<= '1' when ( (current_state=SAVE) and (DepthGreatZero = '1' ) and (WriteSave = '0')   ) else '0'; 

WriteSave<= '1'  when ((current_state=SAVE) and (CNDepthoutput = "0000" )) or ( (current_state=SAVE) and (SaveAckLatch = '1')) else '0' ;

output_proc : process(current_state,IndicatorF,IndicatorI , ReadSave , WriteSave)
begin
	case current_state is
		when RI=>
			ReadF<= '1';
			ReadI<='0';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when RL=>
			ReadF<='1';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when Pool_Cal_ReadImg=>
			ReadF<='0';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when Pool_Read_Img=>
			ReadF<='0';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when conv_calc_ReadImg_ReadBias=>
			ReadF<='1';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when conv_ReadImg_ReadFilter=>
		        ReadF<='1';
		      --ReadF<=not IndicatorF(0);
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when conv_ReadImg=>
		        ReadF<='0';
			ReadI<= '1';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when  CONV=>
			ReadF<=not IndicatorF(0);
			ReadI<=not IndicatorI(0);
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when SAVE=>
			ReadF<='0';
			ReadI<=ReadSave;
			WriteF<='0';
			WriteI<=WriteSave;
			done <= '0';

		when IMGSTAT=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when SHLEFT=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when SHUP=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';
			done <= '0';

		when CHECKS=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';
			done <= '0';
		when WRITE_IMG_WIDTH=>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='1';
			done <= '0';
		when FIN =>
			ReadF<='0';
			ReadI<= '0';
			WriteF<='0';
			WriteI<='0';
			done <= '1';


			

	end case;
end process;


END vlsi;