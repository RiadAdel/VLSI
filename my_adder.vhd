Library ieee;
Use ieee.std_logic_1164.all;
 
------------------------------------------------------
ENTITY my_adder IS

PORT(a, b, cin : in std_logic;
	s, cout : out std_logic);
END my_adder;

------------------------------------------------
Architecture a_my_adder of my_adder is

	begin

		s <= a XOR b XOR cin;
		cout <= ((a XOR b) AND cin) OR (a AND b);

end a_my_adder;