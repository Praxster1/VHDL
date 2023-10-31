onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_data_tb/test_case_count
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_data_tb/reset_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_data_tb/clk
add wave -noupdate -divider input-signals
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_data_tb/state
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_data_tb/fsm_we
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_data_tb/audio_data
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_data_tb/addr_reg0
add wave -noupdate -divider output-signals
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_data_tb/mem_data_b
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_data_tb/srctr_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2179395 ps} 0}
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
WaveRestoreZoom {58095 ps} {271043 ps}
