proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start debouncer_testbench
add wave debouncer_testbench/*
add wave debouncer_testbench/DUT/*
add wave debouncer_testbench/DUT/sat_counter/*
run 1000ms
