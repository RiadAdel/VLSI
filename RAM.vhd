library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
  port (
    CLK,W,R:in std_logic;
    address:in std_logic_vector(9 downto 0);
    data:inout std_logic_vector(447 downto 0);
    MFC:out std_logic
  ) ;
end RAM;
architecture archRAM of RAM is
    type ram_type is array( 0 to 2500) of std_logic_vector(15 downto 0);
    signal ram: ram_type;
    signal mfc_m:std_logic;
    signal cReset,cEnable:std_logic;
    signal cOutput:std_logic_vector(3 downto 0);
    component Counter is
        generic(n: integer := 16);
        port(
            enable:in std_logic;
            reset:in std_logic;
            clk:in std_logic;
            load:in std_logic;
            output:out std_logic_vector(n-1 downto 0);
            input:in std_logic_vector(n-1 downto 0));
    end component;

begin
    -- enable the register when w or r signal comes
    cEnable <= '1' when (((W =  '1') or (R = '1')))
    else '0';
    c1: Counter 
    generic map(4)
    port map(cEnable,cReset,CLK,'0',cOutput,"0001");

    -- MFC appears one clock after 8th clocks
    MFC <= mfc_m;
    mfc_m <= '1' when (cOutput = "0111" and CLK'event and CLK = '1')
    else '0' when   (CLK'event and CLK = '1');

    -- reset the counter when comes to 8 or a signal read or write
    cReset <= '1' when ((cOutput = "1000") or (W'event and W = '1') or (R'event and R = '1') )
    else '0';

    -- memory retrieve 28 pixel of data after 8 bits
    process(cOutput)
	variable k,j,adds:integer;
    begin
        k := -16;
        j := -1;
        if  (cOutput = "1000" and W = '1')then
            ram(to_integer(unsigned(address))) <= data;
        elsif  (cOutput = "1000" and R = '1')then
            loop1: for i in 0 to 27 loop
                k := k + 16;
                j := j + 16;
    			adds := i + to_integer(unsigned(address));
                data(j downto k) <= ram(adds);
		    end loop;
        end if ;
    end process;
end archRAM ;