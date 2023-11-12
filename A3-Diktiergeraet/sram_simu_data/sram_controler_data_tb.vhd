-------------------------------------------------------------------------------
-- Title      : Testbench for design "sram_controler_data"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sram_controler_data_tb.vhd
-- Author     : Dirksen L�nemann
-- Company    : 
-- Created    : 2009-10-10
-- Last update: 2019-11-13
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-10-10  1.0      rabe    Created
-------------------------------------------------------------------------------

library ieee;
library std_developerskit;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std_developerskit.std_iopak.all;
use work.sram_controler_pack.all;

-------------------------------------------------------------------------------

entity sram_controler_data_tb is

end sram_controler_data_tb;

-------------------------------------------------------------------------------
architecture tb1 of sram_controler_data_tb is
  signal clk : std_ulogic := '1';
  signal stop_sim : boolean := false; -- to stop clock-signal at end of simulation to terminate simulation automatically
  signal reset_n : std_ulogic;
  signal audio_data : std_ulogic_vector(23 downto 0);
  signal srctr_data : std_ulogic_vector(23 downto 0);
  signal fsm_we : std_ulogic;
  signal mem_data_b : std_logic_vector(15 downto 0);
  signal state : FSM_T;
  signal addr_reg0 : std_ulogic;
  signal test_case_count : integer := 0;
  component sram_controler_data
    port (
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      audio_data_i : in std_ulogic_vector(23 downto 0);
      srctr_data_o : out std_ulogic_vector(23 downto 0);
      fsm_we_i : in std_ulogic;
      mem_data_b : inout std_logic_vector(15 downto 0);
      state_i : in FSM_T;
      addr_reg0_i : in std_ulogic);
  end component;
begin -- tb1
  DUT : sram_controler_data
  port map(
    clk_i => clk,
    reset_n_i => reset_n,
    audio_data_i => audio_data,
    srctr_data_o => srctr_data,
    fsm_we_i => fsm_we,
    mem_data_b => mem_data_b,
    state_i => state,
    addr_reg0_i => addr_reg0);

  -- clock generation
  -- purpose: generate clock signal
  -- type   : combinational
  -- inputs : 
  -- outputs: clk
  clk_gen_p : process is
  begin -- process clk_gen_p
    wait for 10 ns;
    clk <= not clk;
    if stop_sim then
      wait;
    end if;
  end process clk_gen_p;

  -- reset generation
  reset_p : process
  begin -- process reset_p
    reset_n <= '0';
    wait for 45 ns;
    reset_n <= '1';
    wait;
  end process reset_p;

  -- purpose: check, that mem_data_b is not driven if not in a write-state
  -- type   : sequential
  -- inputs : clk, res_n
  -- outputs: 
  check_memdata_z_p : process (clk) is
    constant data_16xz_c : std_logic_vector(15 downto 0) := (others => 'Z');
  begin -- process check_memdata_z_p
    if clk'event and clk = '1' then -- rising clock edge
      if (state < FSM_WRITE_MEM_11 or state > FSM_WRITE_MEM_33) and state /= FSM_READ_MEM_12 and state /= FSM_READ_MEM_22 and state /= FSM_READ_MEM_32 then
        assert mem_data_b = data_16xz_c report "mem_data_b should not be driven, i.e. should be Z." severity error;
      end if;
    end if;
  end process check_memdata_z_p;

  WaveGen_Proc : process
    procedure check_write_data_proc (
      constant expected_data : in std_ulogic_vector(7 downto 0);
      constant actual_data : in std_ulogic_vector(7 downto 0)) is
    begin
      assert expected_data = actual_data report "mem_data_b has wrong data during write (expected: " & To_String(to_integer(unsigned(expected_data)), "%X") & "; actual: " & To_String(to_integer(unsigned(actual_data)), "%X") & ")" severity error;
    end check_write_data_proc;

    procedure write_proc (
      constant data_param : in std_ulogic_vector(23 downto 0);
      constant upper_byte_start : in std_ulogic;
      constant keep_fsm_we_high : in boolean) is
    begin
      audio_data <= data_param;
      fsm_we <= '1';
      addr_reg0 <= upper_byte_start;

      wait until clk'event and clk = '1';
      state <= FSM_WRITE_MEM_11;
      audio_data <= X"DEAD0F";
      if not(keep_fsm_we_high) then
        -- both has to work
        fsm_we <= '0';
      end if;
      wait until clk'event and clk = '1';
      if upper_byte_start = '1' then
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_12;

      wait until clk'event and clk = '1';
      if upper_byte_start = '1' then
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_13;

      -- second byte 
      wait until clk'event and clk = '1';
      if upper_byte_start = '1' then
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(7 downto 0), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_21;
      addr_reg0 <= not upper_byte_start;

      wait until clk'event and clk = '1';
      if upper_byte_start = '0' then
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_22;

      wait until clk'event and clk = '1';
      if upper_byte_start = '0' then
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_23;
      -- third byte 
      wait until clk'event and clk = '1';
      if upper_byte_start = '0' then
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(15 downto 8), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_31;
      addr_reg0 <= upper_byte_start;

      wait until clk'event and clk = '1';
      if upper_byte_start = '1' then
        check_write_data_proc(data_param(23 downto 16), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(23 downto 16), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_32;

      wait until clk'event and clk = '1';
      if upper_byte_start = '1' then
        check_write_data_proc(data_param(23 downto 16), to_stdulogicvector(mem_data_b(15 downto 8)));
      else
        check_write_data_proc(data_param(23 downto 16), to_stdulogicvector(mem_data_b(7 downto 0)));
      end if;
      state <= FSM_WRITE_MEM_33;
      fsm_we <= '0'; -- now disable fsm_we

    end write_proc; -- 24 bit of data to be written

    procedure read_proc (
      constant data_param : in std_ulogic_vector(23 downto 0);
      constant upper_byte_start : in std_ulogic;
      constant set_fsm_we_high : in boolean) is
    begin
      audio_data <= X"DEAD0F";
      fsm_we <= '0';
      addr_reg0 <= upper_byte_start;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_11;
      if set_fsm_we_high then
        fsm_we <= '1';
      end if;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_12;
      if upper_byte_start = '1' then
        mem_data_b(15 downto 8) <= to_stdlogicvector(data_param(7 downto 0));
      else
        mem_data_b(7 downto 0) <= to_stdlogicvector(data_param(7 downto 0));
      end if;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_13;
      mem_data_b <= (others => 'Z');

      -- second byte 
      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_21;
      addr_reg0 <= not upper_byte_start;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_22;
      if upper_byte_start = '0' then
        mem_data_b(15 downto 8) <= to_stdlogicvector(data_param(15 downto 8));
      else
        mem_data_b(7 downto 0) <= to_stdlogicvector(data_param(15 downto 8));
      end if;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_23;
      mem_data_b <= (others => 'Z');
      -- third byte 
      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_31;
      addr_reg0 <= upper_byte_start;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_32;
      if upper_byte_start = '1' then
        mem_data_b(15 downto 8) <= to_stdlogicvector(data_param(23 downto 16));
      else
        mem_data_b(7 downto 0) <= to_stdlogicvector(data_param(23 downto 16));
      end if;

      wait until clk'event and clk = '1';
      state <= FSM_READ_MEM_33;
      mem_data_b <= (others => 'Z');
      fsm_we <= '0';
    end read_proc; -- 24 bit of data to be written

  begin
    fsm_we <= '0';
    addr_reg0 <= '0';
    state <= FSM_IDLE;
    mem_data_b <= (others => 'Z');
    audio_data <= (others => '0');
    wait until reset_n = '0';
    wait until reset_n = '1';

    test_case_count <= 16#00_00#;
    wait until clk'event and clk = '1';

    write_proc(X"FBABBA", '0', FALSE);
    test_case_count <= 16#00_01#;
    write_proc(X"CDDEAD", '1', TRUE);
    test_case_count <= 16#00_02#;
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    write_proc(X"CDDEAD", '1', TRUE);

    test_case_count <= 16#01_00#;
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;

    read_proc(X"FBABBA", '0', FALSE);
    test_case_count <= 16#01_01#;
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    assert srctr_data = X"FBABBA" report "wrong data read FBABBA" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
    read_proc(X"CDDEAD", '1', TRUE);
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
    test_case_count <= 16#00_02#;
    read_proc(X"CDDEAD", '1', FALSE);
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;

    test_case_count <= 16#01_03#;

    read_proc(X"FBABBA", '0', TRUE);
    read_proc(X"CDDEAD", '1', FALSE);
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
    -- check, that data is kept available at srctr_data
    wait until clk'event and clk = '1';
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;
    wait until clk'event and clk = '1';
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;

    test_case_count <= 16#01_05#;
    read_proc(X"CDDEAD", '0', TRUE);
    write_proc(X"FBABBA", '0', FALSE);
    test_case_count <= 16#01_06#;
    read_proc(X"CDDEAD", '1', TRUE);
    wait until clk'event and clk = '1';
    state <= FSM_IDLE;
    assert srctr_data = X"CDDEAD" report "wrong data read CDDEAD" & "; actual: " & To_String(to_integer(unsigned(srctr_data)), "%X") & ")" severity error;

    assert false report "END OF SIMULATION REACHED - this is no error" severity note;
    stop_sim <= TRUE;
    wait;

  end process WaveGen_Proc;
end tb1;