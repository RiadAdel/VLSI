library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Counter is
	generic(n: integer := 16);
	port(
		enable:in std_logic;
		reset:in std_logic;
		clk:in std_logic;
		load:in std_logic;
		output:out std_logic_vector(n-1 downto 0);
		input:in std_logic_vector(n-1 downto 0));
end Counter;

architecture CounterImplementation of Counter is
	Component my_nadder is
		Generic ( n : integer := 8);
		PORT(a, b : in std_logic_vector(n-1 downto 0);
			cin : in std_logic;
			s : out std_logic_vector(n-1 downto 0);
			cout : out std_logic);
	end component;
	signal toOutput: std_logic_vector( n-1 downto 0);
	signal addResult: std_logic_vector( n-1 downto 0);
	signal one: std_logic_vector ( n-1 downto 0);
	signal zero: std_logic_vector (n-2 downto 0);
	signal carry: std_logic;
	Begin
	A1:my_nadder
	generic map (n)
	port map    (toOutput,one,'0',addResult);
	zero <= (others => '0');
	one <= zero &'1'  ;
	process(enable,input,reset,clk,load)
	begin
		if (reset = '1') then
			toOutput <= (others => '0');
		elsif (load = '1' and enable = '1') then
			toOutput <=input;
		elsif (clk = '1' and clk'event) then
			if(enable = '1') then
				toOutput <= addResult;
			end if;
		end if ;
	end process;
	output <= toOutput;
end CounterImplementation;