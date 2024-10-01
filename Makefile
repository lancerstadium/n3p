OBJ_DIR		:= obj_dir
SRC_DIR 	:= src
NTOP  		?= top
VTOP		:= $(SRC_DIR)/hw/$(NTOP).v
CTOP		:= $(SRC_DIR)/sw/V$(NTOP).cpp
CSIM		:= V$(NTOP)
WAVE  		:= $(OBJ_DIR)/wave.vcd
VSRC		:= $(filter-out $(VTOP) %_tb.v,$(wildcard $(SRC_DIR)/hw/*.v))
CSRC		:= $(wildcard $(SRC_DIR)/sw/*.c $(SRC_DIR)/sw/*.cc $(SRC_DIR)/sw/*.cpp)



sim: $(VTOP) $(VSRC) $(CTOP)
	verilator --cc --exe --build -Wall --trace --top-module $(NTOP) $(VTOP) $(VSRC) $(CTOP)

run: $(OBJ_DIR)/$(CSIM)
	cd $(OBJ_DIR) && ./$(CSIM)

wave: $(WAVE)
	gtkwave $(WAVE)

clean:
	rm -rf $(OBJ_DIR)