library ieee;
use ieee.std_logic_1164.all;

entity prng is
  generic (
    reg_width_g : integer := 6
  );

  port (
    clock_27 : in std_ulogic; -- 27MHz Clock
    key0 : in std_ulogic; -- alternative clock 
    sw0 : in std_ulogic; -- res_n on pin 0
    ledr : out std_ulogic_vector(17 downto 0); -- status bits
    gpio_1 : out std_ulogic_vector(reg_width_g downto 1)); -- status bits
  -- for oszi

end prng;

architecture struc of prng is
  signal prng_reg : std_ulogic_vector(reg_width_g downto 1); -- prng_vector
  component prng_core
    generic (
      prng_width_g : integer := reg_width_g;
      fibonacci_g : integer := 0
    );

    port (
      clk_i : in std_ulogic;
      res_n_i : in std_ulogic;
      regs_o : out std_ulogic_vector(reg_width_g downto 1));
  end component;
begin -- struc

  prng_core_inst : prng_core

  generic map(
    prng_width_g => reg_width_g
  )

  port map(
    -- clk_i  => clock_27,
    clk_i => key0,
    res_n_i => sw0,
    regs_o => prng_reg);

  -- Alternative 1: 
  -- # ** Fatal: (vsim-3471) Slice range (24 downto 0) does not belong to the prefix index range (17 downto 0).
  -- #    Time: 0 ps  Iteration: 0  Process: /prng_tb/prng_1/ledr_p File: C:/Projects/VHDL/A2-PRNG/prng.vhd
  -- #    FATAL ERROR while loading design
  -- ledr_p : process (prng_reg)
  -- begin -- process ledr_p
  --   if reg_width_g > 18 then
  --     ledr <= (others => '0');
  --     ledr <= prng_reg(18 downto 1);
  --   else
  --     ledr <= (others => '0');
  --     ledr(reg_width_g - 1 downto 0) <= prng_reg(reg_width_g downto 1);
  --   end if;
  -- end process ledr_p;

  -- Alternative 2:
  -- # ** Fatal: (vsim-3471) Slice range (24 downto 0) does not belong to the prefix index range (17 downto 0).
  -- #    Time: 0 ps  Iteration: 0  Process: /prng_tb/prng_1/led_p_gen1/ledr_p File: C:/Projects/VHDL/A2-PRNG/prng.vhd
  -- #    FATAL ERROR while loading design
  --led_p_gen1 : if reg_width_g > 18 generate
  --  ledr_p : process (prng_reg)
  --  begin
  --    ledr(17 downto 0) <= (others => '0');
  --    ledr(17 downto 0) <= prng_reg(18 downto 1);
  --  end process;
  --end generate;
  --led_p_gen2 : if reg_width_g <= 18 generate
  --  ledr_p : process (prng_reg)
  --  begin
  --    ledr <= (others => '0');
  --    ledr(reg_width_g - 1 downto 0) <= prng_reg(reg_width_g downto 1);
  --  end process;
  --end generate;

  ledr_p : process (prng_reg)
  begin -- process ledr_p
    ledr <= (others => '0');
    ledr(work.prng_pack.min(reg_width_g, 18) - 1 downto 0) <= prng_reg(work.prng_pack.min(reg_width_g, 18) downto 1);
  end process ledr_p;

  gpio_1 <= prng_reg;
end struc;