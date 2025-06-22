# Makefile for register test

# Variables
VERILATOR ?= verilator
SVDB_HOME ?= $(shell cd ../../ && pwd)
OUTPUT_DIR ?= .
XML_FILE ?= $(SVDB_HOME)/examples/example_registers.xml
DB_FILE ?= $(SVDB_HOME)/examples/example_registers.db
PYTHON ?= python3
PY_UTILS_DIR ?= $(SVDB_HOME)/utils/py
MAKE_SVDB ?= $(SVDB_HOME)/utils/makedir
CFLAGS ?= -I$(SVDB_HOME)/utils/dpi/include

# Source files
SVDB_DPI_PKG = ${SVDB_HOME}/utils/dpi/src/sqlite_dpi_pkg.sv
SV_SOURCES = test_registers.sv
CPP_SOURCES = sim_main.cpp
TOP_MODULE = test_registers
COMPILATION_LOG_FILE = verilator_comp.log
TEST_LOG_FILE = verilator_test.log

# Verilator flags
VERILATOR_FLAGS = -Wall -Wno-UNUSED -Wno-UNDRIVEN -Wno-VARHIDDEN \
                  -I$(SVDB_HOME)/utils/dpi/src \
                  -I$(SVDB_HOME)/utils/dpi/include

# SVDB Verilator flags
SVDB_VERILATOR_FLAG = -CFLAGS "-I$(SVDB_HOME)/utils/dpi/include" \
                      -CFLAGS "-I$(SVDB_HOME)/utils/c/include" \
                      -CFLAGS "$(CFLAGS)" \
                      -LDFLAGS "$(SVDB_HOME)/bin/libdbdpi.so"

# VCS variables
VCS = vcs
VCS_FLAGS = -full64 -sverilog -debug_access+all -timescale=1ns/1ps -l vcs_comp.log \
    -CFLAGS "-I$(SVDB_HOME)/utils/dpi/include -I$(SVDB_HOME)/utils/c/include $(CFLAGS)" \
    -LDFLAGS "$(SVDB_HOME)/bin/libdbdpi.so"
VCS_RUN_FLAGS = -l vcs_run.log
VCS_EXE = simv

SIM ?= verilator

# Build targets
.PHONY: all compile_verilator_sv compile_vcs_sv run run_verilator run_vcs clean create_db svdb_compile

# Default target
all: clean create_db svdb_compile
	@if [ "$(SIM)" = "vcs" ]; then \
	  $(MAKE) compile_vcs_sv && \
	  $(MAKE) run_vcs; \
	else \
	  $(MAKE) compile_verilator_sv && \
	  $(MAKE) run_verilator; \
	fi

# Create database from XML
create_db:
	@echo "Creating database from XML file..."
	@cd $(PY_UTILS_DIR) && $(PYTHON) xml_to_sqlite.py $(XML_FILE) -o $(DB_FILE) -d
	@echo "Database created successfully at $(DB_FILE)"

# Compile SVDB libraries
svdb_compile:
	@echo "Starting svdb_compile target..."
	cd $(MAKE_SVDB) && $(MAKE)
	@echo "SVDB C libraries compilation complete."
	@echo "Completed svdb_compile target."

# Compile Verilator target
compile_verilator_sv:
	@echo "Starting compile_verilator_sv target..."
	@mkdir -p $(OUTPUT_DIR)
	@echo "Compiling with Verilator..." > $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE)
	$(VERILATOR) $(VERILATOR_FLAGS) --cc $(SVDB_DPI_PKG) $(SV_SOURCES) $(SVDB_VERILATOR_FLAG) --top-module $(TOP_MODULE) --exe $(CPP_SOURCES) --Mdir $(OUTPUT_DIR)/obj_dir >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE) 2>&1 || { cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); exit 1; }
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
	$(VCS) $(VCS_FLAGS) $(SVDB_DPI_PKG) $(SV_SOURCES) -o $(OUTPUT_DIR)/$(VCS_EXE)
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
	@if [ "$(SIM)" = "vcs" ]; then \
	  $(MAKE) run_vcs; \
	else \
	  $(MAKE) run_verilator; \
	fi

clean:
	rm -rf obj_dir
	rm -f *.log *.vcd
	rm -f $(DB_FILE)
	# VCS artifacts
	rm -f simv
	rm -rf csrc
	rm -rf simv.daidir
	rm -f vc_hdrs.h
	rm -f ucli.key
	rm -f vcs_comp.log
	rm -f vcs_run.log