library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity MUX_MULT is
  generic(numbit : integer);
  port (A: in std_logic_vector(numbit - 1 downto 0);
        S: in std_logic_vector(2 downto 0);
        A4: out std_logic_vector(2 + numbit -1 downto 0); 
        O: out std_logic_vector(2 + numbit -1 downto 0));
end MUX_MULT;



architecture BEHAVIORAL of MUX_MULT is
    signal Ax1, Ax2, A_neg, Ax2_neg: std_logic_vector(2 + numbit -1 downto 0);
begin
    Ax1 <=  A(numbit-1) & A(numbit-1) & A;
    Ax2 <= Ax1(numbit downto 0) & '0';
    A_neg <= (not Ax1) + 1;
    Ax2_neg <= A_neg(numbit  downto 0) & '0';
    
    with S select O <= 
    (others => '0') when "111",
    Ax1 when "001",
    Ax1 when "010",
    Ax2 when "011",
    Ax2_neg when "100",
    A_neg when "101",
    A_neg when "110",
    (others => '0') when others;

    A4 <= Ax2(numbit downto 0) & '0';
end BEHAVIORAL ; -- BEHAVIORAL