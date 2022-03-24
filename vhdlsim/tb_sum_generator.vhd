library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity TBSUM_GENERATOR is 
end TBSUM_GENERATOR; 

architecture TEST of TBSUM_GENERATOR is


	component SUM_GENERATOR is
		generic (
			NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
		port (
			A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
			S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
	end component;
	
	signal A, B, S : std_logic_vector(31 downto 0);
	signal Ci : std_logic_vector(7 downto 0);
	constant period: time := 10 ns;
begin
	
	DUT: SUM_GENERATOR
			port map (A,B,Ci,S);
	STIMULUS: process 
	begin
		A <= std_logic_vector(to_unsigned(15,32));
		B <= std_logic_vector(to_unsigned(13,32));
		Ci <= std_logic_vector(to_unsigned(0,8));
		wait for period;
		A <= std_logic_vector(to_unsigned(56,32));
		B <= std_logic_vector(to_unsigned(5,32));
		Ci <= std_logic_vector(to_unsigned(0,8));
		wait for (period*2);
	end process STIMULUS;

end TEST;

configuration SUM_GENERATORTEST of TBSUM_GENERATOR is
  for TEST
    for all: SUM_GENERATOR
      use configuration WORK.CFG_SUM_GENERATOR_STRUCTURAL;
    end for;
  end for;
end SUM_GENERATORTEST;
