


sim:
	verilator --cc --exe --build -Wall --trace src/hw/top.v src/sw/Vtop.cpp && ./obj_dir/Vtop

wave:
	gtkwave ./obj_dir/wave.vcd

clean:
	rm -rf obj_dir