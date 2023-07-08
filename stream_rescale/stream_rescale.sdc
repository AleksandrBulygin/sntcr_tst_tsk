## Generated SDC file "stream_rescale..sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition"

## DATE    "Wed Jul  5 14:33:41 2023"

##
## DEVICE  "5CEBA4F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 16 -divide_by 5 -master_clock {clk} [get_pins {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 8 -master_clock {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -rise_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -fall_to [get_clocks {clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 3.75 [get_ports s_data_i*]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1.0 [get_ports s_data_i*]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 3.25 [get_ports s_keep_i*]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1.0 [get_ports s_keep_i*]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 2.5 [get_ports {s_last_i s_valid_i m_ready_i}]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1.0 [get_ports {s_last_i s_valid_i m_ready_i}]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 2.0 [get_ports {rst_n}]
set_input_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1.0 [get_ports {rst_n}]


#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -min 0.0 [get_ports m_data_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -max 12.5 [get_ports m_data_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -min 0.0 [get_ports m_keep_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -max 12.5 [get_ports m_keep_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -rise -min 0.0 [get_ports s_ready_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -rise -max 2.5 [get_ports s_ready_o*]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -min 0.0 [get_ports {m_last_o m_valid_o}]
set_output_delay -clock { clockDecrease_inst|clockdecrease_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -fall -max 12.5 [get_ports {m_last_o m_valid_o}]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

