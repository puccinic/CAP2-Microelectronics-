library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity BOOTHMUL is
    generic (numbit : integer);
    port    (A,B : in std_logic_vector(numbit - 1 downto 0);
             P   : out std_logic_vector(2*numbit - 1 downto 0));
end BOOTHMUL;


architecture SEMI_STRUCTURAL of BOOTHMUL is
    
    type mux_signals is array (numbit/2 - 1 downto 0) of std_logic_vector(2*numbit - 1 downto 0);
    type mux_sel_signal_arr is array (numbit/2 -1 downto 0) of std_logic_vector(2 downto 0);
    type adder_signals is array (numbit/2 - 2 downto 0) of std_logic_vector(2*numbit - 1 downto 0);

    signal muxA_inputs: mux_signals;
    signal muxS_inputs: mux_sel_signal_arr;
    signal muxO_outputs: mux_signals;
    signal adder_output: adder_signals;

    component RCA_GENERIC 
        generic (NBIT: INTEGER);
        port    (A, B : in  std_logic_vector(NBIT-1 downto 0);
                 Ci   : in  std_logic;
                 S    : out std_logic_vector(NBIT-1 downto 0);
                 Co   : out	std_logic);
    end component;

    component MUX_MULT
        generic(numbit : integer);
          port (A: in std_logic_vector(numbit - 1 downto 0);
                S: in std_logic_vector(2 downto 0);
                A4: out std_logic_vector(2 + numbit -1 downto 0);
                O: out std_logic_vector(2 + numbit -1 downto 0));
    end component;

begin
    
    muxA_inputs(0)(numbit -1 downto 0) <= A;

    MUXOX : for i in 0 to numbit/2 - 1 generate
        MUXO0 : if i = 0 generate
            muxS_inputs(i) <= B(1 downto 0) & '0';
            MUX_M0: MUX_MULT generic map (numbit + 2*i)
                                port map (A => muxA_inputs(i)(numbit + 2*i - 1 downto 0),
                                          S => muxS_inputs(i),
                                          A4 => muxA_inputs(i + 1)(numbit + 2*i + 2 - 1 downto 0),
                                          O => muxO_outputs(i)(numbit + 2*i + 2 - 1 downto 0));
        end generate MUXO0;
        MUXO1 : if i > 0 and  i /=  (numbit/2 - 1) generate
            muxS_inputs(i) <= B(1 + 2*i downto 2*i - 1);
            MUX_MX: MUX_MULT generic map (numbit + 2*i)
                                port map (A => muxA_inputs(i)(numbit + 2*i - 1 downto 0),
                                          S => muxS_inputs(i),
                                          A4 => muxA_inputs(i + 1)(numbit + 2*i + 2 - 1 downto 0),
                                          O => muxO_outputs(i)(numbit + 2*i + 2 - 1 downto 0));
        end generate MUXO1;

        MUXOD : if i =  (numbit/2 - 1) generate
            muxS_inputs(i) <= B(1 + 2*i downto 2*i - 1);
            MUX_MD: MUX_MULT generic map (numbit + 2*i)
                                port map (A => muxA_inputs(i)(numbit + 2*i - 1 downto 0),
                                          S => muxS_inputs(i),
                                          O => muxO_outputs(i)(numbit + 2*i + 2 - 1 downto 0));
        end generate MUXOD;

    end generate MUXOX; -- MUXO

    ADDX : for i in 1 to numbit/2 - 1 generate
        ADD0X : if i = 1 generate
            muxO_outputs(i-1)(numbit + 2*i + 2 - 1 downto numbit + 2*i) <= muxO_outputs(i-1)(numbit + 2*i - 1) & muxO_outputs(i-1)(numbit + 2*i - 1);
            ADDER: RCA_GENERIC generic map (NBIT => numbit + 2*i + 2)
                                  port map (A  => muxO_outputs(i)(numbit + 2*i + 2 - 1 downto 0),
                                            B  =>  muxO_outputs(i - 1)(numbit + 2*i +2 - 1 downto 0),
                                            Ci => '0',
                                            S  => adder_output(i - 1)(numbit + 2*i + 2 -1 downto 0));
        end generate ADD0X;
        ADD1X : if i > 1 generate
            adder_output(i - 2)(numbit + 2*i +2 -1 downto numbit + 2*i) <= adder_output(i - 2)(numbit + 2*i -1) & adder_output(i - 2)(numbit + 2*i -1);
            ADDER: RCA_GENERIC generic map (NBIT => numbit + 2*i + 2)
                                  port map (A  => muxO_outputs(i)(numbit + 2*i + 2 - 1 downto 0),
                                            B  => adder_output(i - 2)(numbit + 2*i +2 -1 downto 0),
                                            Ci => '0',
                                            S  => adder_output(i - 1)(numbit + 2*i + 2 -1 downto 0));
        end generate ADD1X;
    end generate ADDX; -- ADDX

    P <= adder_output(numbit/2 - 2);
end SEMI_STRUCTURAL; 