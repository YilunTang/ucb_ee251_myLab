proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start fifo_testbench
add wave fifo_testbench/*
add wave fifo_testbench/DUT/*
run 10ms