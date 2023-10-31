-------------------------------------------------------------------------------
-- Title      : sram controler - top level test bench
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : sram_controler_tb.vhd
-- Author     : Rabe
-- Company    : 
-- Created    : 2014-12-28
-- Last update: 2017-11-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: a few write/read cycles with memory model
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2014-12-28  1.0	Rabe	Created
-------------------------------------------------------------------------------

library ieee;
library std_developerskit;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std_developerskit.std_iopak.all;

-------------------------------------------------------------------------------

entity sram_controler_tb is

end sram_controler_tb;

-------------------------------------------------------------------------------

architecture tb1 of sram_controler_tb is

  component sram_controler
    port (
      clk_i		     : in    std_ulogic;
      reset_n_i		     : in    std_ulogic;
      audio_data_i	     : in    std_ulogic_vector(23 downto 0);
      srctr_data_o	     : out   std_ulogic_vector(23 downto 0);
      fsm_start_addr_i	     : in    std_ulogic_vector(18 downto 0);
      fsm_we_i		     : in    std_ulogic;
      fsm_re_i		     : in    std_ulogic;
      srctr_idle_o	     : out   std_ulogic;
      srctr_end_addr_plus1_o : out   std_ulogic_vector(18 downto 0);
      srctr_we_reg_n_o	     : out   std_ulogic;
      srctr_ce_n_o	     : out   std_ulogic;
      srctr_oe_reg_n_o	     : out   std_ulogic;
      srctr_lb_n_o	     : out   std_ulogic;
      srctr_ub_n_o	     : out   std_ulogic;
      srctr_addr_reg_o	     : out   std_ulogic_vector(18 downto 0);
      mem_data_b	     : inout std_logic_vector(15 downto 0));
  end component;

  component sram
    generic (
      Size : natural;
      Name : string);
    port (
      sram_addr_i : in	  std_ulogic_vector(17 downto 0);
      sram_dq_io  : inout std_logic_vector(15 downto 0);
      sram_ce_n_i : in	  std_ulogic;
      sram_we_n_i : in	  std_ulogic;
      sram_oe_n_i : in	  std_ulogic;
      sram_ub_n_i : in	  std_ulogic;
      sram_lb_n_i : in	  std_ulogic);
  end component;


  -- component ports
  signal reset_n	      : std_ulogic;
  signal audio_data	      : std_ulogic_vector(23 downto 0);
  signal fsm_start_addr	      : std_ulogic_vector(18 downto 0);
  signal fsm_we		      : std_ulogic;
  signal fsm_re		      : std_ulogic;
  signal srctr_data	      : std_ulogic_vector(23 downto 0);
  signal srctr_idle	      : std_ulogic;
  signal srctr_end_addr_plus1 : std_ulogic_vector(18 downto 0);
  signal srctr_we_reg_n	      : std_ulogic;
  signal srctr_ce_n	      : std_ulogic;
  signal srctr_oe_reg_n	      : std_ulogic;
  signal srctr_lb_n	      : std_ulogic;
  signal srctr_ub_n	      : std_ulogic;
  signal srctr_addr_reg	      : std_ulogic_vector(18 downto 0);
  signal mem_data	      : std_logic_vector(15 downto 0);

  signal clk : std_logic := '1';

  type audio_data_stim_t is array (natural range <>) of std_ulogic_vector(23 downto 0);
  constant audio_data_stim_c : audio_data_stim_t(2 downto 0) :=
    (X"01_FE_03",
     X"00_55_01",
     X"FD_00_FB");
  constant audio_data_dummy_c : std_ulogic_vector(23 downto 0) := X"AA_AA_AA";

  signal test_case_count : integer := 0;

begin  -- tb1

  -- component instantiation
  DUT : sram_controler
    port map (
      clk_i		     => clk,
      reset_n_i		     => reset_n,
      audio_data_i	     => audio_data,
      srctr_data_o	     => srctr_data,
      fsm_start_addr_i	     => fsm_start_addr,
      fsm_we_i		     => fsm_we,
      fsm_re_i		     => fsm_re,
      srctr_idle_o	     => srctr_idle,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1,
      srctr_we_reg_n_o	     => srctr_we_reg_n,
      srctr_ce_n_o	     => srctr_ce_n,
      srctr_oe_reg_n_o	     => srctr_oe_reg_n,
      srctr_lb_n_o	     => srctr_lb_n,
      srctr_ub_n_o	     => srctr_ub_n,
      srctr_addr_reg_o	     => srctr_addr_reg,
      mem_data_b	     => mem_data);

  sram_1 : sram
    generic map (
      Size => 2**18,
      Name => "NULL")
    port map (
      sram_addr_i => srctr_addr_reg(srctr_addr_reg'high downto 1),
      sram_dq_io  => mem_data,
      sram_ce_n_i => srctr_ce_n,
      sram_we_n_i => srctr_we_reg_n,
      sram_oe_n_i => srctr_oe_reg_n,
      sram_ub_n_i => srctr_ub_n,
      sram_lb_n_i => srctr_lb_n);

-- clock generation
  clk <= not clk after 10 ns;

-- reset generation
  reset_p : process
  begin	 -- process reset_p
    reset_n <= '0';
    wait for 45 ns;
    reset_n <= '1';
    wait;
  end process reset_p;


  -- waveform generation
  WaveGen_Proc : process
    -- procedure overview:
    -- write_proc:
    --	 without params: mainly to be used as internal procedure
    --	 with 2 params:
    --	   1st param: data to be written
    --	   2nd param: start-address
    --	 with 4 params:
    --	   remark: first 2 params belong to previous memory-access, which are
    --	   checked after 1st clock edge
    --	   1st param: expected data at sram-controler-output (all 'X' not checked)
    --	   2nd param: expected end-address
    --	   3rd param: data to be written
    --	   4th param: start-address
    --	   note: 1st and 2nd param are checked before writing
    -- read_proc:
    --	 without params: mainly to be used as internal procedure
    --	 with 1 param:
    --	   1st param: start-address
    --	 with 3 params:
    --	   remark: first 2 params belong to previous memory-access, which are
    --	   checked after 1st clock edge
    --	   1st param: expected data at sram-controler-output (all 'X' not checked)
    --	   2nd param: expected end-address
    --	   3rd param: start-address
    --	   note: 1st and 2nd param are checked before reading
    -- add_idle_cycles:
    --	 adds idle cycles without memory access
    --	 3 parameteres are used:
    --	   remark: first 2 params belong to previous memory-access, which are
    --	   checked after 1st clock edge
    --	   1st param: expected data at sram-controler-output (all 'X' not checked)
    --	   2nd param: expected end-address
    --	   3rd param: number of idle cycles
    type stim_we_re_t is (stim_nothing, stim_we, stim_re, stim_both);  -- stimulate we/re when hardware shall ignore it
    variable stim_we_re_v : stim_we_re_t := stim_nothing;
    procedure stim_we_re_p is
    begin
      case stim_we_re_v is
	when stim_nothing => fsm_we <= '0'; fsm_re <= '0';
	when stim_we	  => fsm_we <= '1'; fsm_re <= '0';
	when stim_re	  => fsm_we <= '0'; fsm_re <= '1';
	when stim_both	  => fsm_we <= '1'; fsm_re <= '1';
      end case;
      audio_data <= audio_data_dummy_c;	 -- audio_data shall be ignored
    end stim_we_re_p;

    function calc_stable_time_f (
      constant clk_cycles : integer)
      return time is
    begin
      return (20 ns) * clk_cycles - (19 ns);
    --case clk_cycles is
    --	when 2	    => return 21 ns;
    --	when 3	    => return 41 ns;
    --	when others => return 0 ns;
    --end case;
    end calc_stable_time_f;

    procedure myassert_stable_p (constant clk_cycles : in integer; constant num_sigs : in integer) is
    begin  -- myassert_p
      case clk_cycles is
	when 2 =>
	  assert srctr_addr_reg'stable(calc_stable_time_f(2)) report "srctr_addr_reg wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  assert srctr_lb_n'stable(calc_stable_time_f(2)) report "srctr_lb_n wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  assert srctr_ub_n'stable(calc_stable_time_f(2)) report "srctr_ub_n wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  if num_sigs > 3 then
	    assert mem_data'stable(calc_stable_time_f(2)) report "mem_data wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  end if;
	when 3 =>
	  assert srctr_addr_reg'stable(calc_stable_time_f(3)) report "srctr_addr_reg wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  assert srctr_lb_n'stable(calc_stable_time_f(3)) report "srctr_lb_n wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  assert srctr_ub_n'stable(calc_stable_time_f(3)) report "srctr_ub_n wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  if num_sigs > 3 then
	    assert mem_data'stable(calc_stable_time_f(3)) report "mem_data wasn't stable for last " & To_String(clk_cycles, "%i") & " clock cycles" severity error;
	  end if;
	when others => null;
      end case;
    end myassert_stable_p;

    procedure myassert_p (
      constant srctr_idle_exp, srctr_we_reg_n_exp, srctr_oe_reg_n_exp : in std_ulogic) is
    begin  -- myassert_p
      if srctr_idle_exp = '1' then
	assert srctr_idle = srctr_idle_exp report "srctrl_idle: sram controler should be idle" severity error;
      else
	assert srctr_idle = srctr_idle_exp report "srctrl_idle: sram controler should not be idle" severity error;
      end if;
      assert srctr_we_reg_n = srctr_we_reg_n_exp report "srctr_we_reg_n_o: signal wrong (expected: " & To_String(srctr_we_reg_n_exp, "%1s") &")" severity error;
      assert srctr_oe_reg_n = srctr_oe_reg_n_exp report "srctr_oe_reg_n_o: signal wrong (expected: " & To_String(srctr_oe_reg_n_exp, "%1s") &")" severity error;
    end myassert_p;

    procedure myassert_p (
      constant srctr_idle_exp, srctr_we_reg_n_exp, srctr_oe_reg_n_exp, srctr_ce_n_exp : in std_ulogic) is
    begin  -- myassert_p
      if srctr_ce_n_exp = '0' then
	assert srctr_ce_n = srctr_ce_n_exp report "srctrl_ce_n: chip enable hast to be 0 - but is not" severity error;
      end if;
      myassert_p(srctr_idle_exp	    => srctr_idle_exp,
		 srctr_we_reg_n_exp => srctr_we_reg_n_exp,
		 srctr_oe_reg_n_exp => srctr_oe_reg_n_exp);
    end myassert_p;

    procedure write_proc is
    begin
      -- STATE=IDLE, WRITE_MEM_33 or READ_MEM_33 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '1', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      myassert_stable_p(3,3);  		-- no signal changes durch past 2 clock
					-- cycles...
      stim_we_re_p;
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_11 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_12 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '0', srctr_oe_reg_n_exp => '1', srctr_ce_n_exp => '0');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_13 (changing in next delta cycle)
      myassert_stable_p(3,4);
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_21 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_22 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '0', srctr_oe_reg_n_exp => '1', srctr_ce_n_exp => '0');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_23 (changing in next delta cycle)
      myassert_stable_p(3,4);
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_31 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=WRITE_MEM_32 (changing in next delta cycle)
      myassert_stable_p(2,4);
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '0', srctr_oe_reg_n_exp => '1', srctr_ce_n_exp => '0');
--wait until clk'event and clk = '1';
      -- now we need to deassert fsm_we and fsm_re
      fsm_we <= '0'; fsm_re <= '0';
    end write_proc;  -- 24 bit of data to be written
    procedure write_proc (
      constant data_param	    : in std_ulogic_vector(23 downto 0);
      constant fsm_start_addr_param : in std_ulogic_vector(18 downto 0)) is
    begin
      fsm_we	     <= '1';
      fsm_re	     <= '0';
      fsm_start_addr <= fsm_start_addr_param;
      audio_data     <= data_param;
      wait until clk'event and clk = '1';
      write_proc;
    end write_proc;  -- 24 bit of data to be written
    procedure write_proc (
      constant check_data_param	    : in std_ulogic_vector(23 downto 0);
      constant check_addr_param	    : in std_ulogic_vector(18 downto 0);
      constant data_param	    : in std_ulogic_vector(23 downto 0);
      constant fsm_start_addr_param : in std_ulogic_vector(18 downto 0)) is
      constant data_x_c : std_ulogic_vector(check_data_param'range) := (others => 'X');
    begin
      fsm_we	     <= '1';
      fsm_re	     <= '0';
      fsm_start_addr <= fsm_start_addr_param;
      audio_data     <= data_param;
      wait until clk'event and clk = '1';
      assert srctr_end_addr_plus1 = check_addr_param report "srctr_end_addr_plus1 :  wrong address (expected: " & To_String(to_integer(unsigned(check_addr_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_end_addr_plus1)), "%X") & ")" severity error;
      if check_data_param /= data_x_c then
	assert srctr_data = check_data_param report "srctr_data :  wrong data (expected: " & To_String(to_integer(unsigned(check_data_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
      end if;
      write_proc;
    end write_proc;  -- 24 bit of data to be written
    procedure read_proc is
    begin
      -- STATE=IDLE, WRITE_MEM_33 or READ_MEM_33 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '1', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      myassert_stable_p(3,3);  		-- no signal changes durch past 2 clock
					-- cycles...
      stim_we_re_p;
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_11 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_12 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '0', srctr_ce_n_exp => '0');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_13 (changing in next delta cycle)
      myassert_stable_p(3,3);
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_21 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_22 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '0', srctr_ce_n_exp => '0');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_23 (changing in next delta cycle)
      myassert_stable_p(3,3);
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_31 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '1');
      wait until clk'event and clk = '1';
      -- STATE=READ_MEM_32 (changing in next delta cycle)
      myassert_p(srctr_idle_exp => '0', srctr_we_reg_n_exp => '1', srctr_oe_reg_n_exp => '0', srctr_ce_n_exp => '0');
      myassert_stable_p(2,3);
--wait until clk'event and clk = '1';

      -- now we need to deassert fsm_we and fsm_re
      fsm_we <= '0'; fsm_re <= '0';
    -- read 3rd byte and start read from address 0 after next rising edge
    end read_proc;  -- 24 bit of data to be written
    procedure read_proc (
      constant fsm_start_addr_param : in std_ulogic_vector(18 downto 0)) is
    begin
      fsm_start_addr <= fsm_start_addr_param;
      fsm_we	     <= '0';
      fsm_re	     <= '1';
      wait until clk'event and clk = '1';
      read_proc;
    end read_proc;  -- 24 bit of data to be written
    procedure read_proc (
      constant check_data_param	    : in std_ulogic_vector(23 downto 0);
      constant check_addr_param	    : in std_ulogic_vector(18 downto 0);
      constant fsm_start_addr_param : in std_ulogic_vector(18 downto 0)) is
      constant data_x_c : std_ulogic_vector(check_data_param'range) := (others => 'X');
    begin
      fsm_start_addr <= fsm_start_addr_param;
      fsm_we	     <= '0';
      fsm_re	     <= '1';
      wait until clk'event and clk = '1';
      assert srctr_end_addr_plus1 = check_addr_param report "srctr_end_addr_plus1 :  wrong address (expected: " & To_String(to_integer(unsigned(check_addr_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_end_addr_plus1)), "%X") & ")" severity error;
      if check_data_param /= data_x_c then
	assert srctr_data = check_data_param report "srctr_data :  wrong data (expected: " & To_String(to_integer(unsigned(check_data_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
      end if;
      read_proc;
    end read_proc;  -- 24 bit of data to be written
    procedure add_idle_cycles (
      constant check_data_param : in std_ulogic_vector(23 downto 0);
      constant check_addr_param : in std_ulogic_vector(18 downto 0);
      constant idle_cycles	: in integer) is
      constant data_x_c : std_ulogic_vector(check_data_param'range) := (others => 'X');
    begin
      for i in 1 to idle_cycles loop
	wait until clk'event and clk = '1';
	assert srctr_idle = '1' report "srctrl_idle: sram controler should be idle" severity error;
	assert srctr_end_addr_plus1 = check_addr_param report "srctr_end_addr_plus1 :  wrong address (expected: " & To_String(to_integer(unsigned(check_addr_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_end_addr_plus1)), "%X") & ")" severity error;
	if check_data_param /= data_x_c then
	  assert srctr_data = check_data_param report "srctr_data :  wrong data (expected: " & To_String(to_integer(unsigned(check_data_param)), "%X") & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
	end if;
      end loop;	 -- loop
    end add_idle_cycles;
  begin
    -- insert signal assignments here
    audio_data	    <= (others => '0');
    fsm_start_addr  <= (others => '0');
    fsm_we	    <= '0';
    fsm_re	    <= '0';
    wait until reset_n = '0';
    wait until reset_n = '1';
    test_case_count <= 16#00_00#;
    --		    exp.data-output,exp.adr+1,	   #clk cycles
    add_idle_cycles((others    => 'X'), B"000"&X"0000", 2);

    -- testcase #1: write to even address + idle cycles afterwards
    test_case_count <= 16#01_00#; stim_we_re_v := stim_nothing;
    --	       data		   ,start-adr
    write_proc(audio_data_stim_c(0), (others => '0'));
    test_case_count <= 16#01_01#;
    --		    exp.data-output,exp.adr+1,		       #clk cycles
    add_idle_cycles((others		     => 'X'), B"000_0000_0000_0000_0011", 2);
--
    -- testcase#2: write to odd address + immediate read to even address afterwards
    --		   + immediate write to even address
    test_case_count <= 16#02_00#; stim_we_re_v := stim_both;
    --	       data		   ,start-adr
    write_proc(audio_data_stim_c(1), B"000"&X"0003");
    test_case_count <= 16#02_01#; stim_we_re_v := stim_re;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc((others => 'X'), B"000_0000_0000_0000_0110",
	      (others => '0'));
    test_case_count <= 16#02_02#; stim_we_re_v := stim_we;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       data		    , start-adr
    write_proc(audio_data_stim_c(0), B"000_0000_0000_0000_0011",
	       audio_data_stim_c(2), B"000_0000_0000_0000_0110");
    test_case_count <= 16#02_03#; stim_we_re_v := stim_both;
    --		    exp.data-output,exp.adr+1,		       #clk cycles
    add_idle_cycles((others => 'X'), B"000_0000_0000_0000_1001", 2);
--
    -- testcase#3: read all data with and without idle cycles
    test_case_count <= 16#03_00#; stim_we_re_v := stim_we;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc((others => 'X'), B"000_0000_0000_0000_1001",
	      (others => '0'));
    test_case_count <= 16#03_01#; stim_we_re_v := stim_re;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(0), B"000_0000_0000_0000_0011",
	      B"000_0000_0000_0000_0011");
    test_case_count <= 16#03_02#;
    --		    exp.data-output,	 exp.adr+1,		    #clk cycles
    add_idle_cycles(audio_data_stim_c(1), B"000_0000_0000_0000_0110", 2);
    test_case_count <= 16#03_03#; stim_we_re_v := stim_re;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(1), B"000_0000_0000_0000_0110",
	      B"000_0000_0000_0000_0000");
    test_case_count <= 16#03_04#;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(0), B"000_0000_0000_0000_0011",
	      B"000_0000_0000_0000_0011");
    test_case_count <= 16#03_05#;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(1), B"000_0000_0000_0000_0110",
	      B"000_0000_0000_0000_0110");
    test_case_count <= 16#03_06#;
    --		    exp.data-output,	 exp.adr+1,		    #clk cycles
    add_idle_cycles(audio_data_stim_c(2), B"000_0000_0000_0000_1001", 2);
    test_case_count <= 16#03_07#; stim_we_re_v := stim_re;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(2), B"000_0000_0000_0000_1001",
	      B"000_0000_0000_0000_0000");
--
    -- testcase#4: access last 3 bytes and after overflow first 3 bytes -
    --		   without idle cycles
    test_case_count <= 16#04_00#;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       data		    , start-adr
    write_proc(audio_data_stim_c(0), B"000_0000_0000_0000_0011",
	       audio_data_stim_c(1), B"111_1111_1111_1111_1101");
    test_case_count <= 16#04_01#; stim_we_re_v := stim_we;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       data		    , start-adr
    write_proc((others => 'X'), B"000_0000_0000_0000_0000",
	       audio_data_stim_c(2), B"000_0000_0000_0000_0000");
    test_case_count <= 16#04_02#;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc((others => 'X'), B"000_0000_0000_0000_0011",
	      B"111_1111_1111_1111_1101");
    test_case_count <= 16#04_03#; stim_we_re_v := stim_both;
    --	       exp.data-output@begin, exp.adr+1@begin
    --	       start-adr
    read_proc(audio_data_stim_c(1), B"000_0000_0000_0000_0000",
	      B"000_0000_0000_0000_0000");
    test_case_count <= 16#04_04#;
    --		    exp.data-output,	 exp.adr+1,		    #clk cycles
    add_idle_cycles(audio_data_stim_c(2), B"000_0000_0000_0000_0011", 2);

    assert false report "END OF SIMULATION REACHED - this is no error" severity failure;

    wait;

  end process WaveGen_Proc;



end tb1;

-------------------------------------------------------------------------------

configuration sram_controler_tb_tb1_cfg of sram_controler_tb is
  for tb1
  end for;
end sram_controler_tb_tb1_cfg;

-------------------------------------------------------------------------------
