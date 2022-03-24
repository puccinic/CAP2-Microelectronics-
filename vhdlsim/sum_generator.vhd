library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SUM_GENERATOR is
    generic (
        NBIT_PER_BLOCK: integer := 4;
        NBLOCKS:	integer := 8);
    port (
        A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
        B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
        Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
        S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end SUM_GENERATOR;


architecture STRUCTURAL of SUM_GENERATOR is

    component carry_select_adder
        generic(NBIT: INTEGER);
        port   (x,y : in std_logic_vector (NBIT-1 downto 0);
                cin : in std_logic ;
                s : out std_logic_vector (NBIT-1 downto 0));
    end component;
begin
    S_GEN: for I in 1 to NBLOCKS generate
        CSB : carry_select_adder
                generic map (NBIT => NBIT_PER_BLOCK) 
                port Map (x   => A(NBIT_PER_BLOCK*I - 1 downto NBIT_PER_BLOCK*(I-1)),
                          y   => B(NBIT_PER_BLOCK*I - 1 downto NBIT_PER_BLOCK*(I-1)),
                          cin => Ci(I-1),
                          s   => S(NBIT_PER_BLOCK*I - 1 downto NBIT_PER_BLOCK*(I-1))); 
    end generate;

end STRUCTURAL ;


configuration CFG_SUM_GENERATOR_STRUCTURAL of SUM_GENERATOR is
    for STRUCTURAL
        for S_GEN
            for all : carry_select_adder
                use configuration WORK.CFG_CSB_BEHAVIORAL_RCA_STRUC;
            end for;
        end for;
    end for;
end CFG_SUM_GENERATOR_STRUCTURAL;