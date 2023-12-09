-------------------------------------------------------------------------------
-- Title      : Testbench for design "sram_controler_address"
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : sram_controler_address_tb_hide.vhd
-- Author     : Rabe 
-- Company    : 
-- Created    : 2017-10-07
-- Last update: 2018-11-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2017 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2017-10-07  1.0	Rabe	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.sram_controler_pack.all;

library project_lib;
use project_lib.fsm_pack.all;

-------------------------------------------------------------------------------

entity sram_controler_address_tb_hide is

end sram_controler_address_tb_hide;

-------------------------------------------------------------------------------
architecture tb_hide of sram_controler_address_tb_hide is
  signal clk			  : std_ulogic := '1';
  signal reset_n		  : std_ulogic;
  signal srctr_end_addr_plus1	  : std_ulogic_vector(18 downto 0);
  signal srctr_addr_reg		  : std_ulogic_vector(18 downto 0);
  signal fsm_we			  : std_ulogic;
  signal fsm_re			  : std_ulogic;
  signal fsm_start_addr		  : std_ulogic_vector(18 downto 0);
  signal state			  : FSM_T;
  signal ref_srctr_addr_reg	  : std_ulogic_vector(18 downto 0);
  signal ref_srctr_end_addr_plus1 : std_ulogic_vector(18 downto 0);
  signal test_case_count	  : integer    := 0;

begin  -- tb_hide
  DUT : sram_controler_address
    port map (
      clk_i		     => clk,
      reset_n_i		     => reset_n,
      fsm_we_i		     => fsm_we,
      fsm_re_i		     => fsm_re,
      fsm_start_addr_i	     => fsm_start_addr,
      state_i		     => state,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1,
      srctr_addr_reg_o	     => srctr_addr_reg);

  tb_address_hidden_1 : tb_address_hidden
    port map (
      clk_o			 => clk,
      reset_n_o			 => reset_n,
      fsm_we_o			 => fsm_we,
      fsm_re_o			 => fsm_re,
      fsm_start_addr_o		 => fsm_start_addr,
      state_o			 => state,
      ref_srctr_addr_reg_o	 => ref_srctr_addr_reg,
      ref_srctr_end_addr_plus1_o => ref_srctr_end_addr_plus1,
      srctr_end_addr_plus1_i	 => srctr_end_addr_plus1,
      srctr_addr_reg_i		 => srctr_addr_reg);

end tb_hide;
