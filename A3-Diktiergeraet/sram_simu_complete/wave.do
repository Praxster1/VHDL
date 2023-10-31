onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/reset_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/clk
add wave -noupdate -divider memory-interface
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_we_reg_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_oe_reg_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_ce_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_ub_n
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_lb_n
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/srctr_addr_reg
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/srctr_data
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/mem_data
add wave -noupdate -divider sram_controler-signals
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/srctr_idle
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/fsm_we
add wave -noupdate -format Logic -radix hexadecimal /sram_controler_tb/fsm_re
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/audio_data
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/fsm_start_addr
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/srctr_end_addr_plus1
add wave -noupdate -divider sram_controler-internal
add wave -noupdate -format Literal -radix hexadecimal /sram_controler_tb/dut/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {680 ns} 0}
configure wave -namecolwidth 169
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
WaveRestoreZoom {656 ns} {705 ns}
