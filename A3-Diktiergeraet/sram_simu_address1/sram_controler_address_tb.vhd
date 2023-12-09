-------------------------------------------------------------------------------
-- Title      : Testbench for design "sram_controler_address"
-- Project    : 
-------------------------------------------------------------------------------
-- File	      : sram_controler_address_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2023-11-06
-- Last update: 2023-11-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2023-11-08  1.0	timow	Created
-------------------------------------------------------------------------------

library ieee;
library std_developerskit;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use std_developerskit.std_iopak.all;
use work.sram_controler_pack.all;

-------------------------------------------------------------------------------

entity sram_controler_address_tb is

end entity sram_controler_address_tb;

-------------------------------------------------------------------------------

architecture tb of sram_controler_address_tb is
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
  -- component ports
  signal clk_i : std_ulogic := '1';
  signal reset_n_i : std_ulogic := '1';
  signal fsm_we_i : std_ulogic;
  signal fsm_re_i : std_ulogic;
  signal fsm_start_addr_i : std_ulogic_vector(18 downto 0);
  signal state_i : FSM_T;
  signal srctr_end_addr_plus1_o : std_ulogic_vector(18 downto 0);
  signal srctr_addr_reg_o : std_ulogic_vector(18 downto 0);

  -- clock
  signal stop_sim : boolean := false; -- to stop clock-signal at end of simulation to terminate simulation automatically
begin -- architecture tb

  -- component instantiation
  DUT : sram_controler_address
  port map(
    clk_i => clk_i,
    reset_n_i => reset_n_i,
    fsm_we_i => fsm_we_i,
    fsm_re_i => fsm_re_i,
    fsm_start_addr_i => fsm_start_addr_i,
    state_i => state_i,
    srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
    srctr_addr_reg_o => srctr_addr_reg_o);

  -- clock generation
  -- purpose: generate clock signal
  -- type   : combinational
  -- inputs : 
  -- outputs: clk
  clk_gen_p : process is
  begin -- process clk_gen_p
    wait for 10 ns;
    clk_i <= not clk_i;
    if stop_sim then
      wait;
    end if;
  end process clk_gen_p;

  -- waveform generation
  WaveGen_Proc : process
    procedure read(constant start_adress : in std_ulogic_vector(18 downto 0); constant loopCounter : in unsigned) is
      variable increment : std_ulogic_vector(18 downto 0) := (others => '0');
      variable counter : unsigned(18 downto 0) := (others => '0');
    begin
      fsm_start_addr_i <= start_adress;
      wait until rising_edge(clk_i);
      state_i <= FSM_IDLE;
      fsm_re_i <= '1';
      fsm_we_i <= '0';
      while(counter < loopCounter)loop
        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_11;
        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_12;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "start address not equal to srctr_addr_reg_o";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_13;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "MEM 12 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_21;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "MEM 13 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_22;
        increment := increment + "1";
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 21 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_23;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 22 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_31;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 23 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_32;
        increment := increment + "1";
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "MEM 31 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_READ_MEM_33;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "MEM 32 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

        counter := counter + 1;
        fsm_start_addr_i <= srctr_addr_reg_o;

      end loop;
      
      fsm_start_addr_i <= start_adress;
      wait until rising_edge(clk_i);
      state_i <= FSM_IDLE;

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_11;
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "START ADRESS RESET not equal to srctr_end_addr_plus1_o";
      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_12;
      assert fsm_start_addr_i(18 downto 0) = srctr_addr_reg_o(18 downto 0) report "START ADRESS RESET not equal to srctr_addr_reg_o";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_13;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "MEM 12 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_21;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "MEM 13 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_22;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 21 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_23;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 22 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_31;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "MEM 23 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_32;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "MEM 31 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_READ_MEM_33;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "MEM 32 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "start address not equal to srctr_end_addr_plus1_o";
      wait until rising_edge(clk_i);

    end procedure;

    procedure write(constant start_adress : in std_ulogic_vector(18 downto 0); constant loopCounter : in unsigned) is
      variable increment : std_ulogic_vector(18 downto 0) := (others => '0');
      variable counter : unsigned(18 downto 0) := (others => '0');
    begin
      fsm_start_addr_i <= start_adress;
      fsm_re_i <= '0';
      fsm_we_i <= '1';
      while(counter < loopCounter)loop
        state_i <= FSM_WRITE_MEM_11;
        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_12;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE start address not equal to srctr_addr_reg_o";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_13;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE 12 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_21;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE 13 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_22;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 21 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_23;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 22 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_31;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 23 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_32;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "WRITE 31 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        wait until rising_edge(clk_i);
        state_i <= FSM_WRITE_MEM_33;
        assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "WRITE 32 ERROR";
        assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

        counter := counter + 1;
        fsm_start_addr_i <= srctr_addr_reg_o;

      end loop;
      fsm_start_addr_i <= start_adress;
      wait until rising_edge(clk_i);
      state_i <= FSM_IDLE;

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_11;
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE START ADRESS RESET not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_12;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE start address not equal to srctr_addr_reg_o";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_13;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE 12 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_21;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0)) report "WRITE 13 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_22;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 21 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_23;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 22 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_31;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "1") report "WRITE 23 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_32;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "WRITE 31 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";

      wait until rising_edge(clk_i);
      state_i <= FSM_WRITE_MEM_33;
      assert srctr_addr_reg_o(18 downto 0) = (fsm_start_addr_i(18 downto 0) + "10") report "WRITE 32 ERROR";
      assert srctr_end_addr_plus1_o(18 downto 0) = (srctr_addr_reg_o(18 downto 0) + "1") report "WRITE start address not equal to srctr_end_addr_plus1_o";
      wait until rising_edge(clk_i);
      state_i <= FSM_IDLE; --RESET
      wait until rising_edge(clk_i);
    end procedure;
  begin
    -- insert signal assignments here
    read("1111111111111111111", to_unsigned(8, 4));
    write("1111111111111111111", to_unsigned(8, 4));

    assert false report "END OF SIMULATION REACHED - this is no error" severity note;
    stop_sim <= true;
    wait;
  end process WaveGen_Proc;

end architecture tb;

-------------------------------------------------------------------------------

configuration sram_controler_address_tb_tb_cfg of sram_controler_address_tb is
  for tb
  end for;
end sram_controler_address_tb_tb_cfg;

-------------------------------------------------------------------------------