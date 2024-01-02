library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.klausur_package.all;


entity uart_getbaud is

   port (
      clk_i		 : in  std_ulogic;
      res_n_i		 : in  std_ulogic;
      data_i		 : in  std_ulogic;
      start_i		 : in  std_ulogic;
      baud_count_valid_o : out std_ulogic;
      baud_count_o	 : out unsigned(19 downto 0);
      baud_count_min_o	 : out unsigned(19 downto 0));

end entity uart_getbaud;


architecture uart_getbaud_arch of uart_getbaud is

   signal data_chg_count_next	: unsigned(3 downto 0);
   signal data_chg_count_reg	: unsigned(3 downto 0);
   signal baud_count_min_next_s : unsigned(19 downto 0);
   signal baud_count_min_reg	: unsigned(19 downto 0);
   signal baud_count_reg	: unsigned(19 downto 0);
   signal baud_count_plus1_s	: unsigned(19 downto 0);
   signal baud_count_next_s	: unsigned(19 downto 0);
   signal baud_count_valid_s	: std_ulogic;
   signal state			: fsm_t;

begin  -- architecture uart_getbaud_arch
   baud_count_min_o    <= baud_count_min_reg;
   baud_count_plus1_s  <= baud_count_reg + "1";
   baud_count_o	       <= baud_count_plus1_s;
   baud_count_valid_o  <= baud_count_valid_s;
   data_chg_count_next <= data_chg_count_reg + 1;

   -- purpose: muuh
   -- type   : sequential
   -- inputs : clk_i, res_n_i
   -- outputs: 
   fsm_process : process (clk_i, res_n_i) is
   begin  -- process fsm_process
      if res_n_i = '0' then		-- asynchronous reset (active low)
	 state <= FSM_IDLE;
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge
	 if(start_i = '1') then
	    state <= FSM_IDLE;
	 else
	    if(state = FSM_IDLE and data_i = '1') then
	       state <= FSM_IDLE_HIGH;
	    elsif (state = FSM_IDLE and data_i = '0') then
	       state <= FSM_IDLE_LOW;
	    end if;

	    if(state = FSM_IDLE_HIGH and data_i = '0' and data_chg_count_reg = X"F") then
	       state <= FSM_LOW;
	    elsif (state = FSM_IDLE_LOW and data_i = '1' and data_chg_count_reg = X"F") then
	       state <= FSM_HIGH;
	    end if;

	    if(state = FSM_HIGH and data_i = '0' and data_chg_count_reg = X"F") then
	       state <= FSM_LOW;
	    elsif (state = FSM_LOW and data_i = '1' and data_chg_count_reg = X"F") then
	       state <= FSM_HIGH;
	    end if;
	 end if;
      end if;
   end process fsm_process;


   data_chg_count_next_reg : process (clk_i, res_n_i) is
   begin  -- process data_chg_count_reg
      if res_n_i = '0' then		-- asynchronous reset (active low)
	 data_chg_count_reg <= X"0";
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge
	 data_chg_count_reg <= X"0";
	 if((state = FSM_IDLE_LOW or state = FSM_LOW) and data_i = '1') then
	    data_chg_count_reg <= data_chg_count_next;
	 end if;
	 if((state = FSM_IDLE_HIGH or state = FSM_HIGH) and data_i = '0') then
	    data_chg_count_reg <= data_chg_count_next;
	 end if;
      end if;
   end process data_chg_count_next_reg;

   baud_count_valid_o_reg : process(state, data_chg_count_reg, start_i) is
   begin  -- process baud_count_valid_o_reg
      baud_count_valid_s <= '0';
      if (state = FSM_LOW or state = FSM_HIGH) and data_chg_count_reg = X"F" then
	 baud_count_valid_s <= '1';
      end if;
      if start_i = '1' then
	 baud_count_valid_s <= '0';
      end if;
   end process baud_count_valid_o_reg;

   baud_count_next_s_reg : process (clk_i, res_n_i) is
   begin  -- process baud_count_next_s_reg
      if res_n_i = '0' then		-- asynchronous reset (active low)
	 baud_count_reg <= X"FFFFE";
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge
	 baud_count_reg <= baud_count_plus1_s;
	 if(baud_count_reg = X"FFFFE" or start_i = '1') then
	    baud_count_reg <= X"FFFFE";
	 end if;
	 if(data_chg_count_reg = X"F") then
	    baud_count_reg <= X"00000";
	 end if;
      end if;
   end process baud_count_next_s_reg;

   baud_count_min_next_s_reg : process (clk_i, res_n_i) is
      begin  -- process
      if res_n_i = '0' then -- asynchronous reset (active low)
	 baud_count_min_reg <= X"FFFFF";
      elsif clk_i'event and clk_i = '1' then  -- rising clock edge
	 if ((state = FSM_HIGH or state = FSM_LOW) and data_chg_count_reg = X"F" and baud_count_plus1_s < baud_count_min_reg) then
	    baud_count_min_reg <= baud_count_plus1_s;
	 end if;
	 if(start_i = '1') then
	    baud_count_min_reg <= X"FFFFF";
	 end if;
      end if;
   end process baud_count_min_next_s_reg;

end architecture uart_getbaud_arch;
