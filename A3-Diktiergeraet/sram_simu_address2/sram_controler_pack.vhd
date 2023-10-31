-------------------------------------------------------------------------------
-- Title      : sram controler - package for several units
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : sram_controler_pack.vhd
-- Author     : Rabe
-- Company    : 
-- Created    : 2014-12-28
-- Last update: 2018-11-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: type-definition for FSM, function for + operator, component
--		declaration for data path
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2014-12-28  1.0	Rabe	Created
-------------------------------------------------------------------------------

library ieee;
library project_lib;
use project_lib.fsm_pack.all;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
package sram_controler_pack is
--  type FSM_t is (FSM_IDLE, FSM_READ_MEM_11, FSM_READ_MEM_12, FSM_READ_MEM_13, FSM_READ_MEM_21, FSM_READ_MEM_22, FSM_READ_MEM_23, FSM_READ_MEM_31, FSM_READ_MEM_32, FSM_READ_MEM_33, FSM_WRITE_MEM_11, FSM_WRITE_MEM_12, FSM_WRITE_MEM_13, FSM_WRITE_MEM_21, FSM_WRITE_MEM_22, FSM_WRITE_MEM_23, FSM_WRITE_MEM_31, FSM_WRITE_MEM_32, FSM_WRITE_MEM_33);
-- typdef. for fsm
  function "+" (
    constant l, r : std_ulogic_vector)
    return std_ulogic_vector;
  
  component sram_controler_data
    port (
      clk_i	   : in	   std_ulogic;
      reset_n_i	   : in	   std_ulogic;
      audio_data_i : in	   std_ulogic_vector(23 downto 0);
      srctr_data_o : out   std_ulogic_vector(23 downto 0);
      fsm_we_i	   : in	   std_ulogic;
      fsm_re_i	   : in	   std_ulogic;
      mem_data_b   : inout std_logic_vector(15 downto 0);
      state_i	   : in	   FSM_T;
      addr_reg_i   : in	   std_ulogic_vector(18 downto 0));

  end component;

  component sram_controler_address is
    port (
      clk_i		     : in  std_ulogic;
      reset_n_i		     : in  std_ulogic;
      fsm_we_i		     : in  std_ulogic;
      fsm_re_i		     : in  std_ulogic;
      fsm_start_addr_i	     : in  std_ulogic_vector(18 downto 0);
      state_i		     : in  FSM_T;
      srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0);
      srctr_addr_reg_o	     : out std_ulogic_vector(18 downto 0)); 
  end component sram_controler_address;

  component tb_address_hidden is
    port (
      clk_o			 : out std_ulogic;
      reset_n_o			 : out std_ulogic;
      fsm_we_o			 : out std_ulogic;
      fsm_re_o			 : out std_ulogic;
      fsm_start_addr_o		 : out std_ulogic_vector(18 downto 0);
      state_o			 : out FSM_T;
      ref_srctr_addr_reg_o	 : out std_ulogic_vector(18 downto 0);
      ref_srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0);
      srctr_end_addr_plus1_i	 : in  std_ulogic_vector(18 downto 0);
      srctr_addr_reg_i		 : in  std_ulogic_vector(18 downto 0));
  end component tb_address_hidden;


end sram_controler_pack;

package body sram_controler_pack is

  function "+" (
    constant l, r : std_ulogic_vector)
    return std_ulogic_vector is
    variable result : std_ulogic_vector(l'high downto l'low);
  begin	 -- +
    result := std_ulogic_vector(std_logic_vector(unsigned(l)+unsigned(r)));
    return result;
  end "+";
end sram_controler_pack;
