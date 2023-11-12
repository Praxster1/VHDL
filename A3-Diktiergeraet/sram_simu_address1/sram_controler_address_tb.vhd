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
  signal clk_i                  : std_ulogic;
  signal reset_n_i              : std_ulogic;
  signal fsm_we_i               : std_ulogic;
  signal fsm_re_i               : std_ulogic;
  signal fsm_start_addr_i       : std_ulogic_vector(18 downto 0);
  signal state_i                : FSM_T;
  signal srctr_end_addr_plus1_o : std_ulogic_vector(18 downto 0);
  signal srctr_addr_reg_o       : std_ulogic_vector(18 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture tb

  -- component instantiation
  DUT: entity work.sram_controler_address
    port map (
      clk_i                  => clk_i,
      reset_n_i              => reset_n_i,
      fsm_we_i               => fsm_we_i,
      fsm_re_i               => fsm_re_i,
      fsm_start_addr_i       => fsm_start_addr_i,
      state_i                => state_i,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
      srctr_addr_reg_o       => srctr_addr_reg_o);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until Clk = '1';
  end process WaveGen_Proc;

  

end architecture tb;

-------------------------------------------------------------------------------

configuration sram_controler_address_tb_tb_cfg of sram_controler_address_tb is
  for tb
  end for;
end sram_controler_address_tb_tb_cfg;

-------------------------------------------------------------------------------
