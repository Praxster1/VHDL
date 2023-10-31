library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;

entity sram_controler is                -- conditions for sram-controller

  port (
    fsm_start_addr_i       : in    std_ulogic_vector(18 downto 0);  -- start address
    clk_i                  : in    std_ulogic;
    reset_n_i              : in    std_ulogic;
    fsm_we_i               : in    std_ulogic;
    fsm_re_i               : in    std_ulogic;
    srctr_idle_o           : out   std_ulogic;
    srctr_we_reg_n_o       : out   std_ulogic;
    srctr_ce_n_o           : out   std_ulogic;
    srctr_oe_reg_n_o       : out   std_ulogic;
    srctr_lb_n_o           : out   std_ulogic;
    srctr_ub_n_o           : out   std_ulogic;
    srctr_end_addr_plus1_o : out   std_ulogic_vector(18 downto 0);  -- end-address increment
    srctr_addr_reg_o       : out   std_ulogic_vector(18 downto 0);  -- address for SRAM to write
    audio_data_i           : in    std_ulogic_vector(23 downto 0);
    srctr_data_o           : out   std_ulogic_vector(23 downto 0);
    mem_data_b             : inout std_logic_vector(15 downto 0));

end sram_controler;

