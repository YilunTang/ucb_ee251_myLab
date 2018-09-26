proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start edge_detector_testbench
add wave edge_detector_testbench/*
run 1000ms
