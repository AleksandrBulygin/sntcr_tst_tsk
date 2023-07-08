set_global_assignment -entity "clockDecrease" -library "lib_clockDecrease" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clockDecrease" -library "lib_clockDecrease" -name IP_TOOL_VERSION "22.1"
set_global_assignment -entity "clockDecrease" -library "lib_clockDecrease" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clockDecrease" -name SPD_FILE [file join $::quartus(sip_path) "clockDecrease.spd"]

set_global_assignment -library "lib_clockDecrease" -name MISC_FILE [file join $::quartus(sip_path) "clockDecrease_sim/clockDecrease.vo"]
