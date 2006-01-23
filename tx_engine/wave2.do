onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA_VALID
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA_VALID_REG
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/TX_DATA_REG
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_CLK
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/RESET
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_START
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_UNDERRUN
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/TX_ACK
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/FC_TRANS_PAUSEDATA
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FC_TRANS_PAUSEVAL
add wave -noupdate -divider {Main Control}
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/append_start_pause
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame_del
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/RESET_ERR_PAUSE
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PAUSEVAL_DEL1
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PAUSEVAL_DEL2
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL1
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL2
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL3
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL4
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL5
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL6
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL7
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_PAUSE_DEL8
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL1
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL2
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL3
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL4
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL5
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL6
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL7
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_PAUSE_DEL8
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/transmit_pause_frame_valid
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/store_transmit_pause_value
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/pause_frame_counter
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/shift_pause_data
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/shift_pause_valid
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/FC_TX_PAUSEDATA
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FC_TX_PAUSEVALID
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/apply_pause_delay
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/length_register
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FRAME_START
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FRAME_START_DEL
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/insert_error
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/DATA_SIZE
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/store_data
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/store_valid
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/store_CRC
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/APPEND_CRC_COUNT
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA_VALID_REG
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/TX_DATA_REG
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/BYTE_COUNTER
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/CRC_32_64
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/load_CRC8
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/error_flag_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/PARALLEL_CNT
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/CRC_OUT
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/tx_data_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/start_CRC8
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/START_CRC8_DEL
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/LOAD_CRC
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/LOAD_OVERFLOW
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/store_byte_count
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/CRC8_COUNT
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/shift_pause_data
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL1
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL2
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL3
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL4
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL5
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL6
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL7
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL8
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL9
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL10
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL11
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXD_DEL12
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL1
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL2
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL3
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL4
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL5
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL6
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL7
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL8
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL9
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL10
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TXC_DEL11
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/TXC_DEL12
add wave -noupdate -divider CRC8
add wave -noupdate -format Literal /TransmitTop_tb/U_top_module/U_CRC8/DATA_IN
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC8/CLK
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC8/RESET
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC8/START
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC8/LOAD
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/U_CRC8/CRC_IN
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/U_CRC8/CRC_OUT
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC8/start_int
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/U_CRC8/data_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/FRAME_START
add wave -noupdate -divider CRC
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA_VALID_REG
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/TX_DATA_REG
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/U_CRC64/DATA_IN
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/U_CRC64/CRC_OUT
add wave -noupdate -format Literal -radix hexadecimal /TransmitTop_tb/U_top_module/U_CRC64/CRC_REG
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC64/start_int
add wave -noupdate -format Logic /TransmitTop_tb/U_top_module/U_CRC64/startCRC
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/U_CRC64/data_del
add wave -noupdate -format Literal -radix unsigned /TransmitTop_tb/U_top_module/DELAY_ACK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {710 ns} 0}
WaveRestoreZoom {524 ns} {773 ns}
configure wave -namecolwidth 394
configure wave -valuecolwidth 193
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
