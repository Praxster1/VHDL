onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testbench Stimuli}
add wave -noupdate -radix hexadecimal /uart_tb/res_n
add wave -noupdate -radix hexadecimal /uart_tb/clk
add wave -noupdate -radix hexadecimal /uart_tb/start
add wave -noupdate -radix hexadecimal /uart_tb/data
add wave -noupdate -divider {Testcase Parameters}
add wave -noupdate -radix decimal /uart_tb/testcase_number_s
add wave -noupdate /uart_tb/wave_gen_p/baud_rate_v
add wave -noupdate /uart_tb/wave_gen_p/num_bauds_v
add wave -noupdate /uart_tb/wave_gen_p/noise_count_v
add wave -noupdate -divider {DUT Signals + expected signals}
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_valid_exp
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_valid_dut
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_exp
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_dut
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_min_exp
add wave -noupdate -radix hexadecimal /uart_tb/baud_count_min_dut
add wave -noupdate -divider {DUT Signals}
add wave -noupdate /uart_tb/dut/state_reg
add wave -noupdate /uart_tb/dut/baud_count_valid_o
add wave -noupdate -radix hexadecimal /uart_tb/dut/baud_count_reg
add wave -noupdate -radix hexadecimal /uart_tb/dut/baud_count_plus1_s
add wave -noupdate -radix hexadecimal /uart_tb/dut/baud_count_min_o
add wave -noupdate -radix hexadecimal /uart_tb/dut/data_chg_count_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {80580 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 173
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
WaveRestoreZoom {15 ns} {1822 ns}
