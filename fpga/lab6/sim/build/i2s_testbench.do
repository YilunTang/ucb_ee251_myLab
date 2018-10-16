proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start i2s_controller_testbench
add wave i2s_controller_testbench/*
add wave i2s_controller_testbench/i2s/*
add wave i2s_controller_testbench/DUT/*
run 10ms