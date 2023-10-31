library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;

entity mclk is

  port (
    reset_n_i : in  std_ulogic;
    clk_i     : in  std_ulogic;
    mclk_o    : out std_ulogic);

end mclk;


architecture rtl of mclk is
  signal counter : integer range 0 to 7 := 0;  -- Counter for Clk generation
begin

  -- purpose: mclk for the wm8731 Audio Codec
  -- type   : sequential
  -- inputs : clk_i, reset_n_i
  -- outputs: mclk
  mclk_p : process (clk_i, reset_n_i)
  begin  -- process mclk_p
    if reset_n_i = '0' then                 -- asynchronous reset (active low)
      mclk_o <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if counter /= 3 then
        counter <= counter +1;
        if counter = 0 then
          mclk_o <= '1';
        elsif counter = 2 then
          mclk_o <= '0';
        end if;
      else
        counter <= 0;
      end if;
    end if;
  end process mclk_p;
end rtl;
