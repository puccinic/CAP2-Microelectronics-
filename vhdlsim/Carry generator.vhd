library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.Numeric_STD.all;

entity TB_CARRY_GENERATOR is 
end TB_CARRY_GENERATOR; 

architecture TEST of TB_CARRY_GENERATOR is


	component CARRY_GENERATOR is
		generic (
			N_bits :		integer := 32;
			bits_step: integer := 4);
		port (
			A :		in	std_logic_vector(N_bits-1 downto 0);
			B :		in	std_logic_vector(N_bits-1 downto 0);
			cin :	in	std_logic;
			cout :	out	std_logic_vector((N_bits/bits_step)-1 downto 0));
	end component;

	signal A_i  :   std_logic_vector(31 downto 0) := (others => '0');
	signal B_i  :   std_logic_vector(31 downto 0) := (others => '0');
	signal Cin_i:   std_logic:='1';
	signal Co_o :   std_logic_vector((32/4)-1 downto 0);
   
begin

  DUT:CARRY_GENERATOR
    port map(
      A => A_i,
      B => B_i,
      cin => Cin_i,
      cout => Co_o);

test: process
  variable temp :   integer :=1;
begin
   
  wait for 1 ns;

  A_i <= x"FFFFFFFF";
  B_i <= x"00000000";

  wait for 3 ns;
  Cin_i<= '0';
  A_i <= x"00000000";
  B_i <= x"00000000";

  for i in 0 to 31 loop
      temp := temp*2;
      B_i <= std_logic_vector(to_unsigned(temp, B_i'length));
      A_i <= std_logic_vector(to_unsigned(temp, A_i'length));
      wait for 3 ns;
  end loop;

  wait;

end process test;

end TEST;

configuration CFG_TB_CARRY_GENERATOR of TB_CARRY_GENERATOR is
	for TEST
		for DUT:CARRY_GENERATOR
			use configuration WORK.cfg_Carry_Generator;
		end for;
	end for;
end CFG_TB_CARRY_GENERATOR;

