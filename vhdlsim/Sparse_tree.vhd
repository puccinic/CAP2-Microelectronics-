library ieee;
use ieee.std_logic_1164.all;

entity sparseTree is

  generic (nBits : integer := 32;
           step  : integer := 4
           );

  port (A    : in  std_logic_vector(nBits-1 downto 0);
        B    : in  std_logic_vector(nBits-1 downto 0);
        cin  : in  std_logic;
        cout : out std_logic_vector(nBits/step-1 downto 0)
        );

end entity;

architecture structural of sparseTree is

  -- defines the tree levels
  constant nRow           : integer := 6;
  -- defines a matrix of signals
  type Signal_matrix is array (nRow-1 downto 0) of std_logic_vector(nBits-1 downto 0);
  signal pSignal, gSignal : Signal_matrix;

  component pgNetwork is

    generic (nBits : integer := 32
             );
    port (A   : in  std_logic_vector(nBits-1 downto 0);
          B   : in  std_logic_vector(nBits-1 downto 0);
          cin : in  std_logic;
          P   : out std_logic_vector(nBits-1 downto 0);
          G   : out std_logic_vector(nBits-1 downto 0)
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

  -- declares the pg network and uses the firs row of p and g signals as exit of the pg network
  my_pgNetwork : pgNetwork generic map (nBits => nBits)
    port map (A   => A,
              B   => B,
              cin => cin,
              P   => pSignal(0),
              G   => gSignal(0)
              );

  G0 : for line in 1 to nRow-1 generate

    G1 : for i in 0 to nBits-1 generate

      -- starts to generate the first part of PG and G blocks 
      G2 : if (line <= 2) generate

        -- if here is needded a PG or a G block
        G3 : if ((i+1)mod(2**line) = 0) generate

                                        -- if it is a G block generates it
          G4 : if (i < 2**line) generate

            m_blockG : G_block port map (Pik   => pSignal(line-1)(i),
                                        Gik   => gSignal(line-1)(i),
                                        Gk_1j => gSignal(line-1)(i - 2**(line-1)),
                                        Gij   => gSignal(line)(i)
                                        );

          end generate;

                                        -- if it is a PG block generates it
          G5 : if (i >= 2**line) generate

            m_blockPG : PG_block port map (Pik   => pSignal(line-1)(i),
                                          Gik   => gSignal(line-1)(i),
                                          Gk_1j => gSignal(line-1)(i - (2**(line-1))),
                                          Pk_1j => pSignal(line-1)(i - (2**(line-1))),
                                          Gij   => gSignal(line)(i),
                                          Pij   => pSignal(line)(i)
                                          );

          end generate;
        end generate;
      end generate;

      -- starts to generate the second part of PG and G blocks 
      G6 : if (line > 2) generate

        G7 : if((i mod (2**line)) >= 2**(line-1) and (i mod (2**line)) < 2**line) and (((i+1) mod step) = 0) generate

                                        -- if it is a G block
          G8 : if (i < 2**line) generate

            m1_blockG : G_block port map (Pik   => pSignal(line-1)(i),
                                         Gik   => gSignal(line-1)(i),
                                         Gk_1j => gSignal(line-1)((i/2**(line-1))*2**(line-1) - 1),
                                         Gij   => gSignal(line)(i)
                                         );

          end generate;

                                        -- if it is a PG block
          G9 : if (i >= 2**line) generate

            m1_blockPG : PG_block port map (Pik   => pSignal(line-1)(i),
                                           Gik   => gSignal(line-1)(i),
                                           Gk_1j => gSignal(line-1)((i/2**(line-1))*2**(line-1)-1),
                                           Pk_1j => pSignal(line-1)((i/2**(line-1))*2**(line-1)-1),
                                           Gij   => gSignal(line)(i),
                                           Pij   => pSignal(line)(i)
                                           );

          end generate;
        end generate;

        -- if the signal has to be brought to the next level, connects the current row with the previous
        G10 : if((i mod (2**line)) < 2**(line-1) and (i mod (2**line)) >= 0) and (((i+1) mod step) = 0) generate

          pSignal(line)(i) <= pSignal(line-1)(i);
          gSignal(line)(i) <= gSignal(line-1)(i);
        end generate;
      end generate;

      -- if it is the last row, connects the G signals to the carries output                    
      G11 : if (line = nRow-1) generate

        G12 : if ((i+1) mod step) = 0 generate

          cout(i/step) <= gSignal(line)(i);
        end generate;
      end generate;
    end generate;
  end generate;

end architecture;

configuration cfg_sparseTree of sparseTree is
  for structural
    for my_pgNetwork : pgNetwork
      use configuration work.cfg_pgNetwork;
    end for;
  end for;
end configuration;
