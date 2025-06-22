# Makefile
VERILATOR = verilator
VERILATOR_FLAGS = -Wall --trace
SIM_MAIN = sim_main.cpp
TOP_MODULE = test_sqlite
OUTPUT_DIR = .

# Set default SVDB_HOME if not already set
ifeq (${SVDB_HOME},)
    SVDB_HOME := $(shell cd ../../.. && pwd)
endif

# Initialize CFLAGS with common flags
BASE_CFLAGS = -fPIC -shared -I${SVDB_HOME}/utils/c/include -I${SVDB_HOME}/utils/dpi/include -I/usr/include
CFLAGS = $(BASE_CFLAGS)

# Debug flag for verbose output
ifeq ($(DEBUG),1)
    CFLAGS += -DVERBOSE=1
    $(info Debug mode enabled: VERBOSE=1)
endif

COMPILATION_LOG_FILE = verilator_comp.log
TEST_LOG_FILE = verilator_test.log
LIBDBDPI_PATH = ${SVDB_HOME}/bin/libdbdpi.so

# Define source files in correct order
SVDB_DPI_PKG = ${SVDB_HOME}/utils/dpi/src/sqlite_dpi_pkg.sv
CS_COMMON = cs_common.svh
TEST_FILE = test_sqlite.sv

 # Define Verilator flags
SVDB_VERILATOR_FLAG = -CFLAGS "-I${SVDB_HOME}/utils/dpi/include" \
                      -CFLAGS "-I${SVDB_HOME}/utils/c/include" \
                      -CFLAGS "$(CFLAGS)" \
                      -LDFLAGS "${SVDB_HOME}/bin/libdbdpi.so"

MAKE_SVDB = ../../makedir

SIM ?= verilator
# VCS variables
VCS = vcs
VCS_FLAGS = -full64 -sverilog -debug_access+all -timescale=1ns/1ps -l vcs_comp.log \
    -CFLAGS "-I${SVDB_HOME}/utils/dpi/include -I${SVDB_HOME}/utils/c/include $(CFLAGS)" \
    -LDFLAGS "${SVDB_HOME}/bin/libdbdpi.so"
VCS_RUN_FLAGS = -l vcs_run.log
VCS_EXE = simv

.PHONY: all clean run svdb_compile compile_verilator_sv compile_vcs_sv run_verilator run_vcs help debug

# Default target
all:
	@echo "Starting all target..."
	$(MAKE) clean && \
	$(MAKE) svdb_compile && \
	if [ "$(SIM)" = "vcs" ]; then \
	  $(MAKE) compile_vcs_sv && \
	  $(MAKE) run_vcs; \
	else \
	  $(MAKE) compile_verilator_sv && \
	  $(MAKE) run_verilator; \
	fi

# Debug target
debug:
	@echo "Starting debug target..."
	$(MAKE) DEBUG=1 clean && \
	$(MAKE) DEBUG=1 svdb_compile && \
	if [ "$(SIMULATOR)" = "vcs" ]; then \
	  $(MAKE) DEBUG=1 compile_vcs_sv && \
	  $(MAKE) DEBUG=1 run_vcs; \
	else \
	  $(MAKE) DEBUG=1 compile_verilator_sv && \
	  $(MAKE) DEBUG=1 run_verilator; \
	fi && \
	echo "Completed debug target."

# Display help information
help:
	@echo "SVDB Gateway Makefile Help"
	@echo "=========================="
	@echo "Available targets:"
	@echo "  all                 : Default target. Cleans, compiles SVDB libraries, compiles Verilator code, and runs simulation"
	@echo "  debug              : Same as all but with verbose debugging enabled"
	@echo "  svdb_compile       : Compiles the SVDB C libraries"
	@echo "  compile_verilator_sv: Compiles SystemVerilog code with Verilator"
	@echo "  compile_vcs_sv     : Compiles SystemVerilog code with VCS"
	@echo "  run_verilator      : Runs the simulation with Verilator"
	@echo "  run_vcs            : Runs the simulation with VCS"
	@echo "  clean              : Removes all generated files and directories"
	@echo "  help               : Displays this help message"

	@echo ""
	@echo "Configuration variables:"
	@echo "  OUTPUT_DIR         : Directory for output files (default: .)"
	@echo "  VERILATOR          : Path to Verilator executable (default: verilator)"
	@echo "  MAKE_SVDB          : Path to SVDB makedir (default: ../../makedir)"
	@echo "  LIBDBDPI_PATH      : Path to libdbdpi.so library (default: \${SVDB_HOME}/bin/libdbdpi.so)"
	@echo "  SVDB_HOME          : Path to svdb_gateway root directory (default: automatically detected)"
	@echo "  DEBUG              : Set to 1 to enable verbose debugging (default: not set)"
	@echo "  SIM                : Selects simulator (default: verilator, option: vcs)"
	@echo ""
	@echo "Example usage:"
	@echo "  make               : Run all targets"
	@echo "  make DEBUG=1       : Run all targets with verbose debugging enabled"
	@echo "  make debug         : Run all targets with verbose debugging enabled"
	@echo "  make OUTPUT_DIR=./output : Run all targets with custom output directory"
	@echo "  make SIMULATOR=vcs : Run all targets with VCS"
	@echo "  make help          : Show this help"

# Clean target
clean:
	@echo "Starting clean target..."
	rm -rf ./obj_dir
	rm -f ./verilator_comp.log ./verilator_test.log
	$(MAKE) -C $(MAKE_SVDB) -f c.mk clean
	@echo "Completed clean target."

# SVDB compile target
svdb_compile:
	@echo "Starting svdb_compile target..."
	$(MAKE) -C $(MAKE_SVDB) -f c.mk all CFLAGS="$(CFLAGS)" >> ./verilator_comp.log 2>&1 || { cat ./verilator_comp.log; exit 1; }
	@echo "SVDB C libraries compilation complete."
	@echo "Completed svdb_compile target."

# Compile Verilator target
compile_verilator_sv:
	@echo "Starting compile_verilator_sv target..."
	@mkdir -p $(OUTPUT_DIR)
	@echo "Compiling with Verilator..." > $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)
	${VERILATOR} $(VERILATOR_FLAGS) --cc $(SVDB_DPI_PKG) $(CS_COMMON) $(TEST_FILE) $(SVDB_VERILATOR_FLAG) --top-module $(TOP_MODULE) --exe $(SIM_MAIN) --Mdir $(OUTPUT_DIR)/obj_dir >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE) 2>&1 || { cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); exit 1; }
	@echo "Command: make -C $(OUTPUT_DIR)/obj_dir -j -f V$(TOP_MODULE).mk V$(TOP_MODULE)" >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)
	@if [ -d "$(OUTPUT_DIR)/obj_dir" ]; then \
		make -C $(OUTPUT_DIR)/obj_dir -j -f V$(TOP_MODULE).mk V$(TOP_MODULE) >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE) 2>&1 || { cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); exit 1; }; \
	else \
		echo "Error: obj_dir not created, Verilator compilation failed" >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); \
		cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); \
		exit 1; \
	fi
	@echo "Compilation complete. Compilation log file generated: $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)" >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)
	@cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)
	@echo "Completed compile_verilator_sv target."

# Compile VCS target
compile_vcs_sv:
	@echo "Starting compile_vcs_sv target..."
	@mkdir -p $(OUTPUT_DIR)
	$(VCS) $(VCS_FLAGS) $(SVDB_DPI_PKG) $(CS_COMMON) $(TEST_FILE) -o $(OUTPUT_DIR)/$(VCS_EXE)
	@echo "Compilation complete. Compilation log file generated: vcs_comp.log"
	@cat vcs_comp.log
	@echo "Completed compile_vcs_sv target."

# Run Verilator target
run_verilator:
	@echo "Starting run_verilator target..."
	@echo "Running simulation..." > $(OUTPUT_DIR)/$(TEST_LOG_FILE)
	@echo "Command: $(OUTPUT_DIR)/obj_dir/V$(TOP_MODULE)" >> $(OUTPUT_DIR)/$(TEST_LOG_FILE)
	@if [ -x "$(OUTPUT_DIR)/obj_dir/V$(TOP_MODULE)" ]; then \
		$(OUTPUT_DIR)/obj_dir/V$(TOP_MODULE) >> $(OUTPUT_DIR)/$(TEST_LOG_FILE) 2>&1 || { cat $(OUTPUT_DIR)/$(TEST_LOG_FILE); exit 1; }; \
	else \
		echo "Error: Executable $(OUTPUT_DIR)/obj_dir/V$(TOP_MODULE) not found or not executable" >> $(OUTPUT_DIR)/$(TEST_LOG_FILE); \
		cat $(OUTPUT_DIR)/$(TEST_LOG_FILE); \
		exit 1; \
	fi
	@echo "Simulation complete. Test log file generated: $(OUTPUT_DIR)/$(TEST_LOG_FILE)" >> $(OUTPUT_DIR)/$(TEST_LOG_FILE)
	@cat $(OUTPUT_DIR)/$(TEST_LOG_FILE)
	@echo "Completed run_verilator target."

# Run VCS target
run_vcs:
	@echo "Starting run_vcs target..."
	@echo "Running simulation..." > $(OUTPUT_DIR)/vcs_run.log
	@echo "Command: $(OUTPUT_DIR)/$(VCS_EXE)" >> $(OUTPUT_DIR)/vcs_run.log
	@if [ -x "$(OUTPUT_DIR)/$(VCS_EXE)" ]; then \
		$(OUTPUT_DIR)/$(VCS_EXE) $(VCS_RUN_FLAGS) >> $(OUTPUT_DIR)/vcs_run.log 2>&1 || { cat $(OUTPUT_DIR)/vcs_run.log; exit 1; }; \
	else \
		echo "Error: Executable $(OUTPUT_DIR)/$(VCS_EXE) not found or not executable" >> $(OUTPUT_DIR)/vcs_run.log; \
		cat $(OUTPUT_DIR)/vcs_run.log; \
		exit 1; \
	fi
	@echo "Simulation complete. VCS run log file generated: $(OUTPUT_DIR)/vcs_run.log" >> $(OUTPUT_DIR)/vcs_run.log
	@cat $(OUTPUT_DIR)/vcs_run.log
	@echo "Completed run_vcs target."

# Update run target to select simulator
run:
	@if [ "$(SIMULATOR)" = "vcs" ]; then \
	  $(MAKE) run_vcs; \
	else \
	  $(MAKE) run_verilator; \
	fi

