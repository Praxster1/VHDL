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
  signal reset_n_i : std_ulogic := '0';
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
      fsm_re_i <= '0';
      fsm_we_i <= '1';
      wait until rising_edge(clk_i);
      state_i <= FSM_IDLE;
      wait until rising_edge(clk_i);
      assert srctr_addr_reg_o(18 downto 0) = fsm_start_addr_i(18 downto 0) report "INIT WRONG";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "INIT2 WRONG";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_11;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_12;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_13;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_21;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_22;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_23;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_31;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_32;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_33;

      state_i <= FSM_IDLE;
      wait until rising_edge(clk_i);

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_11;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_12;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_13;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_21;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_22;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_23;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_31;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_32;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_33;
    end procedure;
  begin
    -- insert signal assignments here
    read("1111111111111111111");

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