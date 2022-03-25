library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BOOTHMUL is
    generic (numbit : integer);
    port    (A,B : in std_logic_vector(numbit - 1 downto 0);
             P   : out std_logic_vector(numbit - 1 downto 0));
end BOOTHMUL;



architecture SEMI_STRUCTURAL of BOOTHMUL is

    component RCA_GENERIC 
        generic (NBIT: INTEGER);
        port    (A, B : In  std_logic_vector(NBIT-1 downto 0);
                 Ci   : In  std_logic;
                 S    : Out std_logic_vector(NBIT-1 downto 0);
                 Co   : Out	std_logic);
    end component;

begin
    

end SEMI_STRUCTURAL; 