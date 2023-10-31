library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity voice_rec is
  
  port (
    clk_i     : in std_ulogic;
    reset_n_i : in std_ulogic;

    ----------------------------------------------------------------------------
    -- I2S
    ----------------------------------------------------------------------------
    bclk_i            : in    std_ulogic;
    adlrclk_i         : in    std_ulogic;
    adc_dat_ser_in_i  : in    std_ulogic;
    dac_dat_ser_out_o : out   std_ulogic;
    dalrclk_i         : in    std_ulogic;
    ctr_leds          : out   std_ulogic_vector (3 downto 0);
    ----------------------------------------------------------------------------
    -- I2C
    ----------------------------------------------------------------------------
    SDAT_b            : inout std_logic;
    SCLK_o            : out   std_ulogic;
  --  debug_top         : out   std_ulogic_vector(15 downto 0);
    ----------------------------------------------------------------------------
    -- srctr
    ----------------------------------------------------------------------------
    srctr_we_reg_n_o  : out   std_ulogic;
    srctr_ce_n_o      : out   std_ulogic;
    srctr_oe_reg_n_o  : out   std_ulogic;
    srctr_lb_n_o      : out   std_ulogic;
    srctr_ub_n_o      : out   std_ulogic;
    srctr_addr_reg_o  : out   std_ulogic_vector(18 downto 0);
    mem_data_b        : inout std_logic_vector(15 downto 0);
    ----------------------------------------------------------------------------
    -- fsm
    ----------------------------------------------------------------------------
    io_reset_n_i      : in    std_ulogic;
    io_replay_i       : in    std_ulogic;
    io_record_i       : in    std_ulogic;
    mclk_o            : out   std_ulogic);
  ----------------------------------------------------------------------------
  -- mclk
  ----------------------------------------------------------------------------
end voice_rec;




architecture rtl of voice_rec is
  component mclk
    port (
      reset_n_i : in  std_ulogic;
      clk_i     : in  std_ulogic;
      mclk_o    : out std_ulogic);
  end component;

  component audio_interface
    port (
      reset_n_i : in std_ulogic;

      bclk_i            : in  std_ulogic;
      adlrclk_i         : in  std_ulogic;
      adc_dat_ser_in_i  : in  std_ulogic;
      dac_dat_ser_out_o : out std_ulogic;
      dalrclk_i         : in  std_ulogic;

      fsm_cs_i2s_i : in std_ulogic_vector(1 downto 0);

      i2s_we_re_fsm_o    : out std_ulogic_vector(1 downto 0);
      dac_dat_para_in_i  : in  std_ulogic_vector(23 downto 0);
      adc_dat_para_out_o : out std_ulogic_vector(23 downto 0);

      ctr_leds : out std_ulogic_vector (3 downto 0));
  end component;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
  component I2C_State_machine
    port (
      clk_i      : in    std_ulogic;
      reset_n_i  : in    std_ulogic;
      data_i     : in    std_ulogic_vector(15 downto 0);
      we_i       : in    std_ulogic;
      i2c_idle_o : out   std_ulogic;
      i2c_sdin_b : inout std_logic;
      i2c_sclk_o : out   std_ulogic);--
 --     debug_o    : out   std_ulogic_vector(15 downto 0));
  end component;
--component codec_ctrl
--  port (
--    reset_n_i      : IN    std_ulogic;
--    clk          : IN    std_ulogic;
--    fsm_data_i2c_i : IN    std_ulogic_vector (15 downto 0);
--    fsm_we_i2c_i : IN    std_ulogic;
--    SDAT_b       : INOUT std_ulogic;
--    SCLK_o       : OUT   std_ulogic;
--    debug_out_o  : OUT   std_ulogic_vector(6 downto 0));
--end component;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
  component sram_controler
    port (
      clk_i                  : in    std_ulogic;
      reset_n_i              : in    std_ulogic;
      audio_data_i           : in    std_ulogic_vector(23 downto 0);
      srctr_data_o           : out   std_ulogic_vector(23 downto 0);
      fsm_start_addr_i       : in    std_ulogic_vector(18 downto 0);
      fsm_we_i               : in    std_ulogic;
      fsm_re_i               : in    std_ulogic;
      srctr_idle_o           : out   std_ulogic;
      srctr_end_addr_plus1_o : out   std_ulogic_vector(18 downto 0);
      srctr_we_reg_n_o       : out   std_ulogic;
      srctr_ce_n_o           : out   std_ulogic;
      srctr_oe_reg_n_o       : out   std_ulogic;
      srctr_lb_n_o           : out   std_ulogic;
      srctr_ub_n_o           : out   std_ulogic;
      srctr_addr_reg_o       : out   std_ulogic_vector(18 downto 0);
      mem_data_b             : inout std_logic_vector(15 downto 0));
  end component;


  component fsm
    port (
      clk_i                  : in  std_ulogic;
      reset_n_i              : in  std_ulogic;
      fsm_cs_i2s_o           : out std_ulogic_vector(1 downto 0);
      i2s_we_re_fsm_i        : in  std_ulogic_vector(1 downto 0);
      fsm_we_i2c_o           : out std_ulogic;
      fsm_config_i2c_data_o  : out std_ulogic_vector(15 downto 0);
      fsm_start_addr_o       : out std_ulogic_vector(18 downto 0);
      fsm_we_o               : out std_ulogic;
      fsm_re_o               : out std_ulogic;
      srctr_idle_i           : in  std_ulogic;
      srctr_end_addr_plus1_i : in  std_ulogic_vector(18 downto 0);
      io_reset_n_i           : in  std_ulogic;
      io_replay_i            : in  std_ulogic;
      io_record_i            : in  std_ulogic);
  end component;

  -------------------------------------------------------------------------
  -- FSM -- I2S
  -------------------------------------------------------------------------
  signal fsm_cs_i2s_reg    : std_ulogic_vector(1 downto 0)  := (others => '0');
  signal i2s_we_re_fsm_reg : std_ulogic_vector(1 downto 0)  := (others => '0');
  -------------------------------------------------------------------------
  -- I2S -- SRCTR
  ------------------------------------------------------------------------- 
  signal srctr_data_reg    : std_ulogic_vector(23 downto 0) := (others => '0');
  signal audio_data_reg    : std_ulogic_vector(23 downto 0) := (others => '0');
  -------------------------------------------------------------------------
  -- FSM -- I2C
  -------------------------------------------------------------------------

  --signal i2c_idle : std_ulogic; 
  --  signal debug_top_reg : std_ulogic_vector(15 downto 0);

-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
  signal fsm_data_i2c_reg         : std_ulogic_vector(15 downto 0) := (others => '0');
  signal fsm_config_i2c_data      : std_ulogic_vector(15 downto 0) := (others => '0');
  signal fsm_we_i2c_reg           : std_ulogic                     := '0';
  -------------------------------------------------------------------------
  -- FSM -- SRCTR
  -------------------------------------------------------------------------
  signal fsm_start_addr_reg       : std_ulogic_vector(18 downto 0) := (others => '0');
  signal fsm_we_reg               : std_ulogic                     := '0';
  signal fsm_re_reg               : std_ulogic                     := '0';
  signal srctr_idle_reg           : std_ulogic                     := '0';
  signal srctr_end_addr_plus1_reg : std_ulogic_vector(18 downto 0) := (others => '0');
  -----------------------------------------------------------------------------

  ----------------------------------------------------------------------------

begin
  mclk_1 : mclk
    port map (
      reset_n_i => reset_n_i,
      clk_i     => clk_i,
      mclk_o    => mclk_o);
  audio_interface_1 : audio_interface
    port map (
      reset_n_i         => reset_n_i,
      -------------------------------------------------------------------------
      -- to/from audio codec
      -------------------------------------------------------------------------      
      bclk_i            => bclk_i,
      adlrclk_i         => adlrclk_i,
      adc_dat_ser_in_i  => adc_dat_ser_in_i,
      dac_dat_ser_out_o => dac_dat_ser_out_o,
      dalrclk_i         => dalrclk_i,
      -------------------------------------------------------------------------
      -- to/from fsm
      -------------------------------------------------------------------------
      fsm_cs_i2s_i      => fsm_cs_i2s_reg,
      i2s_we_re_fsm_o   => i2s_we_re_fsm_reg,

      -------------------------------------------------------------------------
      -- to/from srctr
      -------------------------------------------------------------------------
      dac_dat_para_in_i  => srctr_data_reg,
      adc_dat_para_out_o => audio_data_reg,
      -------------------------------------------------------------------------
      -- to/from I/O
      -------------------------------------------------------------------------      
      ctr_leds           => ctr_leds);
  -----------------------------------------------------------------------------
  -- -
  -----------------------------------------------------------------------------

  I2C_State_machine_1 : I2C_State_machine
    port map (
      clk_i      => clk_i,
      reset_n_i  => reset_n_i,
      data_i     => fsm_data_i2c_reg,
      we_i       => fsm_we_i2c_reg,
  --    i2c_idle_o => i2c_idle,
      i2c_sdin_b => SDAT_b,
      i2c_sclk_o => SCLK_o);
  --    debug_o    => debug_top);

  -- debug_top <= "000000000000000" & SDAT_b;
--  codec_ctrl_1: codec_ctrl
--    port map (
--      reset_n_i      => reset_n_i,
--      clk          => clk_i,

--      -------------------------------------------------------------------------
--      -- to/from fsm
--      -------------------------------------------------------------------------
--      fsm_data_i2c_i => fsm_data_i2c_reg,
--      fsm_we_i2c_i => fsm_we_i2c_reg,

--      -------------------------------------------------------------------------
--      -- to/from audio codec 
--      -------------------------------------------------------------------------
--      SDAT_b       => SDAT_b,
--      SCLK_o       => SCLK_o,
--      -------------------------------------------------------------------------
--      -- I/O
--      -------------------------------------------------------------------------
--      debug_out_o  => open);
  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------
  sram_controler_1 : sram_controler
    port map (
      clk_i                  => clk_i,
      reset_n_i              => reset_n_i,
      -------------------------------------------------------------------------
      -- to/from srctr
      -------------------------------------------------------------------------
      audio_data_i           => audio_data_reg,
      srctr_data_o           => srctr_data_reg,
      -------------------------------------------------------------------------
      -- to/from fsm
      -------------------------------------------------------------------------
      fsm_start_addr_i       => fsm_start_addr_reg,
      fsm_we_i               => fsm_we_reg,
      fsm_re_i               => fsm_re_reg,
      srctr_idle_o           => srctr_idle_reg,
      srctr_end_addr_plus1_o => srctr_end_addr_plus1_reg,
      -------------------------------------------------------------------------
      -- to/from SRAM
      -------------------------------------------------------------------------
      srctr_we_reg_n_o       => srctr_we_reg_n_o,
      srctr_ce_n_o           => srctr_ce_n_o,
      srctr_oe_reg_n_o       => srctr_oe_reg_n_o,
      srctr_lb_n_o           => srctr_lb_n_o,
      srctr_ub_n_o           => srctr_ub_n_o,
      srctr_addr_reg_o       => srctr_addr_reg_o,
      mem_data_b             => mem_data_b);
  fsm_1 : fsm
    port map (
      clk_i                  => clk_i,
      reset_n_i              => reset_n_i,
      -------------------------------------------------------------------------
      -- to/from I2S
      -------------------------------------------------------------------------
      fsm_cs_i2s_o           => fsm_cs_i2s_reg,
      i2s_we_re_fsm_i        => i2s_we_re_fsm_reg,
      -------------------------------------------------------------------------
      -- to/from I2C
      -------------------------------------------------------------------------      
      fsm_we_i2c_o           => fsm_we_i2c_reg,
      fsm_config_i2c_data_o  => fsm_data_i2c_reg,
      -------------------------------------------------------------------------
      -- to/from srctr
      -------------------------------------------------------------------------
      fsm_start_addr_o       => fsm_start_addr_reg,
      fsm_we_o               => fsm_we_reg,
      fsm_re_o               => fsm_re_reg,
      srctr_idle_i           => srctr_idle_reg,
      srctr_end_addr_plus1_i => srctr_end_addr_plus1_reg,
      -------------------------------------------------------------------------
      -- to/from I/O
      -------------------------------------------------------------------------
      io_reset_n_i           => io_reset_n_i,
      io_replay_i            => io_replay_i,
      io_record_i            => io_record_i);



  


  

end rtl;
