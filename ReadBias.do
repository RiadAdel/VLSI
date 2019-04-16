vsim -gui work.readbias
add wave -position insertpoint  \
sim:/readbias/STATE \
sim:/readbias/BIAS \
sim:/readbias/FilterAddress \
sim:/readbias/NOofFilters \
sim:/readbias/CLK \
sim:/readbias/RST \
sim:/readbias/DMAAddress \
sim:/readbias/UpdatedAddress \
sim:/readbias/outBias0 \
sim:/readbias/outBias1 \
sim:/readbias/outBias2 \
sim:/readbias/outBias3 \
sim:/readbias/outBias4 \
sim:/readbias/outBias5 \
sim:/readbias/outBias6 \
sim:/readbias/outBias7
force -freeze sim:/readbias/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/readbias/RST 1 0
force -freeze sim:/readbias/BIAS 11110000100011001010100110111101 0
force -freeze sim:/readbias/STATE 1 0
run
force -freeze sim:/readbias/RST 0 0
force -freeze sim:/readbias/FilterAddress 0000 0
force -freeze sim:/readbias/NOofFilters 0004 0
run
run

