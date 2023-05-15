# Runtime variables
GHDL_ARGS = --std=93c --ieee=synopsys -fexplicit -Wno-pure -P$(GHDL_XILINX_LIB) -P$(GHDL_LATTICE_LIB)
GHDL_BUILD_DIR = "build/ghdl"
