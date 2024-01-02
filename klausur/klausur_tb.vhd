library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std_developerskit;
use std_developerskit.std_iopak.all;

entity uart_tb is

end uart_tb;

architecture beh of uart_tb is
  component uart_getbaud
    port (
      clk_i		 : in  std_ulogic;
      res_n_i		 : in  std_ulogic;
      data_i		 : in  std_ulogic;
      start_i		 : in  std_ulogic;
      baud_count_valid_o : out std_ulogic;
      baud_count_o	 : out unsigned(19 downto 0);
      baud_count_min_o	 : out unsigned(19 downto 0));
  end component;
  signal clk		      : std_ulogic := '0';
  signal end_clk	      : boolean	   := false;  -- stop clock if TRUE
  signal res_n		      : std_ulogic := '0';
  signal data		      : std_ulogic;
  signal start		      : std_ulogic;
  signal baud_count_valid_dut : std_ulogic;
  signal baud_count_dut	      : unsigned(19 downto 0);
  signal baud_count_min_dut   : unsigned(19 downto 0);
  signal baud_count_valid_exp : std_ulogic;
  signal baud_count_exp	      : unsigned(19 downto 0);
  signal baud_count_min_exp   : unsigned(19 downto 0);

  signal   testcase_number_s : integer := 0;  -- to recognize testnumber in waveform
  constant clk_frequ	     : integer := 50E6;	 -- 50 MHz
  
begin  -- beh

  dut : uart_getbaud
    port map (
      clk_i		 => clk,
      res_n_i		 => res_n,
      data_i		 => data,
      start_i		 => start,
      baud_count_valid_o => baud_count_valid_dut,
      baud_count_o	 => baud_count_dut,
      baud_count_min_o	 => baud_count_min_dut);

  clk_p : process
  begin	 -- process clk_p
    wait for (1 sec/clk_frequ);
    if end_clk then
      wait;
    else
      clk <= not clk;
    end if;
  end process clk_p;

  wave_gen_p : process
    -- parameters to controle procedure
    variable baud_rate_v	 : integer := 500000;
    variable num_bauds_v	 : integer := 1;
    variable noise_clk_cnt_1st_v : integer := 16#FFFFF#;
    variable noise_clk_width_v	 : integer := 1;
    variable noise_clk_silent_v	 : integer := 15;
    variable noise_count_v	 : integer := 0;
    variable toggle_data_v	 : boolean := true;  -- toggle data in procedure stim_baud_proc
    variable init_active_v	 : boolean := true;
    variable init_active_clk1_v	 : boolean := true;

    procedure stim_baud_proc is
      variable work_clk_count_v		  : integer := num_bauds_v * (clk_frequ / baud_rate_v);
      variable work_noise_clk_cnt_1st_v	  : integer := noise_clk_cnt_1st_v;
      variable work_noise_clk_width_v	  : integer := -1;
      variable work_noise_clk_silent_v	  : integer := -1;
      variable work_noise_count_v	  : integer := noise_count_v;
      variable data_save_v, data_target_v : std_ulogic;
      variable tmp_count_v		  : integer := 16#10#;
    begin
      data_save_v   := data;
      data_target_v := data;
      if toggle_data_v then
	data_target_v := not data;
	data	      <= not data;
      end if;
      for i in 1 to work_clk_count_v loop
	if init_active_clk1_v then
	  -- 1st clock cycle is ignored...
	  wait until rising_edge(clk);
	  init_active_clk1_v := false;
	  data_save_v	     := data;
	else
	  baud_count_valid_exp <= '0';
	  if (not(init_active_v) and baud_count_exp /= X"FFFFF") then
	    baud_count_exp <= baud_count_exp + X"00001";
	  end if;
	  if data = data_save_v then
	    
	    tmp_count_v := 16#10#;
	  else
	    tmp_count_v := tmp_count_v-1;
	  end if;
	  if tmp_count_v = 1 then
	    if init_active_v then
	      init_active_v := false;
	    else
	      baud_count_valid_exp <= '1';
	      if baud_count_min_exp > baud_count_exp then
		baud_count_min_exp <= baud_count_exp+1;
	      end if;
	    end if;
	  elsif tmp_count_v = 0 then
	    baud_count_exp <= (0 => '1', others => '0');
	  end if;
	  if i < work_clk_count_v then

	    -- noise handling
	    if work_noise_count_v > 0 then
	      if work_noise_clk_cnt_1st_v = i then
		data		       <= data_save_v;
		work_noise_clk_width_v := noise_clk_width_v-1;
	      end if;
	      if work_noise_clk_width_v = 0 then
		data			<= not data_save_v;
		work_noise_count_v	:= work_noise_count_v-1;
		work_noise_clk_silent_v := noise_clk_silent_v-1;
		work_noise_clk_width_v	:= -1;
	      elsif work_noise_clk_width_v > 0 then
		work_noise_clk_width_v := work_noise_clk_width_v-1;
	      else
		if work_noise_clk_silent_v = 0 then
		  data			  <= data_save_v;
		  work_noise_clk_width_v  := noise_clk_width_v-1;
		  work_noise_clk_silent_v := -1;
		elsif work_noise_clk_silent_v > 0 then
		  work_noise_clk_silent_v := work_noise_clk_silent_v-1;
		end if;
	      end if;
	    end if;
	    -- noise handling end
	    
	  else
	    -- last clock cycle set data to expected value no matter what noise
	    -- operations were executed
	    data <= data_target_v;
	  end if;
	  wait until rising_edge(clk);
	end if;	 -- else branch of "if init_active_clk1_v then"
      end loop;	 -- i
    end;


    procedure restart_baud_count is
    begin
      start		   <= '1';
      init_active_v	   := true;
      baud_count_exp	   <= baud_count_exp+X"00001";
      baud_count_min_exp   <= (others => '1');
      wait until rising_edge(clk);
      start		   <= '0';
      baud_count_exp	   <= (others => '1');
      baud_count_valid_exp <= '0';
    end;

    procedure reset_proc is
    begin
      res_n		   <= '0';
      init_active_v	   := true;
      init_active_clk1_v   := true;
      baud_count_min_exp   <= (others => '1');
      baud_count_exp	   <= (others => '1');
      baud_count_valid_exp <= '0';
      -- reset for 2 clock cycles
      for i in 1 to 2 loop
	wait until rising_edge(clk);
      end loop;	 -- i
      res_n <= '1';
    end;
    
    
    
  begin	 -- process wave_gen_p
    data  <= '1';
    start <= '0';
    reset_proc;

    -- wait for very short short period
    baud_rate_v	  := 5000000;		-- 5_000_000 bauds (just for start...)
    toggle_data_v := false;    -- don't toggle data-signal for next baud
    num_bauds_v	  := 1;
    stim_baud_proc;

    -- test case 1: toggle data to 0 and transfer then 3 bits
    testcase_number_s <= 1;
    baud_rate_v	      := 500000;  -- 500_000 bauds - high baud rate to have
    -- short simulation time...
    toggle_data_v     := true;
    num_bauds_v	      := 3;
    stim_baud_proc;

    -- test case 2: toggle data to 1 and transfer then 5 bits
    testcase_number_s <= 2;
    num_bauds_v	      := 5;
    stim_baud_proc;

    -- test case 3: toggle data to 0 and transfer then 2 bits
    testcase_number_s <= 3;
    num_bauds_v	      := 2;
    stim_baud_proc;

    -- test case 4: toggle data to 1 and transfer then 2 bits
    -- at beginning of transfer insert 3 noise pulses (are supposed to be filtered by DUT)
    testcase_number_s	<= 4;
    noise_clk_cnt_1st_v := 5;
    noise_clk_width_v	:= 14;
    noise_clk_silent_v	:= 14;
    noise_count_v	:= 3;

    num_bauds_v := 2;
    stim_baud_proc;

    -- test case 5: toggle data to 0 and transfer then 5 bits - noise
    -- parameters are simply deactivated again by following settings
    testcase_number_s	<= 5;
    noise_clk_cnt_1st_v := 16#FFFFF#;
    noise_clk_width_v	:= 1;
    noise_clk_silent_v	:= 15;
    noise_count_v	:= 0;

    -- test case 6: toggle data to 1 and transfer 5 bits
    testcase_number_s <= 6;
    num_bauds_v	      := 5;
    stim_baud_proc;

    -- test case 7: toggle data to 0 and transfer 1 bit (new min-value...)
    testcase_number_s <= 7;
    num_bauds_v	      := 1;
    stim_baud_proc;

    -- test case 8: toggle data to 1 and transfer 2 bits (dummy transfer,
    -- because test case 7 needs change of data to generate new min-value...)
    testcase_number_s <= 8;
    num_bauds_v	      := 2;
    stim_baud_proc;

    -- test case 10: reset again and check, that idle is first entered before
    -- getting into idle_low
    testcase_number_s <= 9;
    reset_proc;

    num_bauds_v := 1;
    stim_baud_proc;
    num_bauds_v := 2;			-- time will now be measured...
    stim_baud_proc;
    num_bauds_v := 1;  			-- we need 16 more clock cycles to get
					-- new baud_min_value...
    stim_baud_proc;


    -- test case 20: change baudrate to 9600 and restart recording
    testcase_number_s <= 20;
    num_bauds_v	      := 2;
    data	      <= '1';
    restart_baud_count;
    -- toggle data immediately
    data	      <= '0';
    toggle_data_v     := false;	 -- don't toggle it again in stim_baud_proc
    wait until rising_edge(clk);
    baud_rate_v	      := 9600;		-- new baud rate...
    stim_baud_proc;
    toggle_data_v     := true;

    -- test case 21: transfer 3 bits (data=1) - first counting case
    testcase_number_s <= 21;
    num_bauds_v	      := 4;
    stim_baud_proc;

    -- test case 22: transfer 2 bits (data=0) - second counting case
    testcase_number_s <= 22;
    num_bauds_v	      := 2;
    stim_baud_proc;

    -- test case 23: transfer 1 bit (data=1) - third counting case
    testcase_number_s <= 23;
    num_bauds_v	      := 1;
    stim_baud_proc;

    -- test case 24: transfer 202 bits (data=0) - overflow of baudcounter...
    testcase_number_s <= 24;
    num_bauds_v	      := 202;
    stim_baud_proc;

    -- test case 25: transfer 1 bit (data=0) - simply to inserted to finish
    --		     case 12
    testcase_number_s <= 25;
    num_bauds_v	      := 1;
    stim_baud_proc;

    end_clk <= true;
    wait;
  end process wave_gen_p;

  -- purpose: check DUT signals
  -- type   : sequential
  check_sig_p : process (clk, res_n)
  begin	 -- process check_sig_p
    if res_n = '0' then			-- asynchronous reset (active low)
      null;
    elsif clk'event and clk = '1' then	-- rising clock edge
      assert baud_count_exp = baud_count_dut report "baud count value mismatch (expected: " & To_String(to_integer(baud_count_exp), "%X")
	& "; actual: " & To_String(to_integer(baud_count_dut), "%X") & ")" severity error;
      assert baud_count_min_exp = baud_count_min_dut report "minimum baud count value mismatch (expected: " & To_String(to_integer(baud_count_min_exp), "%X")
	& "; actual: " & To_String(to_integer(baud_count_min_dut), "%X") & ")" severity error;
      if baud_count_valid_exp = '1' then
	assert baud_count_valid_exp = baud_count_valid_dut report "baud_count_valid_dut signal wrong (expected: 1; actual: 0)" severity error;
      else
	assert baud_count_valid_exp = baud_count_valid_dut report "baud_count_valid_dut signal wrong (expected: 0; actual: 1)" severity error;
      end if;
    end if;
  end process check_sig_p;
  
end beh;
