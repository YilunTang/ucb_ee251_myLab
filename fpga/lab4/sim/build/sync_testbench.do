proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start sync_testbench
add wave sync_testbench/*
add wave sync_testbench/DUT/*
run 1000ms
