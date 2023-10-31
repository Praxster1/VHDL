library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;


entity sram_controler_data is

  port (
    clk_i        : in    std_ulogic;
    reset_n_i    : in    std_ulogic;
    audio_data_i : in    std_ulogic_vector(23 downto 0);
    srctr_data_o : out   std_ulogic_vector(23 downto 0);
    fsm_we_i     : in    std_ulogic;
    mem_data_b   : inout std_logic_vector(15 downto 0);
    state_i      : in    FSM_T;
    addr_reg0_i  : in    std_ulogic);

end sram_controler_data;

