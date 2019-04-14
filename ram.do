vsim -gui work.ram
# vsim -gui work.ram 
# Start time: 16:34:10 on Apr 11,2019
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.ram(archram)
# Loading work.counter(counterimplementation)
# Loading work.my_nadder(a_my_nadder)
# Loading work.my_adder(a_my_adder)
add wave  \
sim:/ram/CLK \
sim:/ram/W \
sim:/ram/R \
sim:/ram/address \
sim:/ram/data \
sim:/ram/MFC
force -freeze sim:/ram/address 16#0 0
force -freeze sim:/ram/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/ram/R 1 0
mem load -i *.mem -filltype inc -filldata 0000000000000000 -fillradix symbolic -skip 0 /ram/ram
# ** Error: (vsim-7) Failed to open mem file "*.mem" in read mode.
# Invalid argument. (errno = EINVAL)
mem load -filltype inc -filldata 0000000000000000 -fillradix symbolic -skip 0 /ram/ram
add wave -position insertpoint  \
sim:/ram/mfc_m \
sim:/ram/cReset \
sim:/ram/cEnable \
sim:/ram/cOutput
force -freeze sim:/ram/cReset 1 0
run
noforce sim:/ram/cReset




######################################################################