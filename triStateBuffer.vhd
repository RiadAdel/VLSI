LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY triStateBuffer IS
	GENERIC ( n : integer := 16);
	PORT(	D : IN std_logic_vector(n-1 downto 0);
		EN : IN std_logic;
		F : OUT std_logic_vector(n-1 downto 0));
END ENTITY triStateBuffer;

ARCHITECTURE triBuffer OF triStateBuffer IS	
BEGIN 
	PROCESS(D,EN)
	BEGIN
		IF EN  = '0' THEN 
			F <= (OTHERS=>'Z');
		ELSE F <= D;
		END IF;
	END PROCESS;
END triBuffer;
