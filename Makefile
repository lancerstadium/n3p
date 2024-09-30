


sim:
	verilator --cc --exe --build -Wall --trace src/hw/top.v src/sw/Vtop.cpp

clean:
	rm -rf obj_dir