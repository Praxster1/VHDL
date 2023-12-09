library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;

entity sram_controler is -- conditions for sram-controller

  port (
    fsm_start_addr_i : in std_ulogic_vector(18 downto 0); -- start address
    clk_i : in std_ulogic;
    reset_n_i : in std_ulogic;
    fsm_we_i : in std_ulogic;
    fsm_re_i : in std_ulogic;
    srctr_idle_o : out std_ulogic;
    srctr_we_reg_n_o : out std_ulogic;
    srctr_ce_n_o : out std_ulogic;
    srctr_oe_reg_n_o : out std_ulogic;
    srctr_lb_n_o : out std_ulogic;
    srctr_ub_n_o : out std_ulogic;
    srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0); -- end-address increment
    srctr_addr_reg_o : out std_ulogic_vector(18 downto 0); -- address for SRAM to write
    audio_data_i : in std_ulogic_vector(23 downto 0);
    srctr_data_o : out std_ulogic_vector(23 downto 0);
    mem_data_b : inout std_logic_vector(15 downto 0);
    state_o : out FSM_T
  );

end sram_controler;
architecture rtl of sram_controler is
  signal state_reg : FSM_T;
  signal addr_reg : std_ulogic_vector(18 downto 0);

  component sram_controler_data is
    port (
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      audio_data_i : in std_ulogic_vector(23 downto 0);
      srctr_data_o : out std_ulogic_vector(23 downto 0);
      fsm_we_i : in std_ulogic;
      mem_data_b : inout std_logic_vector(15 downto 0);
      state_i : in FSM_T;
      addr_reg0_i : in std_ulogic);
  end component sram_controler_data;

  component sram_controler_address is
    port (
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      fsm_we_i : in std_ulogic;
      fsm_re_i : in std_ulogic;
      fsm_start_addr_i : in std_ulogic_vector(18 downto 0);
      state_i : in FSM_T;
      srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0);
      srctr_addr_reg_o : out std_ulogic_vector(18 downto 0));
  end component sram_controler_address;

begin

  srctr_addr_reg_o <= addr_reg;

  sram_controler_address_inst : sram_controler_address
  port map(
    clk_i => clk_i,
    reset_n_i => reset_n_i,
    fsm_we_i => fsm_we_i,
    fsm_re_i => fsm_re_i,
    fsm_start_addr_i => fsm_start_addr_i,
    state_i => state_reg,
    srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
    srctr_addr_reg_o => addr_reg);

  sram_controler_data_inst : sram_controler_data
  port map(
    clk_i => clk_i,
    reset_n_i => reset_n_i,
    audio_data_i => audio_data_i,
    srctr_data_o => srctr_data_o,
    fsm_we_i => fsm_we_i,
    mem_data_b => mem_data_b,
    state_i => state_reg,
    addr_reg0_i => addr_reg(0));

  fsm_block : block is
    port (
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      state_o : out FSM_T;
      fsm_re_i : in std_ulogic;
      fsm_we_i : in std_ulogic);

    port map(
      clk_i => clk_i,
      reset_n_i => reset_n_i,
      state_o => state_reg,
      fsm_we_i => fsm_we_i,
      fsm_re_i => fsm_re_i);

    signal next_state : FSM_T;

  begin
    fsm_p : process (clk_i, reset_n_i) is
    begin -- process p_fsm

      if reset_n_i = '0' then
        next_state <= FSM_IDLE;

      elsif clk_i'event and clk_i = '1' then
        case next_state is
          when FSM_IDLE | FSM_WRITE_MEM_33 | FSM_READ_MEM_33 =>

            if fsm_re_i = '1' then
              next_state <= FSM_READ_MEM_11;
            elsif fsm_we_i = '1' then
              next_state <= FSM_WRITE_MEM_11;
            else
              next_state <= FSM_IDLE;
            end if;

          when others =>
            next_state <= FSM_T'succ(next_state);
        end case;
      end if;
    end process fsm_p;

    state_o <= next_state;

  end block fsm_block;

  -- Erzeugt aus dem aktuellen Zustand die Ausgabesignale 
  -- oe_reg und we_reg, die für die Ansteuerung des SRAM-
  -- Speichers erforderlich sind.
  control_seq_p : process (clk_i, reset_n_i)
  begin
    if rising_edge(clk_i) then
      srctr_we_reg_n_o <= '1';
      srctr_oe_reg_n_o <= '1';
      case (state_reg) is
      
        --when FSM_IDLE | FSM_WRITE_MEM_32 | FSM_READ_MEM_32 =>
        --  if fsm_we_i = '1' then
        --    srctr_we_reg_n_o <= '0';
        --  elsif fsm_re_i = '1' then
        --    srctr_oe_reg_n_o <= '0';
        --  end if;
        when FSM_READ_MEM_11 | FSM_READ_MEM_21 | FSM_READ_MEM_31 => -- Ready for new Byte
          srctr_oe_reg_n_o <= '0';
        when FSM_WRITE_MEM_11 | FSM_WRITE_MEM_21 | FSM_WRITE_MEM_31 =>
          srctr_we_reg_n_o <= '0';
        when others =>
      end case;
    end if;
    if reset_n_i = '0' then
      srctr_we_reg_n_o <= '1';
      srctr_oe_reg_n_o <= '1';
    end if;
  end process;

  -- Erzeugt kombinatorisch aus addr_reg0 und dem aktiellen Z. die 
  -- restlichen Ausgabesignale, die für Ansteuerung 
  -- des SRAM-Speichers erforderlich sind
  control_comb_p : process (state_reg, addr_reg(0))
  begin
    srctr_ce_n_o <= '0';
    if state_reg = FSM_IDLE then -- Disable sram in idle to save power / Deactivate if run on Hardware
      srctr_ce_n_o <= '1';
    end if;

    --if state_reg = FSM_READ_MEM_33 or state_reg = FSM_READ_MEM_13 or state_reg = FSM_READ_MEM_23
    --  or state_reg = FSM_WRITE_MEM_33 or state_reg = FSM_WRITE_MEM_13 or state_reg = FSM_WRITE_MEM_23
    --  --or state_reg = FSM_IDLE
    --  then
      srctr_lb_n_o <= addr_reg(0);
      srctr_ub_n_o <= (not addr_reg(0));
    --end if;
  end process;

  srctr_idle_p : process (state_reg)
  begin
    if state_reg = FSM_IDLE or state_reg = FSM_WRITE_MEM_33 or state_reg = FSM_READ_MEM_33 then
      srctr_idle_o <= '1';
    else
      srctr_idle_o <= '0';
    end if;
  end process;

end architecture;