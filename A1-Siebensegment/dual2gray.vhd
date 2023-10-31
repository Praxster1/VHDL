library ieee;
use ieee.std_logic_1164.all;

entity dual2gray is

  generic (
    bitwidth_g : integer := 4);

  port (
    dual_i : in	 std_ulogic_vector(bitwidth_g-1 downto 0);
    gray_o : out std_ulogic_vector(bitwidth_g-1 downto 0));

end entity dual2gray;

architecture transfer of dual2gray is

begin  -- architecture transfer

  -- dual2gray_p: process (dual_i) is
  -- begin  -- process dual2gray_p
  --   gray_o(bitwidth_g-1) <= dual_i(bitwidth_g-1);
  --   gray_o(bitwidth_g-2 downto 0) <= dual_i(bitwidth_g-1 downto 1) xor dual_i(bitwidth_g-2 downto 0);
  -- end process dual2gray_p;

  gray_o <= dual_i(bitwidth_g-1) & dual_i(bitwidth_g-1 downto 1) xor dual_i(bitwidth_g-2 downto 0);
end architecture transfer;
