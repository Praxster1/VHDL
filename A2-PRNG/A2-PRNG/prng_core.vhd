
library ieee;
use ieee.std_logic_1164.all;
use work.prng_pack.all;

entity prng_core is
  generic (
    prng_width_g : integer := 6;
    fibonacci_g : integer := 0
  );

  port (
    clk_i : in std_ulogic;
    res_n_i : in std_ulogic;
    regs_o : out std_ulogic_vector(prng_width_g downto 1));

end prng_core;

architecture rtl of prng_core is
  signal prng_state_reg : std_ulogic_vector(regs_o'range);
  --constant my_polynom_c : std_ulogic(regs_o'range) := polynom_c(4); -- polynom for 8-Bit lfsr -- WAS CONSTANT 
begin -- rtl

  galois_generate : if fibonacci_g = 0 generate
    --galois lfsr
    prng_gal_p : process (clk_i, res_n_i)
      variable next_val_v : std_ulogic_vector(regs_o'range);
    begin -- process prng_gal_p
      if res_n_i = '0' then -- asynchronous reset (active low)
        prng_state_reg <= (others => '1');
        next_val_v := (others => '0');
      elsif clk_i'event and clk_i = '1' then -- rising clock edge
        if prng_state_reg(prng_state_reg'high) = '1' then
          next_val_v := (others => '1');
        else
          next_val_v := (others => '0');
        end if;
        for i in prng_state_reg'range loop
          -- Polynom drehen
          next_val_v(i) := next_val_v(i) and polynom_c(prng_width_g, prng_width_g - i + 1);
        end loop; -- i
        next_val_v := (prng_state_reg(prng_width_g - 1 downto 1) xor
          next_val_v(prng_width_g downto 2)) & next_val_v(1);
        prng_state_reg <= next_val_v;
      end if;
    end process prng_gal_p;
  end generate;

  fibonacci_generate : if fibonacci_g = 1 generate
    prng_fib_p : process (clk_i, res_n_i)
      variable feedback_val_v : std_ulogic;
    begin -- process prng_fib_p
      if res_n_i = '0' then -- asynchronous reset (active low)
        prng_state_reg <= (others => '1');
        feedback_val_v := '1';
      elsif clk_i'event and clk_i = '1' then -- rising clock edge
        -- prng_state_reg(8 downto 2) <= prng_state_reg(8-1 downto 1);
        -- prng_state_reg(1) <= '0';         -- init
        feedback_val_v := '0';
        for i in 1 to 8 loop
          feedback_val_v := feedback_val_v xor (prng_state_reg(i) and polynom_c(prng_width_g, i));
        end loop; -- i
        prng_state_reg(8 downto 2) <= prng_state_reg(7 downto 1);
        prng_state_reg(1) <= feedback_val_v;
        -- alternativ:
        -- prng_state_reg <= prng_state_reg(7 downto 1) & feedback_val_v;
      end if;
    end process prng_fib_p;
  end generate;

  regs_o <= prng_state_reg;

end rtl;