library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsm is

  port (
    clk_i     : in std_ulogic;
    reset_n_i : in std_ulogic;

    -- to/from I2S-Decoder

    fsm_cs_i2s_o    : out std_ulogic_vector(1 downto 0);
    i2s_we_re_fsm_i : in  std_ulogic_vector(1 downto 0);


    -- to/from I2C-Decoder

     fsm_we_i2c_o          : out std_ulogic:= '0';--
     fsm_config_i2c_data_o : out std_ulogic_vector(15 downto 0):= (others => '0');--


    -- to/from memory controller

    fsm_start_addr_o : out std_ulogic_vector(18 downto 0);  -- data input
    fsm_we_o         : out std_ulogic;  -- write request from FSM
    fsm_re_o         : out std_ulogic;  -- read request from FSM
    srctr_idle_i     : in  std_ulogic;  -- SRAM state machine is idle
    -- i.e. ready to start new read/write cycle

    srctr_end_addr_plus1_i : in std_ulogic_vector(18 downto 0);  -- end address plus 1
                                        -- valid if srctr_idle_o=1

    -- to/from I/O

    io_reset_n_i : in std_ulogic;
    io_replay_i  : in std_ulogic;
    io_record_i  : in std_ulogic);
end fsm;

architecture rtl of fsm is

  constant max_mem_c                       : std_ulogic_vector(18 downto 0) := "1111111111111111111";  -- memory size
  type     fsm_t is (FSM_IDLE, FSM_RECORD, FSM_RECORD_DATA, FSM_RECORD_WAIT, FSM_REPLAY, FSM_REPLAY_DATA, FSM_REPLAY_WAIT, FSM_CONFIG);  -- state types
  signal   state, next_state               : fsm_t;
  signal   mem_data_end_reg                : std_ulogic_vector(18 downto 0) := (others => '0');  -- data end address
  signal   first_time, i2s_we_re_fsm_i_reg : std_ulogic;
--  signal   config : std_ulogic := '0';--

--  signal codec_init : std_ulogic_vector(5 downto 0);

  
begin  -- rtl


  fsm_p : process (clk_i, reset_n_i)
  begin  -- process
    if reset_n_i = '0' then                 -- asynchronous reset (active low)
      state               <= FSM_IDLE;
      i2s_we_re_fsm_i_reg <= '0';
      first_time          <= '1';
      fsm_start_addr_o    <= (others => '0');
--      config <= '1';--
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      
      case state is
        
        when FSM_IDLE =>
          first_time <= '1';
          fsm_we_i2c_o <= '0';--
          fsm_config_i2c_data_o <= "0000000000000000";--
          if io_replay_i = '1' then  --and mem_data_end_reg /="000000000000000000"  then
            state <= FSM_REPLAY;
          elsif io_record_i = '1' then
            state <= FSM_RECORD;
--          elsif config = '1' then--
--            state <= FSM_CONFIG;--
--            config <='0';--
          end if;
          
        when FSM_CONFIG => State <= FSM_IDLE;

        when FSM_RECORD =>
          
          fsm_start_addr_o    <= srctr_end_addr_plus1_i;
          i2s_we_re_fsm_i_reg <= i2s_we_re_fsm_i(0);
          if srctr_idle_i = '1' and io_record_i = '1' and unsigned(srctr_end_addr_plus1_i) < unsigned(max_mem_c)-2 and i2s_we_re_fsm_i_reg = '0' and i2s_we_re_fsm_i(0) = '1' then
            state <= FSM_RECORD_DATA;
          elsif unsigned(srctr_end_addr_plus1_i) >= unsigned(max_mem_c) or io_record_i = '0' then
            state            <= FSM_IDLE;
            mem_data_end_reg <= srctr_end_addr_plus1_i;
            
          end if;
          
        when FSM_RECORD_DATA =>
          
          state <= FSM_RECORD_WAIT;

        when FSM_RECORD_WAIT =>
          if i2s_we_re_fsm_i(0) = '0' then
            state <= FSM_RECORD;
          end if;
          
        when FSM_REPLAY =>

          if first_time = '1' then
            fsm_start_addr_o <= (others => '0');
            
          else
            fsm_start_addr_o <= srctr_end_addr_plus1_i;
          end if;
          if srctr_idle_i = '1' and i2s_we_re_fsm_i(1) = '1' then
            state      <= FSM_REPLAY_DATA;
            first_time <= '0';
            fsm_we_i2c_o <= '0';--
			fsm_config_i2c_data_o <= "0000000000000000";--
          elsif srctr_end_addr_plus1_i >= mem_data_end_reg and first_time = '0' then
            state <= FSM_IDLE;
          end if;
          
        when FSM_REPLAY_DATA =>
          
          
          if i2s_we_re_fsm_i(1) = '1' then
            state <= FSM_REPLAY_WAIT;
          end if;
        when FSM_REPLAY_WAIT =>
          if i2s_we_re_fsm_i(1) = '0' then
            state <= FSM_REPLAY;
          end if;
          
        when others => null;
                       
      end case;
    end if;
  end process fsm_p;

-- -- purpose: 
-- i2c: process (state)
-- begin  -- process i2c
--   case state is
--     when   FSM_CONFIG=>
--         fsm_config_i2c_data_o <= B"0000000000" & codec_init;
--         fsm_we_i2c_o <= '1';
--     when others => null;
--   end case;
--
-- end process i2c;

  i2s_p : process (state)
  begin  -- process i2s
    
    case state is
      when FSM_RECORD|FSM_RECORD_DATA|FSM_RECORD_WAIT =>
        fsm_cs_i2s_o <= "01";
      when FSM_REPLAY|FSM_REPLAY_DATA|FSM_REPLAY_WAIT =>
        fsm_cs_i2s_o <= "10";
      when others =>
        fsm_cs_i2s_o <= "00";
    end case;
  end process i2s_p;

  srctr_p : process (state)
  begin  -- process srctr_p
    fsm_we_o <= '0';
    fsm_re_o <= '0';
    --fsm_start_addr_o <= (others => '0');
    case state is
      when FSM_RECORD_DATA =>
        fsm_we_o <= '1';
      when FSM_REPLAY_DATA =>
        fsm_re_o <= '1';
      when others => null;
    end case;
  end process srctr_p;
  
  
end rtl;
