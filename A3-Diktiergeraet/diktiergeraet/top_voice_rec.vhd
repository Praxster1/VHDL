library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sram_controler_pack.all;

entity top_voice_rec is

  port (
    CLOCK_50 : in std_ulogic;
    KEY : in std_ulogic_vector(2 downto 0);
    AUD_BCLK : in std_ulogic;
    AUD_ADCLRCK : in std_ulogic;
    AUD_ADCDAT : in std_ulogic;
    AUD_DACDAT : out std_ulogic;
    AUD_DACLRCK : in std_ulogic;
    I2C_SDAT : inout std_logic;
    I2C_SCLK : out std_ulogic;
    SRAM_WE_N : out std_ulogic;
    SRAM_CE_N : out std_ulogic;
    SRAM_OE_N : out std_ulogic;
    SRAM_LB_N : out std_ulogic;
    SRAM_UB_N : out std_ulogic;
    SRAM_ADDR0 : out std_ulogic;--
    SRAM_ADDR : out std_ulogic_vector(17 downto 0);
    SRAM_DQ : inout std_logic_vector(15 downto 0);
    LEDG : out std_logic_vector(6 downto 0);
    AUD_XCK : out std_ulogic;
    GPIO_1 : out std_ulogic_vector(7 downto 0));
  --      KEY(3)      : in    std_ulogic;
  --      KEY(2)     : in    std_ulogic;
  --      KEY(1)       : in    std_ulogic);

end top_voice_rec;

architecture rtl of top_voice_rec is
  component voice_rec
    port (
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      bclk_i : in std_ulogic;
      adlrclk_i : in std_ulogic;
      adc_dat_ser_in_i : in std_ulogic;
      dac_dat_ser_out_o : out std_ulogic;
      dalrclk_i : in std_ulogic;
      ctr_leds : out std_ulogic_vector (3 downto 0);
      SDAT_b : inout std_logic;
      SCLK_o : out std_ulogic;
      --    debug_top         : out   std_ulogic_vector(15 downto 0);
      srctr_we_reg_n_o : out std_ulogic;
      srctr_ce_n_o : out std_ulogic;
      srctr_oe_reg_n_o : out std_ulogic;
      srctr_lb_n_o : out std_ulogic;
      srctr_ub_n_o : out std_ulogic;
      srctr_addr_reg_o : out std_ulogic_vector(18 downto 0);
      mem_data_b : inout std_logic_vector(15 downto 0);
      io_reset_n_i : in std_ulogic;
      io_replay_i : in std_ulogic;
      io_record_i : in std_ulogic;
      mclk_o : out std_ulogic);
  end component;

  component sram_controler is
    port (
      fsm_start_addr_i : in std_ulogic_vector(18 downto 0);
      clk_i : in std_ulogic;
      reset_n_i : in std_ulogic;
      fsm_we_i : in std_ulogic;
      fsm_re_i : in std_ulogic;
      srctr_idle_o : out std_ulogic;
      srctr_we_reg_n_o : out std_ulogic;
      srctr_ce_n_o : out std_ulogic;
      srctr_oe_reg_n_o : out std_ulogic;
      srctr_lb_n_o : out std_ulogic;
      srctr_ub_n_o : out std_ulogic;
      srctr_end_addr_plus1_o : out std_ulogic_vector(18 downto 0);
      srctr_addr_reg_o : out std_ulogic_vector(18 downto 0);
      audio_data_i : in std_ulogic_vector(23 downto 0);
      srctr_data_o : out std_ulogic_vector(23 downto 0);
      mem_data_b : inout std_logic_vector(15 downto 0);
      state_o : out FSM_T);
  end component sram_controler;

  signal adcdat : std_ulogic;
  signal bidir : std_logic;
  signal clk_i : std_ulogic;
  signal sclk : std_ulogic;
  signal reset : std_ulogic;
  -- signal debug  : std_ulogic_vector(15 downto 0);

  signal fsm_start_addr_i : std_ulogic_vector(18 downto 0);
  signal clk_i : std_ulogic;
  signal reset_n_i : std_ulogic;
  signal fsm_we_i : std_ulogic;
  signal fsm_re_i : std_ulogic;
  signal srctr_idle_o : std_ulogic;
  signal srctr_we_reg_n_o : std_ulogic;
  signal srctr_ce_n_o : std_ulogic;
  signal srctr_oe_reg_n_o : std_ulogic;
  signal srctr_lb_n_o : std_ulogic;
  signal srctr_ub_n_o : std_ulogic;
  signal srctr_end_addr_plus1_o : std_ulogic_vector(18 downto 0);
  signal srctr_addr_reg_o : std_ulogic_vector(18 downto 0);
  signal audio_data_i : std_ulogic_vector(23 downto 0);
  signal srctr_data_o : std_ulogic_vector(23 downto 0);
  signal mem_data_b : std_logic_vector(15 downto 0);
  signal state_o : FSM_T;
begin -- rtl
  voice_rec_1 : voice_rec
  port map(
    clk_i => clk_i,
    reset_n_i => reset,
    bclk_i => AUD_BCLK,
    adlrclk_i => AUD_ADCLRCK,
    adc_dat_ser_in_i => AUD_ADCDAT,
    dac_dat_ser_out_o => AUD_DACDAT, -- changed just for test case
    dalrclk_i => AUD_DACLRCK,
    ctr_leds => open,
    SDAT_b => bidir,
    SCLK_o => sclk,
    --   debug_top                     => debug,
    srctr_we_reg_n_o => SRAM_WE_N,
    srctr_ce_n_o => SRAM_CE_N,
    srctr_oe_reg_n_o => SRAM_OE_N,
    srctr_lb_n_o => SRAM_LB_N,
    srctr_ub_n_o => SRAM_UB_N,
    srctr_addr_reg_o(18 downto 1) => SRAM_ADDR,
    srctr_addr_reg_o(0) => SRAM_ADDR0, --open,
    mem_data_b => SRAM_DQ,
    io_reset_n_i => not KEY(0), --
    io_replay_i => not KEY(2),
    io_record_i => not KEY(1),
    mclk_o => AUD_XCK);

  sram_controler_1 : sram_controler
  port map(
    fsm_start_addr_i => fsm_start_addr_i,
    clk_i => clk_i,
    reset_n_i => reset,
    fsm_we_i => fsm_we_i,
    fsm_re_i => fsm_re_i,
    srctr_idle_o => srctr_idle_o,
    srctr_we_reg_n_o => srctr_we_reg_n_o,
    srctr_ce_n_o => srctr_ce_n_o,
    srctr_oe_reg_n_o => srctr_oe_reg_n_o,
    srctr_lb_n_o => srctr_lb_n_o,
    srctr_ub_n_o => srctr_ub_n_o,
    srctr_end_addr_plus1_o => srctr_end_addr_plus1_o,
    srctr_addr_reg_o => srctr_addr_reg_o,
    audio_data_i => audio_data_i,
    srctr_data_o => srctr_data_o,
    mem_data_b => mem_data_b,
    state_o => state_o);

  -- SRAM
  SRAM_WE_N <= srctr_we_reg_n_o;
  SRAM_CE_N <= srctr_ce_n_o;
  SRAM_OE_N <= srctr_oe_reg_n_o;
  SRAM_LB_N <= srctr_lb_n_o;
  SRAM_UB_N <= srctr_ub_n_o;
  SRAM_ADDR0 <= srctr_addr_reg_o(0);
  SRAM_ADDR <= srctr_addr_reg_o;
  SRAM_DQ <= mem_data_b;
  -- !SRAM

  LEDG(0) <= KEY(0);
  LEDG(1) <= not KEY(1);
  LEDG(2) <= not KEY(2);
  -- LEDG(3)   <= not debug(0);
  LEDG(6 downto 3) <= (others => '0');
  I2C_SDAT <= bidir;
  GPIO_1(0) <= I2C_SDAT;
  clk_i <= CLOCK_50;
  GPIO_1(1) <= CLOCK_50;
  I2C_SCLK <= sclk;
  GPIO_1(2) <= sclk;
  reset <= KEY(0);
  GPIO_1(3) <= KEY(0);
  GPIO_1(4) <= '0';--debug(0);
  GPIO_1(5) <= 'Z';
  GPIO_1(6) <= '0';--debug(1);
  GPIO_1(7) <= '0';--debug(2);

end rtl;