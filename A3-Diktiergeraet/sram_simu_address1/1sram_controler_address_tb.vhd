-------------------------------------------------------------------------------
-- Title      : Testbench for design "sram_controler_address"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sram_controler_address_tb.vhd
-- Author     : Timo Wottka  <timow@twLaptop>
-- Company    : 
-- Created    : 2023-11-08
-- Last update: 2023-11-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-11-08  1.0      timow	Created
-------------------------------------------------------------------------------

library ieee;
library std_developerskit;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std_developerskit.std_iopak.all;
use work.sram_controler_pack.all;

-------------------------------------------------------------------------------

entity sram_controler_address_tb is

end entity sram_controler_address_tb;

-------------------------------------------------------------------------------

architecture tb of sram_controler_address_tb is

  -- component ports
  signal clk_i : std_ulogic := '1';
  signal reset_n_i : std_ulogic := '1';
  signal fsm_we_i : std_ulogic;
  signal fsm_re_i : std_ulogic;
  signal fsm_start_addr_i : std_ulogic_vector(18 downto 0);
  signal state_i : FSM_T;
  signal srctr_end_addr_plus1_o : std_ulogic_vector(18 downto 0);
  signal srctr_addr_reg_o : std_ulogic_vector(18 downto 0);

  -- clock
  signal stop_sim : boolean := false; -- to stop clock-signal at end of simulation to terminate simulation automatically

begin -- architecture tb

  -- component instantiation
  DUT : entity work.sram_controler_address
    port map(
      clk_i => clk_i,
      reset_n_i => reset_n_i,
      fsm_we_i => fsm_we_i,
      fsm_re_i => fsm_re_i,
      fsm_start_addr_i => fsm_start_addr_i,
      state_i => state_i,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
      srctr_addr_reg_o => srctr_addr_reg_o);

  -- clock generation
  -- purpose: generate clock signal
  -- type   : combinational
  -- inputs : 
  -- outputs: clk
  clk_gen_p : process is
  begin -- process clk_gen_p
    wait for 10 ns;
    clk_i <= not clk_i;
    if stop_sim then
      wait;
    end if;
  end process clk_gen_p;

  -- reset generation
  reset_p : process
  begin -- process reset_p
    wait;
  end process reset_p;
  -- waveform generation
  WaveGen_Proc : process
    procedure read(constant start_adress : in std_ulogic_vector(18 downto 0)) is
    begin
      
      fsm_start_addr_i(18 downto 0) <= start_adress(18 downto 0);
      wait until rising_edge(clk_i);
      fsm_re_i <= '1';
      fsm_we_i <= '1';
      state_i <= FSM_IDLE;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_11;
      fsm_re_i <= '0';

      wait until rising_edge(clk_i);
      -- FlipFlop hat Start-Adresse übernommmen
      -- addr_reg = start_addr 
      -- Addierer-Ausgang = start_addr + "1" 
      state_i <= FSM_READ_MEM_12;
      assert srctr_addr_reg_o(18 downto 0) = fsm_start_addr_i(18 downto 0) report "READ_MEM_11 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_11 WRONG 2";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_13;
      assert srctr_addr_reg_o(18 downto 0) = fsm_start_addr_i(18 downto 0) report "READ_MEM_12 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_12 WRONG 2";

      wait until rising_edge(clk_i);
      -- Liegt an
      state_i <= FSM_READ_MEM_21;
      assert srctr_addr_reg_o(18 downto 0) = fsm_start_addr_i(18 downto 0) report "READ_MEM_13 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_13 WRONG 2";

      wait until rising_edge(clk_i); -- FlipFlop adopts values
      -- srctr_addr_reg = end_addr_plus1 
      -- Adder out = start-adress + 2 
      state_i <= FSM_READ_MEM_22;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "READ_MEM_21 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_21 WRONG 2";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_23;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "READ_MEM_22 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_22 WRONG 2";

      wait until rising_edge(clk_i);
      -- Liegt an
      state_i <= FSM_READ_MEM_31;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "READ_MEM_23 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_23 WRONG 2";

      wait until rising_edge(clk_i); -- FlipFlop adopts values
      -- srctr_addr_reg = end_addr_plus1 
      -- Adder out = start-adress + 3
      state_i <= FSM_READ_MEM_32;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "READ_MEM_31 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_31 WRONG 2";      

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_33;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "READ_MEM_32 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_32 WRONG 2";

      wait until rising_edge(clk_i);
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "READ_MEM_33 WRONG 1";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "READ_MEM_33 WRONG 2";
    
      wait until rising_edge(clk_i);
    end procedure;
  begin
    -- insert signal assignments here
    report "READ 1";
    read("1111111111111111111");
    report "READ 2";
    read("1010101010101010101");
    report "READ 3";
    read("0111111111111111111");

    --report "WRITE 1";
    --write("1111111111111111111");
    --report "WRITE 2";
    --write("1010101010101010101");
    --report "WRITE 3";
    --write("0111111111111111111");

    assert false report "END OF SIMULATION REACHED - this is no error" severity note;
    stop_sim <= TRUE;
    wait;
  end process WaveGen_Proc;

end architecture tb;

-------------------------------------------------------------------------------

configuration sram_controler_address_tb_tb_cfg of sram_controler_address_tb is
  for tb
  end for;
end sram_controler_address_tb_tb_cfg;

-------------------------------------------------------------------------------