-- OK 12/05/2024

library ieee;
use ieee.std_logic_1164.all;

entity fsa_test is
end fsa_test;

architecture fsa_test_arc of fsa_test is
    component fsa is
        port (
            start : in std_logic;
            is_k_0 : in std_logic;
            is_data_0 : in std_logic;
            clock : in std_logic;
            rst : in std_logic;
            
            output : out std_logic_vector(3 downto 0)
        );
    end component;

    constant clock_period : time := 10 ns;  -- 100 MHz

    signal start_test, is_k_0_test, is_data_0_test : std_logic;
    signal output_test : std_logic_vector(3 downto 0);
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';

begin
    my_fsa: fsa port map (
        start=>start_test, is_k_0=>is_k_0_test, is_data_0=>is_data_0_test,
        clock=>clk,
        rst=>rst,
        output=>output_test
    );

    clk <= not clk after clock_period / 2;
    
    stim_proc: process
    begin
        -- FIRST ROUND : through "1011" and coming back to "0001"
        -- SECOND ROUND : through "0011" and passing to "0101"
        -- THIRD ROUND : mixed of FIRST and SECOND round with asynchronous resets
        
        is_k_0_test<='0';
        is_data_0_test<='0';
        start_test<='0';
        wait for 0.5 ns;
        assert output_test="0000" report "failed test initial step";
        wait for 50 ns;
        assert output_test="0000" report "failed test maintaineing reset status";
        wait for 10 ns;
        start_test<='1';
        is_k_0_test<='0';
        wait until rising_edge(clk);
        wait for 3.5 ns;
        assert output_test="0000" report "failed test maintaineing reset status with input changes";
        wait for 2 ns;
        rst<='0';
        is_data_0_test<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (FIRST ROUND)";        
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1011" report "failed test passing from 1001 to 1011 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0010" report "failed test passing from 1011 to 0010 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0100" report "failed test passing from 0010 to 0100 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0101" report "failed test passing from 0100 to 0101 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1100" report "failed test passing from 0101 to 1100 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 1100 to 0110 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (FIRST ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1011" report "failed test passing from 1001 to 1011 (FIRST ROUND)";
        
        rst<='1';
        wait for 8 ps;
        rst<='0';
        is_data_0_test<='1';
        wait until rising_edge(clk);
        wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0011" report "failed test passing from 1001 to 0011 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1010" report "failed test passing from 0011 to 1010 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0100" report "failed test passing from 1010 to 0100 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0101" report "failed test passing from 0100 to 0101 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1100" report "failed test passing from 0101 to 1100 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        is_k_0_test<='1';
        assert output_test="0110" report "failed test passing from 1100 to 0110 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0111" report "failed test passing from 0110 to 0111 (SECOND ROUND)";
        start_test<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0000" report "failed test passing from 0111 to 0000 (SECOND ROUND)";
        start_test<='1';
        is_k_0_test<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0011" report "failed test passing from 1001 to 0011 (SECOND ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        
        rst<='1';
        wait for 8 ps;
        rst<='0';
        is_data_0_test<='0';
        wait until rising_edge(clk);
        wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1011" report "failed test passing from 1001 to 1011 (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='1';
        is_data_0_test<='1';
        wait for 3.5 ns;
        assert output_test="0000" report "failed first asyn reset (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0011" report "failed test passing from 1001 to 0011 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1010" report "failed test passing from 0011 to 1010 (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='1';
        is_data_0_test<='0';
        wait for 3.5 ns;
        assert output_test="0000" report "failed second asyn reset (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0001" report "failed test passing from 0110 to 0001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1000" report "failed test passing from 0001 to 1000 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1001" report "failed test passing from 1000 to 1001 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="1011" report "failed test passing from 1001 to 1011 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0010" report "failed test passing from 1011 to 0010 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0100" report "failed test passing from 0010 to 0100 (THIRD ROUND)";
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0101" report "failed test passing from 0100 to 0101 (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='1';
        wait for 3.5 ns;
        assert output_test="0000" report "failed third asyn reset (THIRD ROUND)";
        wait for 3.5 ns;
        rst<='0';
        wait until rising_edge(clk);wait for 3.5 ns;
        assert output_test="0110" report "failed test passing from 0000 to 0110 (THIRD ROUND)";
        
        assert false report "PASSATO" severity failure;
        wait;
    end process;
end;