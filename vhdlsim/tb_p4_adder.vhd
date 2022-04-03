library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.Numeric_STD.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture TEST of TB_P4_ADDER is
	
	-- P4 component declaration
	component P4_ADDER is
		generic (
			NBIT :		integer := 32);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :		out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic);
	end component;
	
	signal A : std_logic_vector(31 downto 0) := (others => '0');
	signal B : std_logic_vector(31 downto 0) := (others => '0');
	signal cin : std_logic := '0';
	signal cout : std_logic;
	signal S : std_logic_vector(31 downto 0);

	begin
	uut: P4_Adder PORT MAP (
		A => A,
		B => B,
		cin => cin,
		S => S,
		Cout => cout
	  );

 stim_proc: process
	variable temp : integer := 1;
begin		
	wait for 3 ns;
	cin<='1';
	A <= x"FFFFFFFF";
	B <= x"00000000";
  
	wait for 3 ns;
	Cin<= '0';
	A <= x"00000000";
	B <= x"00000000";
	
	for i in 0 to 31 loop
		temp := temp*2;
		B <= std_logic_vector(to_unsigned(temp, B'length));
		A <= std_logic_vector(to_unsigned(temp, A'length));
		wait for 3 ns;
	end loop;

	temp := 15;
	B <= std_logic_vector(to_unsigned(temp, B'length));
	A <= x"0F0F0F0F";
	wait for 3 ns;

	for i in 0 to 31 loop
		temp := temp*2;
		B <= std_logic_vector(to_unsigned(temp, B'length));
		--Cin <= not cin;
		wait for 3 ns;
	end loop;

	wait;
 end process;
	
end TEST;

