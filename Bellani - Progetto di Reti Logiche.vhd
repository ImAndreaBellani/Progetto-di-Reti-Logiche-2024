-- Component: project_reti_logiche
-- Last-checked : 23/05/2024
--
-- Type : sequenziale
-- VHDL-Type : structural/behavioral/data flow
-- 
--      Per la descrizione dettagliata della struttura interna e delle scelte progettuali
--      dietro al design del componente e dei suoi sotto-moduli si veda il paragrafo "2"
--      della relazione.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        i_k : in std_logic_vector(9 downto 0);
        
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arc of project_reti_logiche is
    component fsa is port (
        start : in std_logic;
        is_k_0 : in std_logic;
        is_data_0 : in std_logic;
        clock : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(3 downto 0)
    );
    end component;
    component signals_manager is port(
        input : in std_logic_vector(3 downto 0);
        
        rst_for_app : out std_logic;
        clock_for_app : out std_logic;

        rst_for_c : out std_logic;
        clock_for_c : out std_logic;
        set_to_31_for_c : out std_logic;
        
        rst_for_addr_calc : out std_logic;
        clock_for_addr_calc : out std_logic;
        dec_k_for_addr_calc : out std_logic;
        
        output_selector : out std_logic;
        
        o_mem_en : out std_logic;
        o_mem_we : out std_logic;
        o_done : out std_logic
    );
    end component;
    component register_for_app is port (
        input : in std_logic_vector(7 downto 0);
        rst : in std_logic;
        clock : in std_logic;

        output : out std_logic_vector(7 downto 0)
    );
    end component;
    component register_for_c is port (
        clock : in std_logic;
        set_to_31 : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(4 downto 0)
    );
    end component;
    component address_calculator is port (
        input : in std_logic_vector(15 downto 0);
        k : in std_logic_vector(9 downto 0);
        dec_k : in std_logic;
        clock : in std_logic;
        rst : in std_logic;

        output : out std_logic_vector(15 downto 0);
        k_counter : out std_logic_vector(9 downto 0)
    );
    end component;
    component zero_detector_8bit is port (
        a : in std_logic_vector(0 to 7);
        
        output : out std_logic
    );
    end component;
    component zero_detector_10bit is port (
        a : in std_logic_vector(0 to 9);
        
        output : out std_logic
    );
    end component;
    component mux_8bit is port (
        in0 : in std_logic_vector(7 downto 0);
        in1 : in std_logic_vector(7 downto 0);
        sel : in std_logic;
        
        output : out std_logic_vector(7 downto 0)
    );
    end component;
    
    -- signals from FSA:
    signal fsa_states : std_logic_vector(3 downto 0);
    
    -- signals from ZERO DETECTORs:
    signal is_k_0 : std_logic;
    signal is_data_0 : std_logic;
    
    -- signals from SIGNALS MANAGER :
    signal rst_for_app : std_logic;
    signal clock_for_app : std_logic;
    signal rst_for_c : std_logic;
    signal clock_for_c : std_logic;
    signal set_to_31_for_c : std_logic;
    signal rst_for_addr_calc : std_logic;
    signal clock_for_addr_calc : std_logic;
    signal dec_k_for_addr_calc : std_logic;
    signal output_selector : std_logic;
    
    -- signals from REGISTER FOR APP:
    signal output_app : std_logic_vector(7 downto 0);
    
    -- signals from REGISTER FOR C:
    signal output_c : std_logic_vector(4 downto 0);
    signal output_c_8bit : std_logic_vector(7 downto 0);
    
    -- signals from ADDRESS CALCULATOR:
    signal k_counter : std_logic_vector(9 downto 0);

    begin
        comp_FSA : fsa port map (
            start=>i_start,
            is_k_0=>is_k_0,
            is_data_0=>is_data_0,
            clock=>i_clk,
            rst=>i_rst,
            
            output=>fsa_states
        );
        
        comp_ZERO_DETECTOR_8bit : zero_detector_8bit port map (
            a=>i_mem_data,
            
            output=>is_data_0
        );
        
        comp_ZERO_DETECTOR_10bit : zero_detector_10bit port map (
            a=>k_counter,
            
            output=>is_k_0
        );
               
        comp_SIGNALS_MANAGER : signals_manager port map (
            input=>fsa_states,
            
            rst_for_app=>rst_for_app,
            clock_for_app=>clock_for_app,
    
            rst_for_c=>rst_for_c,
            clock_for_c=>clock_for_c,
            set_to_31_for_c=>set_to_31_for_c,
            
            rst_for_addr_calc=>rst_for_addr_calc,
            clock_for_addr_calc=>clock_for_addr_calc,
            dec_k_for_addr_calc=>dec_k_for_addr_calc,
            
            output_selector=>output_selector,
            
            o_mem_en=>o_mem_en,
            o_mem_we=>o_mem_we,
            o_done=>o_done
        );
        
        comp_REGISTER_FOR_APP : register_for_app port map (
            input=>i_mem_data,
            rst=>rst_for_app,
            clock=>clock_for_app,
    
            output=>output_app
        );
        
        comp_REGISTER_FOR_C : register_for_c port map (
            clock=>clock_for_c,
            set_to_31=>set_to_31_for_c,
            rst=>rst_for_c,
            
            output=>output_c
        );
        output_c_8bit<="000"&output_c;
        
        comp_ADDRESS_CALCULATOR : address_calculator port map (
            input=>i_add,
            k=>i_k,
            dec_k=>dec_k_for_addr_calc,
            clock=>clock_for_addr_calc,
            rst=>rst_for_addr_calc,
    
            output=>o_mem_addr,
            k_counter=>k_counter
        );
        
        comp_MUX : mux_8bit port map (
            in0=>output_app,
            in1=>output_c_8bit,
            sel=>output_selector,
            
            output=>o_mem_data
        );

    end project_reti_logiche_arc;
    
-- Component: fsa
-- Last-checked : 23/05/2024
--
-- Type : sequenziale
-- VHDL-Type : behavioral
-- Input :
--         start : std_logic ["i_start"]
--         is_k_0 : std_logic ['1' se "k_counter" di "address_calculator" è '0'; '0' altrimenti]
--         is_data_0 : std_logic ['1' se i_mem_data='0'; '0' altrimenti]
--         clock : std_logic [clock (interpretato sul fronte di salita)]
--         rst : std_logic [reset asincrono (attivo alto)]
-- Output :
--          output : std_logic(3 downto 0) [stato attuale della macchina]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsa is
    port (
        start : in std_logic;
        is_k_0 : in std_logic;
        is_data_0 : in std_logic;
        clock : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(3 downto 0)
    );
end fsa;

architecture fsa_arc of fsa is
     -- lo stato è internamente memorizzato come un segnale di tipo "S"
     -- una sua rappresentazione come "std_logic_vector(3 downto 0)" viene
     -- data in output al "signals_manager" (più pratico di gestire nel signals-manager
     -- un tipo diverso da "std_logic_vector"
     type S is (
                RESET, -- "0000"
                START_IF, -- "0001"
                READ_1, READ_2, -- "0010", "0011"
                DATA_IF, -- "0100"
                PREP_PROC_DEF_DATA, PROC_DEF_DATA, -- "0101", "0110"
                DEC_C, WRITE_APP_ON_MEM, -- "0111", "1000"
                DEC_K, WRITE_C_ON_MEM, NEXT_ADDR, -- "1001", "1010", "1011"
                DONE -- "1100"
        );
        
    signal curr_state : S;

    begin
        process (clock, rst)
            begin
                if (rst='1') then
                    output<="0000";
                    curr_state<=RESET;
                elsif (clock'event and clock='1') then
                    case curr_state is    
                        when RESET =>
                            if (start='1') then
                                curr_state<=START_IF;
                                output<="0001";
                            else
                                curr_state<=RESET;
                                output<="0000";
                            end if;
                        when START_IF =>
                            if (is_k_0='1') then
                                curr_state<=DONE;
                                output<="1100";
                            else
                                curr_state<=READ_1;
                                output<="0010";
                            end if;                            
                        when READ_1 =>
                            curr_state<=READ_2;
                            output<="0011";
                        when READ_2 =>
                            curr_state<=DATA_IF;
                            output<="0100";
                        when DATA_IF =>
                            if (is_data_0='0') then
                                curr_state<=PREP_PROC_DEF_DATA;
                                output<="0101";
                            else
                                curr_state<=DEC_C;
                                output<="0111";
                            end if;
                        when PREP_PROC_DEF_DATA =>
                            curr_state<=PROC_DEF_DATA;
                            output<="0110";
                        when PROC_DEF_DATA =>
                            curr_state<=DEC_K;
                            output<="1001";
                        when DEC_C =>
                            curr_state<=WRITE_APP_ON_MEM;
                            output<="1000";
                        when WRITE_C_ON_MEM =>
                            curr_state<=NEXT_ADDR;
                            output<="1011";
                        when DEC_K =>
                            curr_state<=WRITE_C_ON_MEM;
                            output<="1010";
                        when WRITE_APP_ON_MEM =>
                            curr_state<=DEC_K;
                            output<="1001";
                        when NEXT_ADDR =>
                            curr_state<=START_IF;
                            output<="0001";
                        when DONE =>
                            if (start='0') then
                                curr_state<=RESET;
                                output<="0000";
                            else
                                curr_state<=DONE;
                                output<="1100";
                            end if;
                        when others =>
                            curr_state<=RESET;
                            output<="0000";
                    end case;
                end if;
            end process;
end architecture;

-- Component: signals_manager
-- Last-checked : 22/05/2024
--
-- Type : combinatorio
-- VHDL-Type : structural/data flow
-- Input :
--         input : std_logic_vector(3 downto 0) [stato attuale dell'FSA]
-- Output :
--          ciascun output corrisponde a un segnale di controllo per gli altri componenti (sono tutti quelli del tipo "for_",
--          ad esempio "rst_for_c" comanderà "rst" di "register_for_c", l'unico che fa eccezione è "output_selector" il quale
--          piloterà l'ingresso "sel" di "mux_8bit") oppure per il modulo (nel caso, hanno lo stesso nome, ad esempio, "o_done").
-- Descrizione struttura interna:
--                                Per semplificare la realizzazione del componente, "input" viene dato in ingresso
--                                a un decoder e la logica combinatoria viene costruita unicamente sulle uscite del
--                                decoder. Ad esempio, "o_mem_we<=output_decoder(8) or output_decoder(10)" sarà '1'
--                                solo quando l'FSA è nello stato "8" oppure nello stato "10".

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity signals_manager is
    port(
        input : in std_logic_vector(3 downto 0);
        
        rst_for_app : out std_logic;
        clock_for_app : out std_logic;

        rst_for_c : out std_logic;
        clock_for_c : out std_logic;
        set_to_31_for_c : out std_logic;
        
        rst_for_addr_calc : out std_logic;
        clock_for_addr_calc : out std_logic;
        dec_k_for_addr_calc : out std_logic;
        
        output_selector : out std_logic;
        
        o_mem_en : out std_logic;
        o_mem_we : out std_logic;
        o_done : out std_logic   
    );
end signals_manager;

architecture signals_manager_arc of signals_manager is
    component decoder_4bit is port (
        input : in std_logic_vector(3 downto 0);
        output : out std_logic_vector(15 downto 0)
    );
    end component;

    signal output_decoder : std_logic_vector(15 downto 0);
    
    begin
        comp_decoder : decoder_4bit port map(input=>input, output=>output_decoder);
        
        rst_for_app<=output_decoder(0);
        clock_for_app<=output_decoder(6);

        rst_for_c<=output_decoder(0);
        clock_for_c<=output_decoder(6) or output_decoder(7);
        set_to_31_for_c<=output_decoder(5) or output_decoder(6);
        
        rst_for_addr_calc<=output_decoder(0);
        clock_for_addr_calc<=output_decoder(9) or output_decoder(11);
        dec_k_for_addr_calc<=output_decoder(6) or output_decoder(9) or output_decoder(8);
        
        output_selector<=output_decoder(10);
        
        o_mem_en<=output_decoder(2) or output_decoder(3) or output_decoder(8) or output_decoder(10) or output_decoder(4);
        o_mem_we<=output_decoder(8) or output_decoder(10);
        o_done<=output_decoder(12);
        
    end signals_manager_arc;

-- Component: decoder_4bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : behavioral
-- Input :
--         input : std_logic_vector(3 downto 0) [input del decoder]
-- Output :
--          output : std_logic_vector(15 downto 0) [output del decoder]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_4bit is
    port(
        input : in std_logic_vector(3 downto 0);
        
        output : out std_logic_vector(15 downto 0)
    );
end decoder_4bit;

architecture decoder_4bit_arc of decoder_4bit is
    begin
        process(input)
            begin
                if (input="0000") then
                    output<="0000000000000001";
                elsif (input="0001") then
                    output<="0000000000000010";
                elsif (input="0010") then
                    output<="0000000000000100";
                elsif (input="0011") then
                    output<="0000000000001000";
                elsif (input="0100") then
                    output<="0000000000010000";
                elsif (input="0101") then
                    output<="0000000000100000";
                elsif (input="0110") then
                    output<="0000000001000000";
                elsif (input="0111") then
                    output<="0000000010000000";
                elsif (input="1000") then
                    output<="0000000100000000";
                elsif (input="1001") then
                    output<="0000001000000000";
                elsif (input="1010") then
                    output<="0000010000000000";
                elsif (input="1011") then
                    output<="0000100000000000";
                elsif (input="1100") then
                    output<="0001000000000000";
                elsif (input="1101") then
                    output<="0010000000000000";
                elsif (input="1110") then
                    output<="0100000000000000"; 
                elsif (input="1111") then
                    output<="1000000000000000";      
                else
                    output<=(others=>'0');
                end if;
            end process;
    end decoder_4bit_arc;

-- Component: register_for_app
-- Last-checked : 19/03/2024
--
-- Type : sequenziale
-- VHDL-Type : behavioral
-- Input :
--         input : std_logic_vector(7 downto 0) ["dato" in memoria (non credibilità) se diverso da "0"]
--         rst : std_logic [reset asincrono (attivo alto)]
--         clock : std_logic [clock (interpretato sul fronte di salita)]
-- Output :
--          output : std_logic_vector(7 downto 0) [contenuto del registro]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_for_app is
    port (
        input : in std_logic_vector(7 downto 0);
        rst : in std_logic;
        clock : in std_logic;

        output : out std_logic_vector(7 downto 0)
    );
end register_for_app;

architecture register_for_app_arc of register_for_app is
    begin
        process(clock, rst, input)
            begin
                if (rst='1') then
                    output<= (others => '0');
                elsif (clock'event and clock='1' and input/="00000000") then
                      output<= input;
                end if;  
            end process;
    end register_for_app_arc;
    
-- Component: register_for_c
-- Last-checked : 19/03/2024
--
-- Type : sequenziale
-- VHDL-Type : behavioral
-- Input :
--         clock : std_logic [clock (interpretato sul fronte di salita)]
--         set_to_31 : std_logic [setta "11111" al prossimo fronte di salita del clock]
--         rst : std_logic [reset asincrono (attivo alto)]
-- Output :
--          output : std_logic_vector(4 downto 0) [si decrementa di '1' ad ogni ciclo di clock]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_for_c is
    port (
        clock : in std_logic;
        set_to_31 : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(4 downto 0)
    );
end entity;    
    
architecture register_for_c_arc of register_for_c is
    
    signal stored_value : std_logic_vector(4 downto 0);
    
    begin
       process(clock, rst, set_to_31)
            begin 
                if (rst='1') then
                    stored_value<=(others=>'0');
                    output<=(others=>'0');  
                elsif (clock='1' and clock'event) then
                    if (set_to_31='1') then
                        stored_value<=(others=>'1');
                        output<=(others=>'1'); 
                    else
                        if (stored_value/="00000") then
                            stored_value<=stored_value-"00001";
                            output<=stored_value-"00001";
                        end if;
                    end if;
                 end if;       
            end process; 
    end architecture;

-- Component: address_calculator
-- Last-checked : 19/03/2024
--
-- Type : sequenziale
-- VHDL-Type : structural/behavioral/data flow
-- Input :
--         input : std_logic_vector(15 downto 0) ["i_add"]
--         k : std_logic_vector(9 downto 0) ["i_k"]
--         dec_k : std_logic [se '1', "k_counter" verrà decrementato al prossimo fronte di salita del clock]
--         clock : std_logic [clock del componente (interpretato sul fronte di salita)]
--         rst : std_logic [rst asincrono (attivo alto) che setta "output=input" e "k_counter=k"]
-- Output :
--          output : std_logic_vector(15 downto 0) [indirizzo di memoria a/in cui leggere/scrivere]
--          k_counter : std_logic_vector(9 downto 0) [conta quanti valori devono ancora essere letti dalla memoria]
-- Descrizione struttura interna:
--                                "output" è il risultato della somma (unsigned) tra "input" e il contenuto di un registro
--                                (inizializzato a "0") che viene incrementato di "1" ad ogni ciclo di clock;
--                                "k_counter" è il risultato della sottrazione (unsigned) tra "k" e il contenuto di un
--                                registro (inizializzato a "0") che viene incrementato di "1" ad ogni ciclo di clock
--                                solo se dec_k='1'.

library IEEE;                   
use IEEE.STD_LOGIC_1164.ALL;    
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity address_calculator is
    port (
        input : in std_logic_vector(15 downto 0);
        k : in std_logic_vector(9 downto 0);
        dec_k : in std_logic;
        clock : in std_logic;
        rst : in std_logic;

        output : out std_logic_vector(15 downto 0);
        k_counter : out std_logic_vector(9 downto 0)
    );
end address_calculator;

architecture address_calculator_arc of address_calculator is
    component adder_16bit is port (
        a1 : in std_logic_vector(15 downto 0);
        a2 : in std_logic_vector(15 downto 0);
        
        output : out std_logic_vector(15 downto 0)
    );
    end component;  
    component subtractor_10bit is port (
        s1 : in std_logic_vector(9 downto 0);
        s2 : in std_logic_vector(9 downto 0);
            
        output : out std_logic_vector(9 downto 0)
    );
    end component;
    component reg_16bit is port (
        clock : in std_logic;
        rst : in std_logic;
            
        output : out std_logic_vector(15 downto 0)
    );
    end component;
    component reg_10bit is port (
        clock : in std_logic;
        rst : in std_logic;
            
        output : out std_logic_vector(9 downto 0)
    );
    end component;
    
    signal from_reg16_to_adder : std_logic_vector(15 downto 0);
    signal from_reg10_to_subtractor : std_logic_vector(9 downto 0);
    signal clock_for_reg_k : std_logic; 
    
    begin
        reg_addr : reg_16bit port map(clock=>clock, rst=>rst, output=>from_reg16_to_adder);
        adder : adder_16bit port map(a1=>input, a2=>from_reg16_to_adder, output=>output);
        clock_for_reg_k<=clock and dec_k;
        reg_k : reg_10bit port map(clock=>clock_for_reg_k, rst=>rst, output=>from_reg10_to_subtractor);
        subtractor : subtractor_10bit port map (s1=>k, s2=>from_reg10_to_subtractor, output=>k_counter);
    end architecture;

-- Component: adder_16bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : data flow
-- Input :
--         a1 : std_logic_vector(15 downto 0) [addendo 1]
--         a2 : std_logic_vector(15 downto 0) [addendo 2]
-- Output :
--          output : std_logic_vector(15 downto 0) [somma (unsigned) dei due addendi]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_16bit is
    port (
        a1 : in std_logic_vector(15 downto 0);
        a2 : in std_logic_vector(15 downto 0);
        
        output : out std_logic_vector(15 downto 0)
    );
end adder_16bit;

architecture adder_16bit_arc of adder_16bit is
    begin
        process (a1, a2)
            begin
                output<=a1 + a2;
            end process;
    end architecture;

-- Component: subtractor_10bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : behavioral/data flow
-- Input :
--         a1 : std_logic_vector(9 downto 0) [minuendo]
--         a2 : std_logic_vector(9 downto 0) [sottraendo]
-- Output :
--          output : std_logic_vector(9 downto 0) [differenza (unsigned) tra minuendo e sottraendo]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity subtractor_10bit is
    port (
        s1 : in std_logic_vector(9 downto 0);
        s2 : in std_logic_vector(9 downto 0);
        
        output : out std_logic_vector(9 downto 0)
    );
end subtractor_10bit;

architecture subtractor_10bit_arc of subtractor_10bit is
    begin
        process (s1, s2)
            begin
                if (s1>=s2) then
                    output<=s1 - s2;
                else
                    output<="0000000000";   
                end if;
            end process;
    end architecture;

-- Component: reg_16bit
-- Last-checked : 19/03/2024
--
-- Type : sequenziale
-- VHDL-Type : behavioral
-- Input :
--         clock : std_logic [clock (interpretato sul fronte di salita)]
--         rst : std_logic [reset asincrono (attivo alto)]
-- Output :
--          output : std_logic_vector(15 downto 0) [si incrementa di '1' ad ogni ciclo di clock (inizializzato a '0')]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_16bit is
    port (
        clock : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(15 downto 0)
    );
end reg_16bit;

architecture reg_16bit_arc of reg_16bit is
    signal content : std_logic_vector(15 downto 0);
    begin
        process (rst, clock)
            begin
                if (rst='1') then
                    content<=(others=>'0');
                    output<=(others=>'0');
                elsif (clock='1' and clock'event) then
                    content<=content+'1';
                    output<=content+'1';
                end if;        
            end process;
    end architecture;

-- Component: reg_10bit
-- Last-checked : 19/03/2024
--
-- Type : sequenziale
-- VHDL-Type : behavioral
-- Input :
--         clock : std_logic [clock (interpretato sul fronte di salita)]
--         rst : std_logic [reset asincrono (attivo alto)]
-- Output :
--          output : std_logic_vector(9 downto 0) [si incrementa di '1' ad ogni ciclo di clock (inizializzato a '0')]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_10bit is
    port (
        clock : in std_logic;
        rst : in std_logic;
        
        output : out std_logic_vector(9 downto 0)
    );
end reg_10bit;

architecture reg_10bit_arc of reg_10bit is
    signal content : std_logic_vector(9 downto 0);
    begin
        process (rst, clock)
            begin
                if (rst='1') then
                    content<=(others=>'0');
                    output<=(others=>'0');
                elsif (clock='1' and clock'event) then
                    content<=content+'1';
                    output<=content+'1';
                end if;        
            end process;
    end architecture;
    
-- Component: zero_detector_8bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : behavioral
-- Input :
--          a : std_logic_vector(0 to 7) [ingresso]
-- Output :
--          output : std_logic ['1' se a="00000000"; '0' altrimenti]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_detector_8bit is
    port(
        a : in std_logic_vector(0 to 7);
 
        output : out std_logic
    );
end zero_detector_8bit;

architecture zero_detector_8bit_arc of zero_detector_8bit is
    begin
        process(a)
            begin
                if (a="00000000") then
                  output<='1';
                else
                    output<='0';    
                end if;
            end process;
    end zero_detector_8bit_arc;
    
-- Component: zero_detector_10bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : behavioral
-- Input :
--          a : std_logic_vector(0 to 9) [ingresso]
-- Output :
--          output : std_logic ['1' se a="0000000000"; '0' altrimenti]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zero_detector_10bit is
    port(
        a : in std_logic_vector(0 to 9);
 
        output : out std_logic
    );
end zero_detector_10bit;

architecture zero_detector_10bit_arc of zero_detector_10bit is
    begin
        process(a)
            begin
                if (a="0000000000") then
                  output<='1';
                else
                    output<='0';    
                end if;
            end process;
    end zero_detector_10bit_arc;
    
-- Component: mux_8bit
-- Last-checked : 19/03/2024
--
-- Type : combinatorio
-- VHDL-Type : behavioral
-- Input :
--          in0 : std_logic_vector(7 downto 0) [ingresso "0"]
--          in1 : std_logic_vector(7 downto 0) [ingresso "1"]
--          sel : std_logic [selettore]
-- Output :
--          output : std_logic_vector(7 downto 0) ["in0" se sel='0'; "in1" altrimenti]

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_8bit is
    port (
        in0 : in std_logic_vector(7 downto 0);
        in1 : in std_logic_vector(7 downto 0);
        sel : in std_logic;
        
        output : out std_logic_vector(7 downto 0)
    );
end mux_8bit;

architecture mux_8bit_arc of mux_8bit is       
   begin
        process(in0, in1, sel)
            begin
                if (sel='0') then
                    output<=in0;
                else
                    output<=in1;
                end if;
            end process;       
    end mux_8bit_arc;