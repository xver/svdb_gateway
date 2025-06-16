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

# Build targets
all: clean create_db svdb_compile compile_verilator_sv run

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

run:
	@echo "Starting run target..."
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
	@echo "Completed run target."

clean:
	rm -rf obj_dir
	rm -f *.log *.vcd
	rm -f $(DB_FILE)

.PHONY: all compile_verilator_sv run clean create_db svdb_compile