vsim -gui work.main
# vsim -gui work.main 
# Start time: 15:24:39 on Apr 15,2019
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading work.constants
# Loading ieee.numeric_std(body)
# Loading work.main(vlsi)
# Loading work.ram(archram)
# Loading work.counter(counterimplementation)
# Loading work.my_nadder(a_my_nadder)
# Loading work.my_adder(a_my_adder)
# Loading work.readinfostate(archreadinfostate)
# Loading work.nbitregister(data_flow)
# Loading work.tristatebuffer(tribuffer)
mem load -filltype dec -filldata 0 -fillradix symbolic -skip 0 /main/FilterMem/ram
mem load -filltype rand -filldata 1 -fillradix symbolic -skip 0 /main/ImgMem/ram
# (vsim-3660) Value '1' is not legal data for filltype 'rand'.
mem load -filltype rand -filldata 0000000000000001 -fillradix symbolic -skip 0 /main/ImgMem/ram
# (vsim-3660) Value '0000000000000001' is not legal data for filltype 'rand'.
mem load -filltype rand -filldata 000000000000000 -fillradix symbolic -skip 0 /main/ImgMem/ram
mem load -filltype rand -filldata 1 -fillradix symbolic -skip 0 /main/FilterMem/ram
# (vsim-3660) Value '1' is not legal data for filltype 'rand'.
mem load -filltype rand -filldata 16#0 -fillradix symbolic -skip 0 /main/FilterMem/ram
add wave -position insertpoint  \
sim:/main/rst \
sim:/main/clk \
sim:/main/LayerInfoOut \
sim:/main/next_state \
sim:/main/current_state \
sim:/main/FilterAddressEN \
sim:/main/FilterAddressIN \
sim:/main/FilterAddressOut \
sim:/main/ImgAddRegEN \
sim:/main/ImgAddRegIN \
sim:/main/ImgAddRegOut \
sim:/main/TriStateCounterEN \
sim:/main/TriStateCounterOUT \
sim:/main/ImgAddACKTriEN \
sim:/main/ImgAddACKTriOUT \
sim:/main/zero \
sim:/main/ImgAddACKTriIN \
sim:/main/WriteF \
sim:/main/ReadF \
sim:/main/AddressF \
sim:/main/DataF \
sim:/main/ACKF \
sim:/main/WriteI \
sim:/main/ReadI \
sim:/main/AddressI \
sim:/main/DataI \
sim:/main/ACKI \
sim:/main/NoOfLayers
force -freeze sim:/main/rst 1 0
force -freeze sim:/main/clk 1 0, 0 {50 ps} -r 100
run