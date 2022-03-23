library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; -- we need a conversion to unsigned 

entity TBCSB is 
end TBCSB; 

architecture TEST of TBCSB is

  component LFSR16 
    port (CLK, RESET, LD, EN : in std_logic; 
          DIN : in std_logic_vector(15 downto 0); 
          PRN : out std_logic_vector(15 downto 0); 
          ZERO_D : out std_logic);
  end component;

  component carry_select_adder
    generic(NBIT: INTEGER := 6 );
    port ( x,y : in std_logic_vector (NBIT-1 downto 0);
           cin : in std_logic ;
           s : out std_logic_vector (NBIT-1 downto 0));
  end component;
  

  constant Period: time := 1 ns; -- Clock period (1 GHz)
  signal CLK : std_logic :='0';
  signal RESET,LD,EN,ZERO_D : std_logic;
  signal DIN, PRN : std_logic_vector(15 downto 0);

  signal A, B, S1, S2, S3 : std_logic_vector(5 downto 0);
  signal Ci : std_logic;

Begin

-- Instanciate the carry select block with rca structural
  UADDER1: carry_select_adder port map (A, B, Ci, S1);
  
-- Instanciate the carry select block with rca behavioral
  UADDER2: carry_select_adder port map (A, B, Ci, S2);

-- Forcing adder input to LFSR output
  Ci <= '0';
  A(0) <= PRN(0);
  A(5) <= PRN(2);
  A(3) <= PRN(4);
  A(1) <= PRN(6);
  A(4) <= PRN(8);
  A(2) <= PRN(10);

  B(0) <= PRN(15);
  B(5) <= PRN(13);
  B(3) <= PRN(11);
  B(1) <= PRN(9);
  B(4) <= PRN(7);
  B(2) <= PRN(5);

-- Instanciate the Unit Under Test (UUT)
  UUT: LFSR16 port map (CLK=>CLK, RESET=>RESET, LD=>LD, EN=>EN, 
                        DIN=>DIN,PRN=>PRN, ZERO_D=>ZERO_D);
-- Create the permanent Clock and the Reset pulse
  CLK <= not CLK after Period/2;
  RESET <= '1', '0' after Period;
-- Open file, make a load, and wait for a timeout in case of design error.
  STIMULUS1: process
  begin
    DIN <= "0000000000000001";
    EN <='1';
    LD <='1';
    wait for 2 * PERIOD;
    LD <='0';
    wait for (65600 * PERIOD);
  end process STIMULUS1;

end TEST;

configuration CSBTEST of TBCSB is
  for TEST
    for UADDER1: carry_select_adder
      use configuration WORK.CFG_CSB_BEHAVIORAL_RCA_STRUC;
    end for;
    for UADDER2: carry_select_adder
      use configuration WORK.CFG_CSB_BEHAVIORAL_RCA_BEH;
    end for;
  end for;
end CSBTEST;
