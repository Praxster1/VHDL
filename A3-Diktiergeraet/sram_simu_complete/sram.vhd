-------------------------------------------------------------------------------
-- Title      : SRAM model for SRAM module on DE2-Board
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sram.vhd
-- Author     : Gräper, Richter, Rabe
-- Company    : 
-- Created    : 2009-10-13
-- Last update: 2010-10-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: sram model
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-10-13  1.0      rabe    Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

entity sram is
  
  generic (
    Size : natural := 16;  -- size in doublebytes (i.e. 512KB -> 2^256)
    Name : string  := "Hallo.txt");

  port (
    sram_addr_i : in    std_ulogic_vector(17 downto 0);
    sram_dq_io  : inout std_logic_vector(15 downto 0);
    sram_ce_n_i : in    std_ulogic;
    sram_we_n_i : in    std_ulogic;
    sram_oe_n_i : in    std_ulogic;
    sram_ub_n_i : in    std_ulogic;
    sram_lb_n_i : in    std_ulogic);

end sram;

architecture behav_for_sim of sram is

  -- type ram_t is array (natural range <>, natural range <>) of std_ulogic;

  -- signal ram : ram_t(0 to Size, 15 downto 0) := (others => (others => '0'));

  type ram_t is array (0 to Size) of std_ulogic_vector(15 downto 0);

  signal ram : ram_t := (others => (others => '0'));

  signal ram_init : std_ulogic := '0';

begin  -- behav_for_sim

  rw : process

    --file ram_file : text is in Name;
    --variable ram_line : line;
    variable data    : std_ulogic_vector(15 downto 0);
    variable i       : std_logic_vector(31 downto 0) := (others => '0');
    variable bsel    : std_ulogic_vector(1 downto 0);
    variable adr_int : integer;
    
  begin  -- process rw
--    if ram_init = '0' then
--      if Name /= "NULL" then
--        while (not(endfile(ram_file)) and to_integer(unsigned(i)) < Size) loop
--          readline(ram_file,ram_line);
--          read(ram_line,data);

--          ram(to_integer(unsigned(i(31 downto 0))))(15 downto 0) <= data;
----        if i(0) = '0' then
----          ram(to_integer(unsigned(i(31 downto 1))))(7 downto 0) <= data;
----        else
----          ram(to_integer(unsigned(i(31 downto 1))))(15 downto 8) <= data;
----        end if;

--          i := std_logic_vector(unsigned(i)+1);

--          ram_init <= '1';
--        end loop;
--      end if;
--    end if;

    sram_dq_io <= (others => 'Z');

    if sram_ce_n_i = '0' then
      
      assert to_integer(unsigned(sram_addr_i)) < Size report "Max Memory reached" severity note;

      bsel := sram_ub_n_i & sram_lb_n_i;

      if sram_we_n_i = '0' then
        --write
        -- sram_dq_io <= (others => 'Z');

        assert sram_oe_n_i = '1' report "Write: Output enable is '1'" severity error;

        case bsel is
          when "00"   => ram(to_integer(unsigned(sram_addr_i)))              <= To_StdULogicVector(sram_dq_io);  -- 16 bit
          when "10"   => ram(to_integer(unsigned(sram_addr_i)))(7 downto 0)  <= To_StdULogicVector(sram_dq_io(7 downto 0));  -- lower byte
          when "01"   => ram(to_integer(unsigned(sram_addr_i)))(15 downto 8) <= To_StdULogicVector(sram_dq_io(15 downto 8));  -- upper byte
          when others => null;
        end case;

      elsif sram_oe_n_i = '0' then

        -- assert sram_oe_n_i = '0' report "Read: Output enable must be '0'" severity warning;
        case bsel is
          when "00"   => sram_dq_io <= std_logic_vector(ram(to_integer(unsigned(sram_addr_i))));  -- 16 bit
          when "10"   => sram_dq_io <= "ZZZZZZZZ" & std_logic_vector(ram(to_integer(unsigned(sram_addr_i)))(7 downto 0));  -- lower byte
          when "01"   => sram_dq_io <= std_logic_vector(ram(to_integer(unsigned(sram_addr_i)))(15 downto 8)) & "ZZZZZZZZ";  -- upper byte
          when others => sram_dq_io <= (others => '0');
        end case;
        -- wait for 2 ns;
      end if;
    end if;
    wait on sram_addr_i, sram_ce_n_i, sram_dq_io, sram_lb_n_i, sram_oe_n_i, sram_ub_n_i, sram_we_n_i;
    -- avoid delta cycle issues of e.g. address switching during write together
    -- with other control signals
    wait for 1 ps;
  end process rw;

end behav_for_sim;
