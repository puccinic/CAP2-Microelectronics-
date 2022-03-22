library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity carry_select_adder is
port ( x : in std_logic_vector (3 downto 0);
       y : in std_logic_vector (3 downto 0);
       cin : in std_logic ;
	   s : out std_logic_vector (3 downto 0);
       co : out std_logic );
end carry_select_adder;

architecture behavioral of carry_select_adder

component rca
port ( A:	In	std_logic_vector(3 downto 0);
		B:	In	std_logic_vector(3 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(3 downto 0);
		Co:	Out	std_logic);
end component;
component mux21_generic
port (A, B : in  std_logic_vector(3 downto 0);
        SEL  : in  std_logic;
        Y    : out std_logic_vector(3 downto 0);
end component;

signal A,B,s1,s2: std_logic_vector(3 downto 0);
signal co1,co2: std_logic;
begin

rca1: rca port map(x,y,'0',s1,co1);
rca2: rca port map(x,y,'1',s2,co2);

mux1: mux21 port map(s1,s2,cin,s);


end behavioral;
