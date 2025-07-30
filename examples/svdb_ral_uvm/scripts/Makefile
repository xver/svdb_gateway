# Makefile for sv_dut simulation (Verilator/VCS)

# Variables
VERILATOR ?= verilator
VCS ?= vcs
SVDB_HOME ?= $(shell cd ../../../ && pwd)
OUTPUT_DIR ?= .
XML_FILE ?= $(SVDB_HOME)/examples/example_registers.xml
DB_FILE ?= $(SVDB_HOME)/examples/example_registers.db
PYTHON ?= python3
PY_UTILS_DIR ?= $(SVDB_HOME)/utils/py
MAKE_SVDB ?= $(SVDB_HOME)/utils/makedir
CFLAGS ?= -I$(SVDB_HOME)/utils/dpi/include
FILES_F ?= ../sim/files.f
SVDB_DPI_PKG = ${SVDB_HOME}/utils/dpi/src/sqlite_dpi_pkg.sv
TOP_MODULE ?= tb_top
COMPILATION_LOG_FILE = verilator_comp.log
TEST_LOG_FILE = verilator_test.log
VCS_EXE = simv
UVM_HOME ?=""
UVM_PKG=$(UVM_HOME)/scr/uvm_pkg.sv
UVM_TESTNAME ?= top_test

# Verilator flags
VERILATOR_FLAGS = --timescale 1ns/1ps \
		--trace \
		-Wall \
		-Wno-UNUSED \
		-Wno-UNDRIVEN \
		-Wno-VARHIDDEN \
		-Wno-ZERODLY \
		-Wno-UNSIGNED \
		-Wno-IMPORTSTAR \
		-Wno-PROCASSINIT \
		-Wno-DECLFILENAME \
		-Wno-COVERIGN \
		-Wno-WIDTHTRUNC \
		-Wno-WIDTHEXPAND \
		-Wno-MODDUP \
		+define+UVM_NO_DPI \
		--binary --build \
		--hierarchical \
		-j 2 \
		+define+UVM_REPORT_DISABLE_FILE_LINE \
		+incdir+$(UVM_HOME) \
		+incdir+$(UVM_HOME)/src \
		+incdir+$(SVDB_HOME)/utils/dpi/src \
		+incdir+$(SVDB_HOME)/utils/dpi/include \
		+incdir+$(SVDB_HOME)/utils/uvm \
		-I$(SVDB_HOME)/utils/dpi/src \
		-I$(SVDB_HOME)/utils/dpi/include

# SVDB Verilator flags
SVDB_VERILATOR_FLAG = -CFLAGS "-I$(SVDB_HOME)/utils/dpi/include" \
                      -CFLAGS "-I$(SVDB_HOME)/utils/c/include" \
                      -LDFLAGS "$(SVDB_HOME)/bin/libdbdpi.so"

# VCS flags
VCS_FLAGS = -full64 -sverilog -debug_access+all -timescale=1ns/1ps -l vcs_comp.log \
	-CFLAGS " -I$(SVDB_HOME)/utils/dpi/include -I$(SVDB_HOME)/utils/c/include $(CFLAGS)" \
    -LDFLAGS "$(SVDB_HOME)/bin/libdbdpi.so"
VCS_RUN_FLAGS = -l vcs_run.log
VCS_EXE = simv

SIM ?= verilator

# Build targets
.PHONY: all compile_verilator_sv compile_vcs_sv run run_verilator run_vcs clean create_db svdb_compile

# Default target
all: clean check_uvm_home create_db svdb_compile
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
	@echo $(SVDB_HOME)
	@echo $(PY_UTILS_DIR)
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
	$(VERILATOR) $(VERILATOR_FLAGS) --cc -f $(FILES_F) $(SVDB_VERILATOR_FLAG) --top-module $(TOP_MODULE) --exe --Mdir $(OUTPUT_DIR)/obj_dir >> $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE) 2>&1 || { cat $(OUTPUT_DIR)/$(COMPILATION_LOG_FILE); exit 1; }
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
	$(VCS) $(VCS_FLAGS) $(SVDB_DPI_PKG) -f $(FILES_F) -o $(OUTPUT_DIR)/$(VCS_EXE)
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
		$(OUTPUT_DIR)/$(VCS_EXE) $(VCS_RUN_FLAGS) +UVM_TESTNAME="$(UVM_TESTNAME)" >> $(OUTPUT_DIR)/vcs_run.log 2>&1 || { cat $(OUTPUT_DIR)/vcs_run.log; exit 1; }; \
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

# Target to check if UVM_HOME exists
.PHONY: check_uvm_home
check_uvm_home:
	@if [ -z "$(UVM_HOME)" ] || [ ! -d "$(UVM_HOME)" ]; then \
		echo "Error: UVM_HOME is not set or does not exist."; \
		exit 1; \
	 else \
		echo "UVM_HOME exists: $(UVM_HOME)"; \
	 fi
