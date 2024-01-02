library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.klausur_pack.all;

entity uart_getbaud is

  port (
    clk_i	       : in  std_ulogic;
    res_n_i	       : in  std_ulogic;
    data_i	       : in  std_ulogic;
    start_i	       : in  std_ulogic;
    baud_count_valid_o : out std_ulogic;
    baud_count_o       : out unsigned(19 downto 0);
    baud_count_min_o   : out unsigned(19 downto 0));

end entity uart_getbaud;

architecture klausur of uart_getbaud is
  signal baud_count_reg	       : unsigned(19 downto 0);
  signal baud_count_plus1_s    : unsigned(19 downto 0);
  signal data_change_count_reg : unsigned(3 downto 0);

  signal baud_count_min_reg : unsigned(19 downto 0);

  -- Zwischensignale
  signal data_change_count_next : unsigned(3 downto 0);
  signal baud_count_next_s	: unsigned(19 downto 0);
  signal baud_count_min_next_s	: unsigned(19 downto 0);
  signal baud_count_valid_s	: std_ulogic;

  signal state : fsm_state;
begin
  -----------------------------------------------------------------------------
  -- Assignments
  -----------------------------------------------------------------------------
  baud_count_valid_o	 <= baud_count_valid_s;
  baud_count_min_o	 <= baud_count_min_reg;
  baud_count_plus1_s	 <= baud_count_reg + "1";
  baud_count_o		 <= baud_count_plus1_s;
  data_change_count_next <= data_change_count_reg + "1";

  -----------------------------------------------------------------------------
  state_machine_p : process (clk_i, res_n_i) is
  begin	 -- process state_machine_p
    if res_n_i = '0' then		    -- asynchronous reset (active low)
      state <= FSM_IDLE;
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if state = FSM_IDLE and data_i = '0' then
	state <= FSM_IDLE_LOW;

      elsif state = FSM_IDLE and data_i = '1' then
	state <= FSM_IDLE_HIGH;

      elsif state = FSM_IDLE_LOW and data_i = '1' and baud_count_valid_s = '1' then
	state <= FSM_HIGH;

      elsif state = FSM_IDLE_HIGH and data_i = '0' and baud_count_valid_s = '1' then
	state <= FSM_LOW;

      elsif state = FSM_LOW and data_i = '1' and baud_count_valid_s = '1' then
	state <= FSM_HIGH;

      elsif state = FSM_HIGH and data_i = '1' and baud_count_valid_s = '1' then
	state <= FSM_LOW;
      elsif start_i = '1' then
	state <= FSM_IDLE;
      end if;
    end if;
  end process state_machine_p;
  -----------------------------------------------------------------------------
  baud_valid_p : process (data_change_count_reg, start_i, state) is
  begin	 -- process baud_valid_p
    baud_count_valid_s <= '0';
    if (state = FSM_HIGH or state = FSM_LOW) and data_change_count_reg = X"F" then
      baud_count_valid_s <= '1';
    end if;
    
    if start_i = '1' then
      baud_count_valid_s <= '0';
    end if;
  end process baud_valid_p;
  -------------------------------------------------------------------------------

  count_baud_p : process (clk_i, res_n_i) is
  begin	 -- process count_baud_p
    if res_n_i = '0' then		-- asynchronous reset (active low)
      baud_count_reg <= X"FFFFE";

    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      baud_count_reg <= baud_count_plus1_s;
      if baud_count_reg = X"FFFFE" then	    -- Oveflow Not
	baud_count_reg <= X"FFFFE";
      end if;

      if data_change_count_reg = X"F" then
	baud_count_reg <= (others => '0');
      end if;

      if start_i = '1' then
	baud_count_reg <= X"FFFFE";
      end if;
    end if;
  end process count_baud_p;
  -----------------------------------------------------------------------------

  change_p : process (clk_i, res_n_i) is
  begin	 -- process change_p
    if res_n_i = '0' then		    -- asynchronous reset (active low)
      --data_change_count_next <= (others => '0');
      data_change_count_reg <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      data_change_count_reg <= X"0";

      if (state = FSM_IDLE_LOW or state = FSM_LOW) and data_i = '1' then  -- Wechsel
	data_change_count_reg <= data_change_count_next;
      end if;

      if (state = FSM_IDLE_HIGH or state = FSM_HIGH) and data_i = '0' then
	data_change_count_reg <= data_change_count_next;
      end if;
    end if;
  end process change_p;

  -----------------------------------------------------------------------------
  baud_count_min : process (clk_i, res_n_i) is
  begin	 -- process
    if res_n_i = '0' then		    -- asynchronous reset (active low)
      baud_count_min_reg <= X"FFFFF";
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if ((state = FSM_HIGH or state = FSM_LOW) and data_change_count_reg = X"F" and baud_count_plus1_s < baud_count_min_reg) then
	baud_count_min_reg <= baud_count_plus1_s;
      end if;
      if (start_i = '1') then
	baud_count_min_reg <= X"FFFFF";
      end if;
    end if;
  end process baud_count_min;
-----------------------------------------------------------------------------
end architecture;
