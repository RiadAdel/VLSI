LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

Entity FC_adder is
    port( a,b,cin :in std_logic;
          f   :out std_logic;
          cout:out std_logic);
end entity FC_adder;

architecture a_FC_adder of FC_adder is
    begin
        f <= a xor b xor cin;
        cout <= (a and b) or (cin and (a xor b));
end a_FC_adder;