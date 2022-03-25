library ieee; 
use ieee.std_logic_1164.all;

entity Carry_Generator is

  generic (N_bits : integer := 32;
           bits_step  : integer := 4
           );

  port (A    : in  std_logic_vector(N_bits-1 downto 0);
        B    : in  std_logic_vector(N_bits-1 downto 0);
        cin  : in  std_logic;
        cout : out std_logic_vector(N_bits/bits_step-1 downto 0)
        );

end entity;

architecture structural of Carry_Generator is

  constant nRow: integer := 6; -- the number of levels the tree
  type mySignal_t is array (nRow-1 downto 0) of std_logic_vector(N_bits-1 downto 0); -- create the matrix for interconections of the blocks
  signal pSignal, gSignal : mySignal_t;

  component pgNetwork is

    generic (N_bits : integer := 32
             );
    port (A   : in  std_logic_vector(N_bits-1 downto 0);
          B   : in  std_logic_vector(N_bits-1 downto 0);
          cin : in  std_logic;
          P   : out std_logic_vector(N_bits-1 downto 0);
          G   : out std_logic_vector(N_bits-1 downto 0)
          );
  end component;

  component PG_block is

    port (Pik   : in  std_logic;
          Gik   : in  std_logic;
          Gk_1j : in  std_logic;
          Pk_1j : in  std_logic;
          Gij   : out std_logic;
          Pij   : out std_logic
          );
	end component;

  component G_block is

    port (Pik   : in  std_logic;
          Gik   : in  std_logic;
          Gk_1j : in  std_logic;
          Gij   : out std_logic
          );
  end component;
   
begin

  pgNetwork_i : pgNetwork generic map (N_bits => N_bits)
    port map (A   => A,
              B   => B,
              cin => cin,
              P   => pSignal(0),
              G   => gSignal(0)
              );  -- The first row of the matrix signals are connected to the output signals of the pgNetwork

  Rows : for row in 1 to nRow-1 generate -- iterates for each row from 1 to 5

    BitCell : for i in 0 to N_bits -1 generate -- iterates for each bit
 
      Row12 : if (row <= 3) generate -- take the first 3 rows that behaves simiraly

        Block_power2 : if ((i+1) mod(2**row) = 0) generate -- checks if the cell (i) is a multiple of power 2 of number of row

          first_G : if (i  < 2**row) generate  -- if less than power of two is a G block

            G_block_i : G_block port map (Pik   => pSignal(row-1)(i),
                                        Gik   => gSignal(row-1)(i),
                                        Gk_1j => gSignal(row-1)(i - 2**(row-1)),
                                        Gij   => gSignal(row)(i)
                                        );

          end generate;

          PG_blocks : if (i >= 2**row) generate -- if greater or equal than power of two is a G block

            PG_blocki : PG_block port map (Pik   => pSignal(row-1)(i),
                                          Gik   => gSignal(row-1)(i),
                                          Gk_1j => gSignal(row-1)(i - (2**(row-1))),
                                          Pk_1j => pSignal(row-1)(i - (2**(row-1))),
                                          Gij   => gSignal(row)(i),
                                          Pij   => pSignal(row)(i)
                                          );

          end generate;
        end generate;

        Row3 : if ( (row = 3) and ( (i mod 8) <= 4 ) and ( (i+1) mod bits_step = 0)) generate -- make vertical interconectiones for the row 3
          pSignal(row)(i) <= pSignal(row-1)(i);
          gSignal(row)(i) <= gSignal(row-1)(i);
        end generate;

      end generate;

      Last2rows : if (row > 3) generate -- other logic for the last 2 rows

        Block2_power2 : if((i mod (2**row)) >= 2**(row-1)) and (((i+1) mod bits_step) = 0) generate -- check if the cell (i) belongs to the range of blocks and if are multiple of 4

          Gblocks : if (i < 2**row) generate -- if less than power of two is a G block

            G_block_i1 : G_block port map (Pik   => pSignal(row-1)(i),
                                         Gik   => gSignal(row-1)(i),
                                         Gk_1j => gSignal(row-1)( (i/2**(row-1)) *2**(row-1) - 1),
                                         Gij   => gSignal(row)(i)
                                         );

          end generate;

          pgBlocks : if (i >= 2**row) generate -- if greater or equal than power of two is a G block

            PG_blocki1 : PG_block port map (Pik   => pSignal(row-1)(i),
                                           Gik   => gSignal(row-1)(i),
                                           Gk_1j => gSignal(row-1)((i/2**(row-1))*2**(row-1)-1),
                                           Pk_1j => pSignal(row-1)((i/2**(row-1))*2**(row-1)-1),
                                           Gij   => gSignal(row)(i),
                                           Pij   => pSignal(row)(i)
                                           );
   
          end generate;
        end generate;

        Vertical_Int : if (((i mod (2**row)) <= 2**(row-1)) and (((i+1) mod bits_step) = 0)) generate -- checks if a vertical interconnection has to be done

          pSignal(row)(i) <= pSignal(row-1)(i);
          gSignal(row)(i) <= gSignal(row-1)(i);
        end generate;
      end generate;

      Out_Int : if (row = nRow-1) and (((i+1) mod bits_step) = 0) generate --checks if a vertical interconnection has to be done to the output 

        cout(i/bits_step) <= gSignal(row)(i);

      end generate;
    end generate;
  end generate;

end architecture;

configuration cfg_Carry_Generator of Carry_Generator is
  for structural
    for pgNetwork_i : pgNetwork
      use configuration work.cfg_pgNetwork;
		end for;
	end for;
end configuration;