LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY nBitRegister IS
	generic( n : integer := 16);
	PORT(	D: IN std_logic_vector(n-1 downto 0);	
		CLK,RST,EN : IN std_logic;
		Q : OUT std_logic_vector(n-1 downto 0));
END ENTITY nBitRegister;

ARCHITECTURE Data_flow OF nBitRegister IS	
BEGIN 
	PROCESS(CLK,RST,EN)
	BEGIN
		IF RST='1' THEN 
			Q <= (OTHERS=>'0');
		ELSIF (CLK'EVENT AND CLK = '1') THEN
			IF EN = '1' THEN 
				Q<=D;
			END IF;
		END IF;
	END PROCESS;
END Data_flow;