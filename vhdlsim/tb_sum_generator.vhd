library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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

	constant Period: time := 10 ns; 
	signal A, B, S : std_logic_vector(31 downto 0);
	signal Ci : std_logic_vector(7 downto 0);

begin
	
	DUT: SUM_GENERATOR
			port map (A,B,Ci,S);


	
	STIMULUS: process
		-- Source code taken from https://vhdlwhiz.com/random-numbers/ 
		-- function generates random values for std_logic_vector
		variable seed1, seed2 : integer := 999; 
		impure function rand_slv(len : integer) return std_logic_vector is
			variable r : real;
			variable slv : std_logic_vector(len - 1 downto 0);
		
	  	begin
			for i in slv'range loop
		  		uniform(seed1, seed2, r);
		  		if r > 0.5 then
			  		slv(i) := '1';
		  		else
			  		slv(i) := '0';
		  		end if ;
			end loop;
		return slv;
	  	end function;
	begin
		identifier : for i in 0 to 10 loop
			A <= rand_slv(len => 32);
			B <= rand_slv(len => 32);
			Ci <= rand_slv(len => 8);
			wait for period;
			A <= rand_slv(len => 32);
			B <= rand_slv(len => 32);
			Ci <= rand_slv(len => 8);
			wait for (period*2);
		end loop ; -- identifier
		wait;
	end process STIMULUS;

end TEST;

configuration SUM_GENERATORTEST of TBSUM_GENERATOR is
  for TEST
    for all: SUM_GENERATOR
      use configuration WORK.CFG_SUM_GENERATOR_STRUCTURAL;
    end for;
  end for;
end SUM_GENERATORTEST;
