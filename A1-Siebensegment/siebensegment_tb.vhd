-------------------------------------------------------------------------------
-- Title      : Testbench for design "siebensegment"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : siebensegment_tb.vhd
-- Author     :   <timow@TIMOWINDOWS>
-- Company    : 
-- Created    : 2023-09-24
-- Last update: 2023-09-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-09-24  1.0      timow	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

use ieee.numeric_bit.all;
entity siebensegment_tb is

end entity siebensegment_tb;

-------------------------------------------------------------------------------

architecture Behavior of siebensegment_tb is

  -- component ports
  signal sw   : std_ulogic_vector(15 downto 0);
  signal ledg : std_ulogic_vector(6 downto 0);
  signal hex0 : std_ulogic_vector(6 downto 0);
  signal hex1 : std_ulogic_vector(6 downto 0);
  signal hex2 : std_ulogic_vector(6 downto 0);
  signal hex3 : std_ulogic_vector(6 downto 0);
  signal hex4 : std_ulogic_vector(6 downto 0);
  signal hex5 : std_ulogic_vector(6 downto 0);
  signal hex6 : std_ulogic_vector(6 downto 0);
  signal hex7 : std_ulogic_vector(6 downto 0);

  -- clock
  signal Clk : std_logic := '1';

  component siebensegment is
    port (
      sw   : in  std_ulogic_vector(15 downto 0);
      ledg : out std_ulogic_vector(6 downto 0);
      hex0 : out std_ulogic_vector(6 downto 0);
      hex1 : out std_ulogic_vector(6 downto 0);
      hex2 : out std_ulogic_vector(6 downto 0);
      hex3 : out std_ulogic_vector(6 downto 0);
      hex4 : out std_ulogic_vector(6 downto 0);
      hex5 : out std_ulogic_vector(6 downto 0);
      hex6 : out std_ulogic_vector(6 downto 0);
      hex7 : out std_ulogic_vector(6 downto 0));
  end component siebensegment;

begin  -- architecture Behavior

  -- component instantiation
  DUT: siebensegment
    port map (
      sw   => sw,
      ledg => ledg,
      hex0 => hex0,
      hex1 => hex1,
      hex2 => hex2,
      hex3 => hex3,
      hex4 => hex4,
      hex5 => hex5,
      hex6 => hex6,
      hex7 => hex7);

  
  
  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    for counter in 0 to 2**16 -1 loop
      sw <= sw(to_unsigned(counter, sw'length)); -- Oder standard std_ulogic_vector?
      wait for 5 ns;
    end loop;


    wait until Clk = '1';
  end process WaveGen_Proc;

  

end architecture Behavior;

-------------------------------------------------------------------------------

configuration siebensegment_tb_Behavior_cfg of siebensegment_tb is
  for Behavior
  end for;
end siebensegment_tb_Behavior_cfg;

-------------------------------------------------------------------------------
