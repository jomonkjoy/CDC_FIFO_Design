create_clock -period 16.000 [get_ports cpu_m_clk]
create_clock -period 08.000 [get_ports cpu_s_clk]

set_input_delay  -clock [get_clocks cpu_m_clk] -max 0.020 [get_ports -filter { NAME =~ "*cpu_m*" && DIRECTION == "IN" }]
set_output_delay -clock [get_clocks cpu_m_clk] -max 0.010 [get_ports -regexp -nocase -filter { NAME =~ ".*cpu_m.*" && DIRECTION == "OUT" }]
set_input_delay  -clock [get_clocks cpu_s_clk] -max 0.020 [get_ports -filter { NAME =~ "*cpu_s*" && DIRECTION == "IN" }]
set_output_delay -clock [get_clocks cpu_s_clk] -max 0.010 [get_ports -regexp -nocase -filter { NAME =~ ".*cpu_s.*" && DIRECTION == "OUT" }]

set_max_delay -from [get_pins sync_request/back_reg/C]  -to [get_pins sync_request/*sync_pulsegen_aack/q0_reg/D]  8.0
set_max_delay -from [get_pins sync_response/back_reg/C] -to [get_pins sync_response/*sync_pulsegen_aack/q0_reg/D] 8.0

set_max_delay -from [get_pins sync_request/aenable_reg/C]  -to [get_pins sync_request/*sync_pulsegen_benable/q0_reg/D]  8.0
set_max_delay -from [get_pins sync_response/aenable_reg/C] -to [get_pins sync_response/*sync_pulsegen_benable/q0_reg/D] 8.0

set_false_path -from [get_pins {sync_request/data_reg[*]/C}]  -to [get_pins {sync_request/bdata_reg[*]/D}]
set_false_path -from [get_pins {sync_response/data_reg[*]/C}] -to [get_pins {sync_response/bdata_reg[*]/D}]
