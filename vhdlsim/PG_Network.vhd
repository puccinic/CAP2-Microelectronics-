library ieee;
use ieee.std_logic_1164.all;

entity pgNetwork is
  generic (N_bits : integer := 32);
  port (  A : in std_logic_vector(N_bits-1 downto 0);
          B : in std_logic_vector(N_bits-1 downto 0);
			 cin : in std_logic;
          P : out std_logic_vector(N_bits-1 downto 0);
          G : out std_logic_vector(N_bits-1 downto 0)
        );

end entity;

architecture behavioral of pgNetwork is

  begin

    proc : process (A, B) begin

      for i in 0 to N_bits-1 loop

		  if ( i = 0 ) then --first bit must consider carry in 
        P(i) <= a(i) xor b(i);
			  G(i) <= (a(i) and b(i)) or (a(i) and cin) or (b(i) and cin);
			else
				P(i) <= A(i) xor B(i);
				G(i) <= A(i) and B(i);
			end if;

      end loop;
    end process;
end architecture;

configuration cfg_pgNetwork of pgNetwork is
  for behavioral
  end for;
end configuration;
