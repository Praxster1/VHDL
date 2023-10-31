onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /prng_tb/clk_count
add wave -noupdate /prng_tb/prng_1/sw0
add wave -noupdate /prng_tb/prng_1/clock_27
add wave -noupdate /prng_tb/prng_1/key0
add wave -noupdate -radix hexadecimal -childformat {{/prng_tb/prng_1/prng_reg(8) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(7) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(6) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(5) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(4) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(3) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(2) -radix hexadecimal} {/prng_tb/prng_1/prng_reg(1) -radix hexadecimal}} -expand -subitemconfig {/prng_tb/prng_1/prng_reg(8) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(7) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(6) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(5) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(4) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(3) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(2) {-height 15 -radix hexadecimal} /prng_tb/prng_1/prng_reg(1) {-height 15 -radix hexadecimal}} /prng_tb/prng_1/prng_reg
add wave -noupdate -radix hexadecimal /prng_tb/prng_1/ledr
add wave -noupdate -radix hexadecimal /prng_tb/prng_1/gpio_1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {167686 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1245014 ps}
