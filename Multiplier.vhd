LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

Entity Multiplier is
   generic(n:integer :=10);
    port( A,B :in std_logic_vector(n-1 downto 0);
          F  :out std_logic_vector(n+n-1 downto 0)
	);
end entity Multiplier;

architecture Flow of Multiplier is

constant BigN : Integer := n+n;   -- number of Bits assigned as integer part

type outs is array(0 to BigN-1) of std_logic_vector(BigN-1 downto 0);
    signal addout : outs;
    signal op2 : outs;

signal op1 :std_logic_vector(BigN-1 downto 0);
signal Z :std_logic_vector(BigN-1 downto 0) := (others => '0');
signal O :std_logic_vector(BigN-1 downto 0) := (others => '1');
signal NewA : std_logic_vector(BigN-1 downto 0);
signal NewB : std_logic_vector(BigN-1 downto 0);

begin

NewA <= Z(n-1 downto 0) & A(n-1 downto 0) when A(n-1) = '0' else O(n-1 downto 0) & A(n-1 downto 0);
NewB <= Z(n-1 downto 0) & B(n-1 downto 0) when B(n-1) = '0' else O(n-1 downto 0) & B(n-1 downto 0);

-- n - IntBits = start of the Integer part
op1 <= (others => '0') when NewB(0) = '0'  Else NewA;

loop1: FOR i in 0 to BigN-2 Generate  
	op2(i) <= (others => '0') when NewB(i + 1) = '0' Else NewA(BigN - i - 2 downto 0) & Z(i downto 0);
end Generate;  


f0:entity work.FC_nadder generic map(n+n) PORT MAP( op1 , op2(0) ,'0' , addout(0));
loop3: FOR i in 1 to BigN-2 Generate
        fx:entity work.FC_nadder generic map(n+n) PORT MAP (addout(i-1) , op2(i) , '0' , addout(i));
end Generate;  

F <= addout(BigN-2);
end Flow;