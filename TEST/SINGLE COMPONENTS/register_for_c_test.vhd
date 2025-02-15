library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_for_c_test is
end register_for_c_test;

architecture register_for_c_test_arc of register_for_c_test is
    component register_for_c is
        port (
            clock : in std_logic;
            set_to_31 : in std_logic;
            rst : in std_logic;
            
            output : out std_logic_vector(4 downto 0)
        );
    end component;
    
    signal clock : std_logic:='1';
    signal dec_test : std_logic;
    signal real_dec_test : std_logic;
    
    signal rst_test : std_logic;
    signal force_zero_test : std_logic;
    
    signal output_test : std_logic_vector(4 downto 0);
    
    constant clock_period : time:=13 ns;
    
    begin
        dec_test<=(clock and real_dec_test);
       
        my_register_for_c: register_for_c port map(clock => dec_test, set_to_31 => rst_test, rst=>force_zero_test, output=>output_test);
        
        clock <= not clock after clock_period/2;
        
        process
            begin
                real_dec_test<='0';
                rst_test<='0';
                force_zero_test<='1';
                wait for 2 ns;
                assert output_test="00000" report "failed first reset";
                wait for 2 ns;
                real_dec_test<='1';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="00000" report "failed to maintain reset";
                wait for 2 ns;
                real_dec_test<='1';
                force_zero_test<='0';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="00000" report "failed to maintain 0";
                wait for 2 ns;
                rst_test<='1';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="11111" report "failed to set 31";
                wait for 2 ns;
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="11111" report "failed to maintain 31";
                wait for 2 ns; 
                rst_test<='0';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="11110" report "failed first dec";
                wait for 2 ns;
                
                for j in 0 to 28 loop
                    wait until rising_edge(dec_test);
                end loop;
                 wait for 2 ns; 
                assert output_test="00001" report "failed to fall down to 1";
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="00000" report "failed to dec 1 to 0";
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="00000" report "failed to not dec 0";
                wait for 2 ns;
                
                rst_test<='1';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="11111" report "failed to set 31 (second time)";
                wait for 2 ns;
                rst_test<='0';
                
                for j in 0 to 10 loop
                    wait until rising_edge(dec_test);
                end loop;
                
                wait for 2 ns;
                assert output_test="10100" report "failed to fall down of 11";
                wait for 2 ns;
                rst_test<='1';
                wait until rising_edge(dec_test);wait for 2 ns;
                assert output_test="11111" report "failed to set 31 after fall down";
                wait for 2 ns;
                rst_test<='0';
                
                for j in 0 to 2 loop
                    wait until rising_edge(dec_test);
                end loop;
                wait for 2 ns;
                
                assert output_test="11100" report "failed to fall down of 2";
                wait for 2 ns;
                force_zero_test<='1';
                wait for 2 ns;
                assert output_test="00000" report "failed spurious forze zero after fall down";
                
                assert false report "PASSATO" severity failure;
                wait;    
            end process;
    end register_for_c_test_arc;