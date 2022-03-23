library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity RCA_GENERIC is 
	generic (DRCAS : 	Time := 0 ns;
	         DRCAC : 	Time := 0 ns;
           NBIT : INTEGER := 4);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT-1 downto 0);
		Co:	Out	std_logic);
end RCA_GENERIC; 

architecture STRUCTURAL of RCA_GENERIC is

  signal STMP : std_logic_vector(NBIT-1 downto 0);
  signal CTMP : std_logic_vector(NBIT downto 0);

  component FA 
  generic (DFAS : 	Time := 0 ns;
           DFAC : 	Time := 0 ns);
  Port ( A:	In	std_logic;
	 B:	In	std_logic;
	 Ci:	In	std_logic;
	 S:	Out	std_logic;
	 Co:	Out	std_logic);
  end component; 

begin

  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(NBIT);
  
  ADDER1: for I in 1 to NBIT generate
    FAI : FA 
	  generic map (DFAS => DRCAS, DFAC => DRCAC) 
	  Port Map (A(I-1), B(I-1), CTMP(I-1), STMP(I-1), CTMP(I)); 
  end generate;

end STRUCTURAL;


architecture BEHAVIORAL of RCA_GENERIC is
   signal CAUX : std_logic_vector(NBIT downto 0);
begin

 CAUX <= (('0' & A) +('0' & B )+ ("000000" & Ci) );
 Co <= CAUX(NBIT) after DRCAC;
 S  <= CAUX(NBIT-1 downto 0) after DRCAS;
end BEHAVIORAL;

configuration CFG_RCA_GEN_STRUCTURAL of RCA_GENERIC is
  for STRUCTURAL 
    for ADDER1
      for all : FA
        use configuration WORK.CFG_FA_BEHAVIORAL;
      end for;
    end for;
  end for;
end CFG_RCA_GEN_STRUCTURAL;

configuration CFG_RCA_GEN_BEHAVIORAL of RCA is
 for BEHAVIORAL 
 end for;
end CFG_RCA_GEN_BEHAVIORAL;
