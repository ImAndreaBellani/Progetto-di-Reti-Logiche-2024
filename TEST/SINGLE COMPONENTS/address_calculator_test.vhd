library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity address_calculator_test is
end address_calculator_test;


architecture address_calculator_test_arc of address_calculator_test is
    component address_calculator is port (
        input : in std_logic_vector(15 downto 0);
        k : in std_logic_vector(9 downto 0);
        dec_k : in std_logic;
        clock : in std_logic;
        rst : in std_logic;

        k_counter : out std_logic_vector(9 downto 0);
        output : out std_logic_vector(15 downto 0)
    );
    end component;
    
    signal input_test : std_logic_vector(15 downto 0):="1010101010101010";
    signal k_test : std_logic_vector(9 downto 0):="0000001111";
    signal dec_k_test : std_logic;
    signal clock_test : std_logic:='1';
    signal rst_test : std_logic;

    signal k_counter_test : std_logic_vector(9 downto 0);
    signal output_test : std_logic_vector(15 downto 0);
    
    constant clock_period : time:=20 ns;
    
    begin
       
        my_address_calculator: address_calculator port map(
            input=>input_test,
            k=>k_test,
            dec_k=>dec_k_test,
            clock=>clock_test,
            rst=>rst_test,
            k_counter=>k_counter_test,
            output=>output_test     
        );
        
        clock_test <= not clock_test after clock_period/2;
        
        process
            begin
                rst_test<='1';
                dec_k_test<='0';
                wait for 3 ns;
                assert output_test="1010101010101010" report "failed first reset for mem_addr";
                assert k_counter_test="0000001111" report "failed first reset for k";
                wait for 3 ns;
                rst_test<='0';
                wait until rising_edge(clock_test);
                wait for 3 ns;
                assert output_test="1010101010101011" report "failed first inc of mem_addr";
                assert k_counter_test="0000001111" report "failed first period of not dec k";
                wait until rising_edge(clock_test);
                wait for 3 ns;
                assert output_test="1010101010101100" report "failed second inc of mem_addr";
                assert k_counter_test="0000001111" report "failed second period of not dec k";
                wait until rising_edge(clock_test);
                wait for 3 ns;
                assert output_test="1010101010101101" report "failed third inc of mem_addr";
                assert k_counter_test="0000001111" report "failed third period of not dec k";
                wait for 3 ns;
                wait until rising_edge(clock_test);
                dec_k_test<='1';
                wait for 3 ns;
                assert output_test="1010101010101110" report "failed fourth inc of mem_addr";
                assert k_counter_test="0000001110" report "failed first period of dec k";
                
                wait for 3 ns;
                rst_test<='1';
                wait for 3 ns;
                assert k_counter_test="0000001111" report "failed spurious reset of k";
                assert output_test="1010101010101010" report "failed spurious reset of mem_addr";
                wait for 3 ns;
                rst_test<='0';
                wait until rising_edge(clock_test);
                wait for 3 ns;
                assert k_counter_test="0000001110" report "failed dec of k after spurious reset";
                assert output_test="1010101010101011" report "failed inc of mem_addr after spurious reset";          
                
                for j in 0 to 31 loop
                    wait until rising_edge(clock_test);
                end loop;                
                wait for 3 ns;
                assert k_counter_test="0000000000" report "failed dec of k after falling down to zero";
                assert output_test="1010101011001011" report "failed inc of mem_addr after 32 periods";          
                
                assert false report "PASSATO" severity failure;
                wait;
            end process;
    end architecture;