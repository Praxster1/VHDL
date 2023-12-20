library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;

entity sram_controler is		-- conditions for sram-controller

  port (
    fsm_start_addr_i	   : in	   std_ulogic_vector(18 downto 0);  -- start address
    clk_i		   : in	   std_ulogic;
    reset_n_i		   : in	   std_ulogic;
    fsm_we_i		   : in	   std_ulogic;
    fsm_re_i		   : in	   std_ulogic;
    srctr_idle_o	   : out   std_ulogic;
    srctr_we_reg_n_o	   : out   std_ulogic;
    srctr_ce_n_o	   : out   std_ulogic;
    srctr_oe_reg_n_o	   : out   std_ulogic;
    srctr_lb_n_o	   : out   std_ulogic;
    srctr_ub_n_o	   : out   std_ulogic;
    srctr_end_addr_plus1_o : out   std_ulogic_vector(18 downto 0);  -- end-address increment
    srctr_addr_reg_o	   : out   std_ulogic_vector(18 downto 0);  -- address for SRAM to write
    audio_data_i	   : in	   std_ulogic_vector(23 downto 0);
    srctr_data_o	   : out   std_ulogic_vector(23 downto 0);
    mem_data_b		   : inout std_logic_vector(15 downto 0));

end sram_controler;

-------------------------------------------------------------------------------

architecture sram_ctrl of sram_controler is

  signal state_s    : FSM_t;
  signal addr_reg_s : std_ulogic_vector(18 downto 0);

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

  component sram_controler_data is
    port (
      clk_i	   : in	   std_ulogic;
      reset_n_i	   : in	   std_ulogic;
      audio_data_i : in	   std_ulogic_vector(23 downto 0);
      srctr_data_o : out   std_ulogic_vector(23 downto 0);
      fsm_we_i	   : in	   std_ulogic;
      mem_data_b   : inout std_logic_vector(15 downto 0);
      state_i	   : in	   FSM_T;
      addr_reg0_i  : in	   std_ulogic);
  end component sram_controler_data;

-------------------------------------------------------------------------------
begin  -- architecture sram_ctrl

  sram_controler_address_1 : sram_controler_address
    port map (
      clk_i		     => clk_i,
      reset_n_i		     => reset_n_i,
      fsm_we_i		     => fsm_we_i,
      fsm_re_i		     => fsm_re_i,
      fsm_start_addr_i	     => fsm_start_addr_i,
      state_i		     => state_s,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
      srctr_addr_reg_o	     => addr_reg_s);

  srctr_addr_reg_o <= addr_reg_s;

  sram_controler_data_1 : sram_controler_data
    port map (
      clk_i	   => clk_i,
      reset_n_i	   => reset_n_i,
      audio_data_i => audio_data_i,
      srctr_data_o => srctr_data_o,
      fsm_we_i	   => fsm_we_i,
      mem_data_b   => mem_data_b,
      state_i	   => state_s,
      addr_reg0_i  => addr_reg_s(0));
-------------------------------------------------------------------------------
-- purpose: finite statemachine
  fsm_block : block is
    port (
      fsm_we_i	: in  std_ulogic;
      fsm_re_i	: in  std_ulogic;
      clk_i	: in  std_ulogic;
      reset_n_i : in  std_ulogic;
      state_o	: out FSM_t);
    port map (
      fsm_we_i	=> fsm_we_i,
      fsm_re_i	=> fsm_re_i,
      clk_i	=> clk_i,
      reset_n_i => reset_n_i,
      state_o	=> state_s);

    signal state_reg : FSM_t;

  begin	 -- block fsm_block
    p_fsm : process (clk_i, reset_n_i) is
    begin  -- process p_fsm
      if reset_n_i = '0' then		-- asynchronous reset (active low)

	state_reg <= FSM_IDLE;

      elsif clk_i'event and clk_i = '1' then  -- rising clock edge

	case state_reg is

	  when FSM_IDLE | FSM_WRITE_MEM_32 | FSM_READ_MEM_32 =>

	    state_reg <= FSM_IDLE;

	    if fsm_we_i = '1' then
	      state_reg <= FSM_WRITE_MEM_11;
	    end if;

	    if fsm_re_i = '1' then
	      state_reg <= FSM_READ_MEM_11;
	    end if;

	    -- when FSM_WRITE_MEM_33 =>

	    --	 if fsm_we_i = '1' then
	    --	   state_reg <= FSM_WRITE_MEM_11;
	    --	 elsif fsm_re_i = '1' then
	    --	   state_reg <= FSM_READ_MEM_11;
	    --	 else
	    --	   state_reg <= FSM_IDLE;
	    --	 end if;

	    -- when FSM_READ_MEM_33 =>

	    --	 if fsm_we_i = '1' then
	    --	   state_reg <= FSM_WRITE_MEM_11;
	    --	 elsif fsm_re_i = '1' then
	    --	   state_reg <= FSM_READ_MEM_11;
	    --	 else
	    --	   state_reg <= FSM_IDLE;
	    --	 end if;

	  when others => state_reg <= FSM_t'succ(state_reg);
	end case;
      end if;
    end process p_fsm;

    state_o <= state_reg;

  end block fsm_block;

-------------------------------------------------------------------------------
-- purpose: finitie state machine
-- type	  : sequential
-- inputs : clk_i, reset_n_i
-- outputs: 
  -- p_fsm : process (clk_i, reset_n_i) is
  -- begin	 -- process p_fsm
  --   if reset_n_i = '0' then		-- asynchronous reset (active low)

  --	 state_s <= FSM_IDLE;

  --   elsif clk_i'event and clk_i = '1' then  -- rising clock edge

  --	 case state_s is

  --	when FSM_IDLE =>
  --	  if fsm_we_i = '1' then
  --	    state_s <= FSM_WRITE_MEM_11;
  --	  end if;

  --	  if fsm_re_i = '1' then
  --	    state_s <= FSM_READ_MEM_11;
  --	  end if;

  --	when FSM_WRITE_MEM_33 =>

  --	  if fsm_we_i = '1' then
  --	    state_s <= FSM_WRITE_MEM_11;
  --	  elsif fsm_re_i = '1' then
  --	    state_s <= FSM_READ_MEM_11;
  --	  else
  --	    state_s <= FSM_IDLE;
  --	  end if;

  --	when FSM_READ_MEM_33 =>

  --	  if fsm_we_i = '1' then
  --	    state_s <= FSM_WRITE_MEM_11;
  --	  elsif fsm_re_i = '1' then
  --	    state_s <= FSM_READ_MEM_11;
  --	  else
  --	    state_s <= FSM_IDLE;
  --	  end if;

  --	when others => state_s <= FSM_t'succ(state_s);

  --	 end case;
  --   end if;
  -- end process p_fsm;

-------------------------------------------------------------------------------

  srctr_idle_p : process (state_s) is
  begin	 -- process srctr_idle_p

    case state_s is
      when FSM_IDLE | FSM_WRITE_MEM_32 | FSM_READ_MEM_32 => srctr_idle_o <= '1';
      when others					 => srctr_idle_o <= '0';
    end case;

  end process srctr_idle_p;

-------------------------------------------------------------------------------

  control_seq_p : process (clk_i, reset_n_i) is
  begin	 -- process control_seq_p
    if reset_n_i = '0' then		-- asynchronous reset (active low)
      srctr_we_reg_n_o <= '1';
      srctr_oe_reg_n_o <= '1';

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      case state_s is

	when FSM_IDLE | FSM_WRITE_MEM_32 | FSM_READ_MEM_32 =>
	  if fsm_we_i = '1' then
	    srctr_we_reg_n_o <= '0';
	    srctr_oe_reg_n_o <= '1';
	  end if;
	  
	  if fsm_re_i = '1' then
	    srctr_we_reg_n_o <= '1';
	    srctr_oe_reg_n_o <= '0';
	  end if;
	  
	when FSM_WRITE_MEM_12 | FSM_WRITE_MEM_22 => srctr_we_reg_n_o <= '0';
						    srctr_oe_reg_n_o <= '1';

	when FSM_READ_MEM_11 | FSM_READ_MEM_21 => srctr_oe_reg_n_o <= '0';
						srctr_we_reg_n_o <= '1';

	when others => srctr_oe_reg_n_o <= '1';
		       srctr_we_reg_n_o <= '1';

      end case;

    end if;
  end process control_seq_p;

-------------------------------------------------------------------------------

  control_comp_p : process (addr_reg_s, state_s) is
  begin	 -- process control_comp_p

    case state_s is
      when FSM_IDLE => srctr_ce_n_o <= '1';
      when others   => srctr_ce_n_o <= '0';
    end case;

    if addr_reg_s(0) = '0' then
      srctr_lb_n_o <= '0';
      srctr_ub_n_o <= '1';
    else
      srctr_lb_n_o <= '1';
      srctr_ub_n_o <= '0';
    end if;

  end process control_comp_p;

-------------------------------------------------------------------------------
end architecture sram_ctrl;
