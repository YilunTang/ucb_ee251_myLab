proc start {m} {vsim -L unisims_ver -L unimacro_ver -L secureip $m work.glbl}
start tone_generator_testbench
add wave tone_generator_testbench/*
add wave tone_generator_testbench/audio_controller/*
run 10000ms
