library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_for_app_test is
end register_for_app_test;

-- non mi spiego molto ma funziona da dio, capire perché (24/2/2024)
-- tutto a posto (06/03/2024)
-- controllo finale (07/05/2024)

architecture register_for_app_test_arc of register_for_app_test is
    component register_for_app is
        port (
            input : in std_logic_vector(7 downto 0);
            rst : in std_logic;
            clock : in std_logic;

            output : out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal clock : std_logic:='1';
    signal input_test : std_logic_vector(7 downto 0);    
    signal force_zero_test : std_logic;
    signal output_test : std_logic_vector(7 downto 0);
    
    constant clock_period : time:=20 ns;
    
    begin
       
        my_register_for_app: register_for_app port map(input=>input_test, rst=>force_zero_test, clock=>clock, output=>output_test);
        
        clock <= not clock after clock_period/2;
        
        process
            begin
                input_test<="00000000";
                force_zero_test<='1';
                wait for 2 ns;
                assert output_test="00000000" report "failed after first force zero";
                wait for 2 ns;
                
                force_zero_test<='0';
                wait for 2 ns;
                assert output_test="00000000" report "failed after zero mem";
                wait for 2 ns;
                
                input_test<="10101011";
                wait until rising_edge(clock);wait for 1 ns;
                assert output_test="10101011" report "failed after not zero mem";
                wait for 2 ns;
                wait until rising_edge(clock);
                wait for 2 ns;
                assert output_test="10101011" report "failed after one clock of zero mem";
                wait for 2 ns;
                               
                input_test<="00000000";
                wait until rising_edge(clock);
                wait for 2 ns;
                assert output_test="10101011" report "failed after test of maintening the previous value";
                wait for 2 ns;
                
                force_zero_test<='1';
                wait until rising_edge(clock);
                wait for 2 ns;
                assert output_test="00000000" report "failed after last reset";
                
                assert false report "PASSATO" severity failure;
                wait;    
            end process;
    end register_for_app_test_arc;