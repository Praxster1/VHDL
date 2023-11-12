library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;

entity sram_controler_data is
  port (
    clk_i : in std_ulogic;
    reset_n_i : in std_ulogic;
    audio_data_i : in std_ulogic_vector(23 downto 0);
    srctr_data_o : out std_ulogic_vector(23 downto 0);
    fsm_we_i : in std_ulogic;
    mem_data_b : inout std_logic_vector(15 downto 0);
    state_i : in FSM_T;
    addr_reg0_i : in std_ulogic);

end sram_controler_data;

architecture rtl of sram_controler_data is
  signal data_reg : std_ulogic_vector(23 downto 0);
begin -- architecture rtl

  srctr_data_o <= data_reg;

  datareg_p : process (clk_i, reset_n_i) is
  begin -- process datareg_p
    if reset_n_i = '0' then
      data_reg <= (others => '0');
    elsif (rising_edge(clk_i)) then
      if fsm_we_i = '1' and (state_i = FSM_IDLE or state_i = FSM_WRITE_MEM_33 or state_i = FSM_READ_MEM_33) then
        data_reg <= audio_data_i;
      elsif ((state_i = FSM_WRITE_MEM_13) or (state_i = FSM_WRITE_MEM_23)) then
        data_reg(15 downto 0) <= data_reg(23 downto 8);

      elsif (state_i = FSM_READ_MEM_12 or state_i = FSM_READ_MEM_22 or state_i = FSM_READ_MEM_32) then
        if (addr_reg0_i = '1') then
          data_reg(23 downto 16) <= std_ulogic_vector(mem_data_b(15 downto 8));
          data_reg(15 downto 0) <= data_reg(23 downto 8);
        else
          data_reg(23 downto 16) <= std_ulogic_vector(mem_data_b(7 downto 0));
          data_reg(15 downto 0) <= data_reg(23 downto 8);
        end if;
      end if;
    end if;
  end process;

  data_b_p : process (state_i, data_reg) is
  begin -- process data_b_p
    if (state_i >= FSM_WRITE_MEM_11 and state_i <= FSM_READ_MEM_33) then -- (state_i = FSM_WRITE_MEM_11) or (state_i = FSM_WRITE_MEM_12) or (state_i = FSM_WRITE_MEM_13) or (state_i = FSM_WRITE_MEM_21) or (state_i = FSM_WRITE_MEM_22) or (state_i = FSM_WRITE_MEM_23) or (state_i = FSM_WRITE_MEM_31) or (state_i = FSM_WRITE_MEM_32) or (state_i = FSM_WRITE_MEM_31)) then
      mem_data_b(15 downto 8) <= std_logic_vector(data_reg(7 downto 0));
      mem_data_b(7 downto 0) <= std_logic_vector(data_reg(7 downto 0));
    else
      mem_data_b <= (others => 'Z');
    end if;
  end process data_b_p;
end architecture rtl;