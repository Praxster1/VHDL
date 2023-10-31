-------------------------------------------------------------------------------
-- Title      : sram controler - address path
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sram_controler_address.vhd
-- Author     : Rabe
-- Company    : 
-- Created    : 2014-12-28
-- Last update: 2018-11-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-12-28  1.0      Rabe	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
library project_lib;
use project_lib.fsm_pack.all;
use work.sram_controler_pack.all;


entity sram_controler_address is

  port (
    clk_i                  : in  std_ulogic;
    reset_n_i              : in  std_ulogic;
    fsm_we_i               : in  std_ulogic;
    fsm_re_i               : in  std_ulogic;
    fsm_start_addr_i       : in  std_ulogic_vector(18 downto 0);
    state_i                : in  FSM_T;
    srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0);
    srctr_addr_reg_o       : out std_ulogic_vector(18 downto 0));
end sram_controler_address;

