library ieee;
use ieee.std_logic_1164.all;

entity gray2dual is

  generic (
    bitwidth_g : integer := 4);

  port (
    gray_i : in	 std_ulogic_vector(bitwidth_g-1 downto 0);
    dual_o : out std_ulogic_vector(bitwidth_g-1 downto 0));

end entity gray2dual;

architecture transfer of gray2dual is
begin  -- architecture transfer

  gray2dual_p : process (gray_i) is
    variable dual_v : std_ulogic_vector(bitwidth_g-1 downto 0);

  begin	 -- process gray2dual_p
    dual_v(bitwidth_g-1) := gray_i(bitwidth_g-1);
    for i in bitwidth_g-2 downto 0 loop
      dual_v(i) := dual_v(i+1) xor gray_i(i);
    end loop;  -- i
    dual_o <= dual_v;
  end process gray2dual_p;

end architecture transfer;
