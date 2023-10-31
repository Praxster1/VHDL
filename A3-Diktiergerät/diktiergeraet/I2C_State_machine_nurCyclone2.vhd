library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity I2C_State_machine is

  port (
    clk_i     : in std_ulogic;
    reset_n_i : in std_ulogic;

    data_i     : in  std_ulogic_vector(15 downto 0);
    we_i       : in  std_ulogic;
    i2c_idle_o : out std_ulogic;

    i2c_sdin_b : inout std_logic;
    i2c_sclk_o : out   std_ulogic);--
--    debug_o    : out   std_ulogic_vector(15 downto 0));

  
end I2C_State_machine;

architecture Rtl of I2C_State_machine is

  -----------------------------------------------------------------------------
  -- type definitions
  -----------------------------------------------------------------------------

  type fsm_write is (FSM_WRITE_IDLE, FSM_WRITE_STARTCOND, FSM_WRITE_STARTCOND2, FSM_WRITE_BIT7_SEND, FSM_WRITE_BIT6_SEND, FSM_WRITE_BIT5_SEND, FSM_WRITE_BIT4_SEND, FSM_WRITE_BIT3_SEND, FSM_WRITE_BIT2_SEND, FSM_WRITE_BIT1_SEND, FSM_WRITE_BIT0_SEND, FSM_WRITE_ACK, FSM_WRITE_ACK_READY, FSM_WRITE_STOPCOND, FSM_WRITE_STOPCOND2);  -- state types
  type fsm_control is (FSM_CONTROL_IDLE, FSM_CONTROL_SEND_1, FSM_CONTROL_SEND_2, FSM_CONTROL_SEND_3, FSM_CONTROL_WAIT);  -- c_state types
  type regset is array (integer range 0 to 5) of std_ulogic_vector(15 downto 0);  --Register file, contains data for codec initializations

  -----------------------------------------------------------------------------
  -- send_reg_p
  -----------------------------------------------------------------------------

  signal shift_reg    : std_ulogic_vector(7 downto 0);  -- byte sized shift register for I²C Data
  signal shift_reload : std_ulogic_vector(2 downto 0);  -- set to reload the register

  -------------------------------------------------------------------------------
  -- tristate_p
  -------------------------------------------------------------------------------

  --signal ack : std_ulogic;              -- acknownledge signal

  -----------------------------------------------------------------------------
  -- clk_counter_p
  -----------------------------------------------------------------------------

  signal clk_counter_reg : integer range 0 to 132;  -- for clk splitting purposes
  signal s_clk_reg       : std_ulogic;  -- register for clk transfer to other processes

  -----------------------------------------------------------------------------
  -- fsm_write_p
  -----------------------------------------------------------------------------

  signal byte_trans_compl_s : std_ulogic;  -- byte send transaction is done
  signal byte_trans_ok_s    : std_ulogic;  -- byte send transaction was successful

  signal state : fsm_write;

  -----------------------------------------------------------------------------
  -- write_out_p
  -----------------------------------------------------------------------------

  signal tri_z_s    : std_ulogic;  -- tristate high impendancy enable signal
  signal tri_data_s : std_ulogic;       -- data input for tristate bridge

  -----------------------------------------------------------------------------
  -- fsm_control_p
  -----------------------------------------------------------------------------

  signal c_state        : fsm_control;
  signal std_conf_count : integer range 0 to 6;
  signal data_reg       : std_ulogic_vector(23 downto 0);  -- Data register for shifting
  signal ack_ok_reg     : std_ulogic;

  -----------------------------------------------------------------------------
  -- control_out_p
  -----------------------------------------------------------------------------

  signal send_en_s   : std_ulogic;  -- enable signal for the bit send state machine
  signal start_con_s : std_ulogic;      -- enable bit for start condition
  signal stop_con_s  : std_ulogic;      -- enable bit for stop condition
  signal sclk_en_s   : std_ulogic;      -- enables the I²C clock


  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  constant std_conf_array : regset := (X"1200", X"0117", X"0815", X"0E4A", X"0C00", X"1201");

  constant t2  : natural := 68;
  constant t3  : natural := 34;
  constant t10 : natural := 96;

  constant t8 : natural := 32;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

begin  -- Rtl

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

  -- purpose: reloads the send register
  -- type   : sequential
  -- inputs : clk_i, reset_n_i, shift_reload, data_reg
  -- outputs: shift_reg
  send_reg_p : process (clk_i, reset_n_i)
  begin  -- process send_reg_p
    if reset_n_i = '0' then                 -- asynchronous reset (active low)
      shift_reg <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if shift_reload = "001" then
        shift_reg <= data_reg(23 downto 16);
      elsif shift_reload = "010" then
        shift_reg <= data_reg(15 downto 8);
      elsif shift_reload = "100" then
        shift_reg <= data_reg(7 downto 0);
      end if;
    end if;
  end process send_reg_p;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------  

  -- purpose: tristate, bidirectional signal to configuration interface of the
  -- audio codec
  -- type   : sequential
  -- inputs : clk_i, reset_n_i, shift_reload
  -- outputs: i2c_sdin_b, ack
  tristate_p : process ( i2c_sdin_b, tri_data_s, tri_z_s)--ack,
  begin
    -- debug_o(0) <= ack;
    i2c_sdin_b <= 'Z';
 --   ack        <= i2c_sdin_b;

    if tri_z_s = '1' then
      i2c_sdin_b <= 'Z';

    elsif tri_data_s = '1' then
      i2c_sdin_b <= '1';
    elsif tri_data_s = '0' then
      i2c_sdin_b <= '0';
    end if;

  end process tristate_p;
  -- ack        <= i2c_sdin_b;
  -----------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

  -- purpose: generates the clock for I²C
  -- type   : sequential
  -- inputs : clk_i, reset_n_i 
  -- outputs: i2c_sclk_o, s_clk_reg, clk_counter_reg
  clk_counter_p : process (clk_i, reset_n_i)
  begin  -- process clk_counter_p
    if reset_n_i = '0' then                 -- asynchronous reset (active low)
      clk_counter_reg <= 0;
      s_clk_reg       <= '0';
      i2c_sclk_o      <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if sclk_en_s = '1' or clk_counter_reg /= 0 then
        if clk_counter_reg = 126 then
          clk_counter_reg <= 0;
        else
          clk_counter_reg <= clk_counter_reg + 1;
          if clk_counter_reg = 0 then
            i2c_sclk_o <= '1';
            s_clk_reg  <= '1';
          elsif clk_counter_reg = t2 then
            i2c_sclk_o <= '0';
            s_clk_reg  <= '0';
          end if;
        end if;
      end if;
    end if;
  end process clk_counter_p;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

  -- purpose: FSM for bit send, sends each bit of of current byte as well as
  -- the start condition before the first byte and the stop condition after the
  -- third byte. It aso checks for the acknowledge. 
  -- type   : sequential
  -- inputs : clk_i, reset_n_i, send_en_s, start_con_s, clk_counter_reg,
  -- stop_con_s, s_clk_reg
  -- outputs: state, byte_trans_ok_s, byte_trans_compl_s

  fsm_write_p : process (clk_i, reset_n_i)
  begin  -- process p_fsm
    if reset_n_i = '0' then                 -- asynchronous reset (active low)
      state      <= FSM_WRITE_IDLE;
--      debug_o(1) <= '1';
--      debug_o(2) <= '0';
--		debug_o(15 downto 3) <= (others => '0');
--		debug_o(0) <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      
      case state is

        when FSM_WRITE_IDLE =>
          if send_en_s = '1' and start_con_s = '1' and clk_counter_reg = t3 then
            state <= FSM_WRITE_STARTCOND;
          elsif send_en_s = '1' and start_con_s = '0' then
            if clk_counter_reg = t10 then
              state <= FSM_WRITE_BIT7_SEND;
            end if;
          else
            state <= FSM_WRITE_IDLE;
          end if;

        when FSM_WRITE_STARTCOND =>
          state <= FSM_WRITE_STARTCOND2;
          
        when FSM_WRITE_STARTCOND2 =>
          if s_clk_reg = '0' and clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT7_SEND;
          else
            state <= FSM_WRITE_STARTCOND2;
          end if;

        when FSM_WRITE_BIT7_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT6_SEND;
          else
            state <= FSM_WRITE_BIT7_SEND;
          end if;

        when FSM_WRITE_BIT6_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT5_SEND;
          else
            state <= FSM_WRITE_BIT6_SEND;
          end if;

        when FSM_WRITE_BIT5_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT4_SEND;
          else
            state <= FSM_WRITE_BIT5_SEND;
          end if;

        when FSM_WRITE_BIT4_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT3_SEND;
          else
            state <= FSM_WRITE_BIT4_SEND;
          end if;

        when FSM_WRITE_BIT3_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT2_SEND;
          else
            state <= FSM_WRITE_BIT3_SEND;
            
          end if;

        when FSM_WRITE_BIT2_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT1_SEND;
          else
            state <= FSM_WRITE_BIT2_SEND;
          end if;

        when FSM_WRITE_BIT1_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_BIT0_SEND;
          else
            state <= FSM_WRITE_BIT1_SEND;
          end if;

        when FSM_WRITE_BIT0_SEND =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_ACK;
          else
            state <= FSM_WRITE_BIT0_SEND;
          end if;

        when FSM_WRITE_ACK =>
          if clk_counter_reg = 33 then
  --          debug_o(2) <= '1';
  --          debug_o(1) <= ack;
            state      <= FSM_WRITE_ACK_READY;
          else
            state <= FSM_WRITE_ACK;
          end if;

        when FSM_WRITE_ACK_READY =>
          if clk_counter_reg = 80 then
            if stop_con_s = '1' then
              state <= FSM_WRITE_STOPCOND;
            else
              state <= FSM_WRITE_IDLE;
            end if;

          end if;

        when FSM_WRITE_STOPCOND =>
          if s_clk_reg = '1' and clk_counter_reg = t8 then
            state <= FSM_WRITE_STOPCOND2;
          else
            state <= FSM_WRITE_STOPCOND;
          end if;

        when FSM_WRITE_STOPCOND2 =>
          if clk_counter_reg = t10 then
            state <= FSM_WRITE_IDLE;
          else
            state <= FSM_WRITE_STOPCOND2;
          end if;
          
          
          
        when others => null;
      end case;

    end if;
  end process fsm_write_p;

  ------------------------------------------------------------------------------

  -- purpose: generates the outputs for p_writ_fsm
  -- type   : combinational
  -- inputs : state, shift_reg
  -- outputs: tri_z_s, tri_data_s

  write_out_p : process (shift_reg, state)
  begin  -- process p_out
    tri_z_s            <= '0';
    tri_data_s         <= '0';
    byte_trans_compl_s <= '0';
    byte_trans_ok_s    <= '0';
    case state is

      when FSM_WRITE_IDLE =>
        --tri_z_s <= '1';
        tri_data_s <= '1';
        
        
        
      when FSM_WRITE_STARTCOND =>
        tri_data_s <= '1';
        
      when FSM_WRITE_STARTCOND2 =>
        tri_data_s <= '0';


      when FSM_WRITE_BIT7_SEND =>
        tri_data_s <= shift_reg(7);
        

      when FSM_WRITE_BIT6_SEND =>
        tri_data_s <= shift_reg(6);
        

      when FSM_WRITE_BIT5_SEND =>
        tri_data_s <= shift_reg(5);
        

      when FSM_WRITE_BIT4_SEND =>
        tri_data_s <= shift_reg(4);
        

      when FSM_WRITE_BIT3_SEND =>
        tri_data_s <= shift_reg(3);
        

      when FSM_WRITE_BIT2_SEND =>
        tri_data_s <= shift_reg(2);
        

      when FSM_WRITE_BIT1_SEND =>
        tri_data_s <= shift_reg(1);
        

      when FSM_WRITE_BIT0_SEND =>
        tri_data_s <= shift_reg(0);
        

      when FSM_WRITE_ACK =>
        tri_z_s <= '1';
        
      when FSM_WRITE_ACK_READY =>
        tri_z_s            <= '1';
        byte_trans_compl_s <= '1';
        byte_trans_ok_s    <= '1';
        

      when FSM_WRITE_STOPCOND =>
        tri_z_s    <= '0';
        tri_data_s <= '0';
        

      when FSM_WRITE_STOPCOND2 =>
        tri_data_s <= '1';
        
        
      when others => null;
    end case;
    
  end process write_out_p;

  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

  -- purpose: FSM for byte send, it generates the configuration bit for th bit
  -- send FSM, whether start_condition and stop_condition must happen or not.
  -- Beside that, it is in charge for sending the standard configuration after
  -- the reset. 
  -- type   : sequential
  -- inputs : clk_i; reset_n_i, we_i, state, byte_trans_ok_s, byte_trans_compl_s
  -- outputs: c_state, shift_reload, data_reg
  fsm_control_p : process (clk_i, reset_n_i)
  begin  -- process p_fsm
    if reset_n_i = '0' then             -- asynchronous reset (active low)
      c_state        <= FSM_CONTROL_IDLE;
      std_conf_count <= 0;
      shift_reload   <= "000";
      ack_ok_reg     <= '0';
      
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      case c_state is
        when FSM_CONTROL_IDLE =>
          if we_i = '1' and state = FSM_WRITE_IDLE then
            data_reg     <= "00110100" & data_i;
            c_state      <= FSM_CONTROL_SEND_1;
            shift_reload <= "001";
          elsif std_conf_count <= 5 and state = FSM_WRITE_IDLE then
            data_reg     <= "00110100" & std_conf_array(std_conf_count);
            c_state      <= FSM_CONTROL_SEND_1;
            shift_reload <= "001";
          else
            c_state <= FSM_CONTROL_IDLE;
          end if;
        when FSM_CONTROL_SEND_1 =>
          if byte_trans_compl_s = '1' and byte_trans_ok_s = '1' then
            ack_ok_reg <= '1';
          end if;
          if state = FSM_WRITE_IDLE and ack_ok_reg = '1' then
            c_state      <= FSM_CONTROL_SEND_2;
            shift_reload <= "010";
            ack_ok_reg   <= '0';
          end if;

        when FSM_CONTROL_SEND_2 =>
          if byte_trans_compl_s = '1' and byte_trans_ok_s = '1' then
            ack_ok_reg <= '1';
          end if;
          if state = FSM_WRITE_IDLE and ack_ok_reg = '1' then
            c_state      <= FSM_CONTROL_SEND_3;
            shift_reload <= "100";
            ack_ok_reg   <= '0';
          end if;

        when FSM_CONTROL_SEND_3 =>
          if byte_trans_compl_s = '1' and byte_trans_ok_s = '1' then
            ack_ok_reg <= '1';
            
          end if;
          if state = FSM_WRITE_IDLE and ack_ok_reg = '1' then
            if std_conf_count < 6 then
              std_conf_count <= std_conf_count + 1;
            end if;
            c_state    <= FSM_CONTROL_WAIT;
            ack_ok_reg <= '0';
          end if;

        when FSM_CONTROL_WAIT =>
          c_state <= FSM_CONTROL_IDLE;

        when others => null;
      end case;
    end if;
  end process fsm_control_p;
  -----------------------------------------------------------------------------

  -- purpose: generates the outputs for fsm_control_p
  -- type   : combinational
  -- inputs : c_state
  -- outputs: i2c_idle_o, send_en_s, start_con_s, stop_con_s, sclk_en_s

  control_out_p : process (c_state)
  begin  -- process p_out
    start_con_s <= '0';
    stop_con_s  <= '0';
    send_en_s   <= '0';
    sclk_en_s   <= '1';
    i2c_idle_o  <= '0';

    case c_state is

      when FSM_CONTROL_IDLE =>
        i2c_idle_o <= '1';

      when FSM_CONTROL_SEND_1 =>
        send_en_s   <= '1';
        start_con_s <= '1';

      when FSM_CONTROL_SEND_2 =>
        send_en_s <= '1';
      when FSM_CONTROL_SEND_3 =>
        stop_con_s <= '1';
        send_en_s  <= '1';
      when others => null;
    end case;
    
  end process control_out_p;




end Rtl;
