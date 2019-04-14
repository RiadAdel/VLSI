vsim -gui work.counter
add wave -position insertpoint  \
sim:/counter/n \
sim:/counter/enable \
sim:/counter/reset \
sim:/counter/clk \
sim:/counter/load \
sim:/counter/input \
sim:/counter/output
force -freeze sim:/counter/enable 1 0
force -freeze sim:/counter/reset 0 0
force -freeze sim:/counter/reset 1 0
force -freeze sim:/counter/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/counter/load 1 0
force -freeze sim:/counter/input 16#AA 0
run
noforce sim:/counter/reset
force -freeze sim:/counter/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/counter/reset 0 0
run
force -freeze sim:/counter/load 0 0
run