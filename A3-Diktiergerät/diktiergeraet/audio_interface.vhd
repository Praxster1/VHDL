

------------------------------
--Design unit: audio_interface
------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity audio_interface is
  port(reset_n_i                    : in  std_ulogic;  --reset
                  bclk_i            : in  std_ulogic;  --bit clock, shift triggered by posedge
                  adlrclk_i         : in  std_ulogic;  --channel select(speaker, stereo...): 
                                                       --0 -> left, 1 -> right (f= sample rate)
                  adc_dat_ser_in_i  : in  std_ulogic;  --incomming serial data
                  dac_dat_ser_out_o : out std_ulogic;  --incomming serial data
                                                       --channel select(speaker, stereo...): 0 -> left, 1 -> right (f= sample rate)
                  dalrclk_i         : in  std_ulogic;

                                                                            --chip select: fsm_cs_i2s_i(0)=1 -> ser-para aktive, fsm_cs_i2s_i(1)=1 -> para-ser aktive
                  fsm_cs_i2s_i       : in  std_ulogic_vector(1 downto 0);
                  i2s_we_re_fsm_o    : out std_ulogic_vector(1 downto 0);
                  dac_dat_para_in_i  : in  std_ulogic_vector(23 downto 0);  --paralism data in
                  adc_dat_para_out_o : out std_ulogic_vector(23 downto 0);  --paralism data out
                                                                            --signalizes the cpu that new data are availabel or that the design is rdy for new input.
                                                                            --element (0) para data available, element (1) rdy for new para data input                              
                  ctr_leds           : out std_ulogic_vector (3 downto 0)
                  );

end audio_interface;

architecture behav of audio_interface is
  signal data_pipe_serpara_s : std_ulogic_vector(23 downto 0) := (others => '0');
  signal data_pipe_paraser_s : std_ulogic_vector(23 downto 0) := (others => '0');
  signal dalrclk_pipe_s      : std_ulogic;
  signal adlrclk_pipe_s      : std_ulogic_vector (1 downto 0);
  signal adlrclk_delayed_s   : std_ulogic;
  signal dalrclk_delayed_s   : std_ulogic;
  signal new_shift_s         : std_ulogic_vector (1 downto 0);
begin
  sreg_ser_para : process (bclk_i, fsm_cs_i2s_i, reset_n_i)
    --need 25counts, due the buffered output! for 24bit shift 
    -- +1 count due the first clock has to be ignored (see audio codec protocol (I2S))
    --(+1 count if decrement is on top, but in this code it isn't) 
    variable bit_count   : integer range 0 to 25 := 25;
    variable first_shift : boolean               := true;
  begin
    if reset_n_i = '0' or fsm_cs_i2s_i(0) = '0' then  --asynchronous reset, set all values to default
      data_pipe_serpara_s <= (others => '0');
      adc_dat_para_out_o  <= (others => '0');
      bit_count           := 25;      --the same init value is needed as above 
      first_shift         := true;
      ctr_leds(0)         <= '0';
      ctr_leds(2)         <= '0';
      i2s_we_re_fsm_o(0)  <= '0';
      --adlrclk_delayed_s <= adlrclk_i;                         
      --adlrclk_pipe_s <= (adlrclk_i & dalrclk_i);      -- flushs the delay-pipe but it don't work ;-(
    elsif bclk_i'event and bclk_i = '1' then  --clock synchr. shift register
      --adlrclk is delayed by 1 dff! because the edges of adlrclk_i and bclk_i are synchronus 
      --Otherwise the edgedetection won't work...see cuncurrent asignment below
      adlrclk_delayed_s               <= adlrclk_i;
      i2s_we_re_fsm_o(0)              <= '0';     --clear interruptrequest ....
      if bit_count >= 1 and bit_count <= 24 then  --if counter between 1 and 24, shift the values
        for I in 23 downto 1 loop
          data_pipe_serpara_s(I) <= data_pipe_serpara_s(I-1);
        end loop;
        data_pipe_serpara_s(0) <= adc_dat_ser_in_i;  --shift the serial data to LSB
        --      adc_dat_para_out_o <= data_pipe_serpara_s;      --for debug...
      elsif bit_count = 0 then
        if first_shift = false then
          adc_dat_para_out_o <= data_pipe_serpara_s;  --overtake shifted values to buffer
        end if;
        i2s_we_re_fsm_o(0) <= '1';      --set interruptrequest
        ctr_leds(0)        <= '1';
        if new_shift_s(0) = '1' then  --if a new shift is triggered, reset counter
          --reset bit counter
          --it takes one clock cycle to come to this position in code 
          --the first clk cycle is not allowed to trigger a shift!!
          --Therefor the reset value is 25!!! it is decremented immediately below.
          --...the position of decrement of counter does't effect this reset value! 
          bit_count   := 25;
                              --data_pipe_serpara_s <= (others => '0');               --...for debug
                              --first shift doesn't effekt output data to prevent unwanted behaviour
          first_shift := false;
          ctr_leds(2) <= '1';
        end if;
      end if;
      if bit_count /= 0 then  --decrement shift counter if it isn't zero...
        bit_count := (bit_count - 1);
      end if;
    end if;
  end process;

  sreg_para_ser : process (bclk_i, fsm_cs_i2s_i, reset_n_i)
    variable bit_count   : integer range 0 to 25 := 25;
    variable first_shift : boolean               := true;
  begin
    if reset_n_i = '0' or fsm_cs_i2s_i(1) = '0' then  --asynchronous reset, set all values to default
      data_pipe_paraser_s <= (others => '0');
      dac_dat_ser_out_o   <= '0';
      bit_count           := 25;
      first_shift         := true;
      ctr_leds(1)         <= '0';
      ctr_leds(3)         <= '0';
      i2s_we_re_fsm_o(1)  <= '0';
    elsif bclk_i'event and bclk_i = '0' then  --clock synchr. shift register
      dalrclk_delayed_s  <= dalrclk_pipe_s;
      --adlrclk is delayed by 2 DFFs! one more because this process is sensitiv to negedge 
      --Otherwise the edgedetection won't work...see cuncurrent asignment below
      dalrclk_pipe_s     <= dalrclk_i;
      i2s_we_re_fsm_o(1) <= '0';        --clear interruptrequest ....   
      if new_shift_s(1) = '1' then  --if a new shift is triggered, reset counter 
        first_shift := false;

        bit_count         := 24;  --...reset value is 24 not 25!!! due the position in code ....
        dac_dat_ser_out_o <= '0';
        ctr_leds(3)       <= '1';
      end if;
      if bit_count >= 1 and bit_count <= 24 then  --if counter between 1 and 24, shift the values
        if first_shift = false then     --in first shift no data are overtaken
          dac_dat_ser_out_o <= data_pipe_paraser_s(23);  --shift the paralel data to serial output
        end if;
        for I in 23 downto 1 loop
          data_pipe_paraser_s(I) <= data_pipe_paraser_s(I-1);
        end loop;
      elsif bit_count = 0 then
        data_pipe_paraser_s <= dac_dat_para_in_i;  --over take shifted values to buffer
        i2s_we_re_fsm_o(1)  <= '1';     --set interruptrequest
        ctr_leds(1)         <= '1';
      end if;
      if bit_count /= 0 then      --decrement shift counter if it isn't zero...
        bit_count := (bit_count - 1);
      end if;
    end if;
  end process;

  --edgedetection
  --cuncurrent assignment, to notice adlrclk event! ...corresponds with xor the adlrclk and the delayed adlrclk
  new_shift_s(0) <= '1' when (adlrclk_i = '0' and adlrclk_delayed_s = '1') or (adlrclk_i = '1' and adlrclk_delayed_s = '0') else '0';
  new_shift_s(1) <= '1' when (dalrclk_i = '0' and dalrclk_delayed_s = '1') or (dalrclk_i = '1' and dalrclk_delayed_s = '0') else '0';

end behav;
