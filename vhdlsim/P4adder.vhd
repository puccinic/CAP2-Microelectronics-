library IEEE;
use IEEE.std_logic_1164.all;

entity P4_adder is
    generic(
        NBIT:           integer := 32;
        NBLOCKS:        integer := 8;
        NBIT_PER_BLOCK: integer := 4);
    port(
        A:          in  std_logic_vector(NBIT-1 downto 0);
        B:          in  std_logic_vector(NBIT-1 downto 0);
        Cin:        in  std_logic;
        S:          out std_logic_vector(NBIT-1 downto 0);
        Cout:       out std_logic);
end P4_adder;

architecture STRUCTURAL of P4_adder is
    component SUM_GENERATOR
        generic(NBIT_PER_BLOCK: integer;
                NBLOCKS:        integer);
        port (
            A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
            B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
            Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
            S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
        end component;

    component Carry_Generator
        generic (N_bits:    integer;
                bits_step:  integer);
        port (  A:            in  std_logic_vector(N_bits-1 downto 0);
                B:            in  std_logic_vector(N_bits-1 downto 0);
                cin:          in  std_logic;
                cout:         out std_logic_vector(N_bits/bits_step-1 downto 0));
    end component;

    signal C_generate: std_logic_vector (NBLOCKS -1 downto 0);
    signal C_in_SG: std_logic_vector (NBLOCKS -1 downto 0);

begin
    Cout <= C_generate(NBLOCKS -1);
    C_in_SG <= C_generate(NBLOCKS-2 downto 0) & Cin;

    Carry_Generator_i: Carry_Generator generic map (N_bits => NBIT, bits_step => NBIT_PER_BLOCK)
        port map(   A =>    A,
                    B =>    B,
                    cin =>  Cin,
                    cout => C_generate);
    
    Sum_Generator_i: SUM_GENERATOR generic map (NBIT_PER_BLOCK => NBIT_PER_BLOCK, NBLOCKS => NBLOCKS)
        port map(   A =>        A,
                    B =>        B,
                    Ci=>        C_in_SG,
                    S =>        S);
    


end STRUCTURAL;

configuration CFG_P4adder_STRUCTURAL of P4_adder is
    for STRUCTURAL
        for Carry_Generator_i: Carry_Generator 
            use configuration work.cfg_Carry_Generator;
        end for;

        for Sum_Generator_i: SUM_GENERATOR 
        use configuration work.CFG_SUM_GENERATOR_STRUCTURAL;
        end for;
    end for;
end configuration CFG_P4adder_STRUCTURAL;

