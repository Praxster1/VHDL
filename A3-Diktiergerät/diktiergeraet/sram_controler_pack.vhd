library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
package sram_controler_pack is
  type FSM_t is (FSM_IDLE, FSM_READ_MEM_11, FSM_READ_MEM_12, FSM_READ_MEM_13, FSM_READ_MEM_21, FSM_READ_MEM_22, FSM_READ_MEM_23, FSM_READ_MEM_31, FSM_READ_MEM_32, FSM_READ_MEM_33, FSM_WRITE_MEM_11, FSM_WRITE_MEM_12, FSM_WRITE_MEM_13, FSM_WRITE_MEM_21, FSM_WRITE_MEM_22, FSM_WRITE_MEM_23, FSM_WRITE_MEM_31, FSM_WRITE_MEM_32, FSM_WRITE_MEM_33);
-- typdef. for fsm
  function "+" (
    constant l, r : std_ulogic_vector)
    return std_ulogic_vector;
  component sram_controler_data
    port (
      clk_i        : in    std_ulogic;
      reset_n_i    : in    std_ulogic;
      audio_data_i : in    std_ulogic_vector(23 downto 0);
      srctr_data_o : out   std_ulogic_vector(23 downto 0);
      fsm_we_i     : in    std_ulogic;
      fsm_re_i     : in    std_ulogic;
      mem_data_b   : inout std_logic_vector(15 downto 0);
      state_i      : in    FSM_T;
      addr_reg_i   : in    std_ulogic_vector(18 downto 0));

  end component;

end sram_controler_pack;

package body sram_controler_pack is

  function "+" (
    constant l, r : std_ulogic_vector)
    return std_ulogic_vector is
    variable result : std_ulogic_vector(l'high downto l'low);
  begin  -- +
    result := std_ulogic_vector(std_logic_vector(unsigned(l)+unsigned(r)));
    return result;
  end "+";
end sram_controler_pack;
