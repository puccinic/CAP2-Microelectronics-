library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity carry_select_adder is
generic(NBIT: INTEGER := 4 );
port ( x,y : in std_logic_vector (NBIT-1 downto 0);
       cin : in std_logic ;
       s : out std_logic_vector (NBIT-1 downto 0));
end carry_select_adder;

architecture behavioral of carry_select_adder is

component RCA_GENERIC 
generic(NBIT: INTEGER);
port ( A, B : In std_logic_vector(NBIT-1 downto 0);
       Ci : In std_logic;
       S : Out std_logic_vector(NBIT-1 downto 0);
       Co : Out	std_logic);
end component;

signal s1,s2: std_logic_vector(NBIT-1 downto 0);
signal co1,co2: std_logic;
begin

rca1: RCA_GENERIC generic map(NBIT => NBIT)
          port    map(A  => x,
                      B  => y,
                      Ci => '0',
                      S  => s1);

rca2: RCA_GENERIC generic map(NBIT => NBIT)
          port    map(A  => x,
                      B  => y,
                      Ci => '1',
                      S  => s2);

 s <= s1 when cin = '0' else s2;

end behavioral;
