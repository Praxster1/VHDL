library ieee;
use ieee.std_logic_1164.all;

entity prng_tb is

end prng_tb;

architecture behav of prng_tb is

  signal clk : std_ulogic := '0';
  signal reset_n : std_ulogic;
  signal prng_reg : std_ulogic_vector(25 downto 1);
  signal clk_count : integer;

  component prng
    generic (
    reg_width_g : integer := prng_reg'length
    );

    port (
      clock_27 : in std_ulogic;
      key0 : in std_ulogic;
      sw0 : in std_ulogic;
      ledr : out std_ulogic_vector(17 downto 0);
      gpio_1 : out std_ulogic_vector(reg_width_g downto 1));
  end component;

begin -- behav

  -- clock generation: 27 MHz
  clk <= not clk after 18 ns;
  -- reset generation
  --reset_p : process
  --begin  -- process reset_p
  --  -- initialize reset_n with '0' at time 0 nsProzess prng_gal_p ein (Tipp: VHDL-Menü „Comment“… im EMACS verwenden…).
  --  -- wait for 2 clock cycles
  --  -- assign '1' to reset_n
  --  -- hint: avoid, that this process will be reinvoked a second time!!
  --end process reset_p;
  init_prng : process
  begin
    reset_n <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    reset_n <= '1';
    wait;
  end process; --reset_n 
  prng_1 : prng
  port map(
    clock_27 => clk,
    key0 => clk,
    sw0 => reset_n,
    ledr => open,
    gpio_1 => prng_reg);
  -- purpose: count clocks for display
  -- type	  : sequential
  -- inputs : clk, reset_n
  -- outputs: clk_count
  clk_count_p : process (clk, reset_n)
  begin -- process clk_count_p
    if reset_n = '0' then -- asynchronous reset (active low)
      clk_count <= 1;
    elsif clk'event and clk = '1' then -- rising clock edge
      clk_count <= clk_count + 1;
    end if;
  end process clk_count_p;

  sim_stop : process
    variable init_comb_v : std_ulogic_vector(prng_reg'range);
  begin -- process sim_stop
    wait until reset_n = '1';
    init_comb_v := prng_reg;
    wait until rising_edge(clk);
    for i in 1 to 2 ** prng_reg'length loop
      wait until rising_edge(clk);
      assert init_comb_v /= prng_reg report "initial combination reached again." severity failure;
    end loop; -- i
    report "Initial combination not reached again." severity failure;
    wait;
  end process sim_stop;

end behav;