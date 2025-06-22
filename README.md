# Welcome to the **SVDB Gateway**! [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)
![](https://github.com/xver/svdb_gateway/blob/main/docs/svdb_log_min.png)

# SQLite Database Gateway for SystemVerilog

## Overview

SVDB Gateway provides a bridge between SystemVerilog and SQLite databases, allowing SystemVerilog code to interact with SQLite databases through a Direct Programming Interface (DPI).
### Use Cases

#### Hardware Verification
- **Register Map Management**: Store and query register configurations during simulation
- **Configuration Storage**: Persist test configurations and results
- **Logging Systems**: Log simulation data and events to database
- **Coverage Tracking**: Track verification coverage metrics

#### IP-XACT Integration
- **Component Libraries**: Convert IP-XACT component descriptions to database format
- **Register Map Generation**: Generate register maps from IP-XACT descriptions
- **Configuration Management**: Store and retrieve hardware configurations
- **Version Control**: Track component versions and changes

#### Database Operations
- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **Transaction Management**: ACID-compliant database transactions
- **Index Optimization**: Performance optimization through database indexing
- **Schema Management**: Comprehensive database schema validation


## Project Structure

```
svdb_gateway/
├── bin/                  # Compiled binaries output (libdbdpi.so)
├── docs/                # Auto-generated documentation
├── examples/            # Example code and demonstrations
│   ├── example_registers.xml      # IP-XACT component example
│   ├── example_registers.db       # Generated SQLite database
│   └── sv_regs/                   # SystemVerilog register examples
│       ├── test_registers.sv      # Register testing module
│       ├── sim_main.cpp           # verilator simulation entry
│       └── Makefile               # Build configuration
├── utils/
│   ├── c/              # C utilities and primitives
│   │   ├── include/    # C header files
│   │   └── src/        # C source files
│   ├── dpi/            # DPI interface layer
│   │   ├── include/    # DPI header files
│   │   └── src/        # DPI source files and SystemVerilog package
│   ├── makedir/        # Build system and Makefiles
│   ├── py/             # Python utilities
│   │   ├── xml_to_sqlite.py  # XML to SQLite converter
│   │   ├── sqlite_to_xml.py  # SQLite to XML converter
│   │   └── schema.sql        # Database schema definition
│   └── tests/          # Test suite
│       ├── sv/         # SystemVerilog tests
│       │   ├── test_sqlite.sv    # Main test file (11 test cases)
│       │   ├── sim_main.cpp      # verilator simulation entry
│       │   ├── cs_common.svh     # Common definitions
│       │   └── Makefile          # Test build rules
│       └── py/         # Python tests
│           ├── test_xml_to_sqlite.py  # Test for xml_to_sqlite.py
│           ├── test_sqlite_to_xml.py  # Test for sqlite_to_xml.py
│           └── Makefile          # Makefile for running Python tests
└── README.md           # This file
```
## HTML Documentation
 [API](https://rawcdn.githack.com/xver/svdb_gateway/006cad2a8c055f7b520c0ee1efae61d0952c2629/docs/index.html)
## Features

### Core Functionality
- **SQLite Database Operations**: Complete CRUD operations from SystemVerilog
- **DPI Bridge**: Direct Programming Interface for seamless integration
- **IP-XACT Support**: XML to SQLite conversion for component descriptions
- **Bidirectional Conversion**: XML ↔ SQLite conversion utilities
- **Index Management**: Database indexing for performance optimization

### Advanced Features
- **Register Management**: Specialized functions for hardware register operations
- **Cell-Level Access**: Granular data access with `get_cell_value` and `get_rowid_by_column_value`
- **Schema Validation**: Comprehensive database schema validation
- **Error Handling**: Robust error reporting and logging
- **Multi-Namespace Support**: IP-XACT and SPIRIT namespace handling

### Testing & Verification
- **Comprehensive Test Suite**: 11 test cases covering all major functionality
- **Register Examples**: Real-world IP-XACT component testing
- **Build System**: Automated compilation and testing with Verilator/VCS support

## Recent Updates

### Latest Changes (v0.0.2)
- **Enhanced DPI Functions**: Added `sqlite_dpi_get_rowid_by_column_value()` and `sqlite_dpi_get_cell_value()`
- **Register Examples**: New `examples/sv_regs/` with comprehensive register testing
- **Improved Testing**: Enhanced test coverage with 11 passing test cases
- **Code Cleanup**: Removed problematic `sqlite_dpi_get_all_rows` function
- **Better Documentation**: Updated comments and documentation throughout

### Support
- For assistance with **SVDB Gateway** integration or customization, contact us at icshunt.help@gmail.com
- Report bugs to [Issues](https://github.com/xver/svdb_gateway/issues)

## Requirements

### System Requirements
- **C/C++ Compiler** (GCC recommended)
  - GCC 9.4.0 or later
  - Clang 12.0.0 or later
- **SQLite Development Libraries**
  - SQLite 3.37.0 or later
  - libsqlite3-dev package

### Verification Tools
- **For SystemVerilog Testing**:
  - Verilator 5.014 or later
  - Make 4.3 or later
- **Optional**: VCS (Synopsys VCS) for alternative simulation

### Python Dependencies
- **Python**: 3.8.0 or later
- **Required Packages** (all built-in):
  - `sqlite3` (3.8.0 or later)
  - `xml.etree.ElementTree` (3.8.0 or later)
  - `argparse` (3.8.0 or later)
  - `hashlib` (3.8.0 or later)
  - `datetime` (3.8.0 or later)
  - `logging` (3.8.0 or later)
  - `typing` (3.8.0 or later)
  - `os` (3.8.0 or later)

## Quick Start

### Building the Project
```bash
cd utils/makedir
make
```

### Running SystemVerilog Tests
```bash
cd utils/tests/sv
make
```

### Running Register Examples
```bash
cd examples/sv_regs
make
```

## API Overview

### Core Database Operations
```systemverilog
// Database connection management
chandle db = sqlite_dpi_open_database("database.db");
sqlite_dpi_close_database(db);

// Basic operations
sqlite_dpi_execute_query(db, "SELECT * FROM table");
sqlite_dpi_create_table(db, "table_name", "column_definitions");
sqlite_dpi_drop_table(db, "table_name");

// Row operations
int row_id = sqlite_dpi_insert_row(db, "table", "columns", "values");
sqlite_dpi_delete_row(db, "table", row_id);
sqlite_dpi_get_row(db, "table", row_id);

// Advanced lookup functions
int row_id = sqlite_dpi_get_rowid_by_column_value(db, "table", "column", "value");
string cell_value = sqlite_dpi_get_cell_value(db, "table", row_id, "column");

// Transaction control
sqlite_dpi_begin_transaction(db);
sqlite_dpi_commit_transaction(db);
sqlite_dpi_rollback_transaction(db);

// Index management
sqlite_dpi_create_index(db, "index_name", "table", "column");
sqlite_dpi_drop_index(db, "index_name");

// Database maintenance
sqlite_dpi_vacuum_database(db);
```

## Makefile Help

The project includes comprehensive Makefiles with multiple targets and configuration options:

### Available Targets
- `make` or `make all`: Default target - clean, compile, and run simulation
- `make debug`: Same as all but with verbose debugging enabled
- `make svdb_compile`: Compiles the SVDB C libraries
- `make compile_verilator_sv`: Compiles SystemVerilog code with Verilator
- `make compile_vcs_sv`: Compiles SystemVerilog code with VCS
- `make run_verilator`: Runs the simulation with Verilator
- `make run_vcs`: Runs the simulation with VCS
- `make clean`: Removes all generated files and directories
- `make help`: Displays detailed help information

### Configuration Variables
- `OUTPUT_DIR`: Directory for output files (default: .)
- `VERILATOR`: Path to Verilator executable (default: verilator)
- `SVDB_HOME`: Path to svdb_gateway root directory (auto-detected)
- `DEBUG`: Set to 1 to enable verbose debugging
- `SIM`: Selects simulator (default: verilator, option: vcs)

### Example Usage
```bash
# Run all targets
make

# Run with verbose debugging
make DEBUG=1
# or
make debug

# Run with custom output directory
make OUTPUT_DIR=./output

# Run with VCS simulator
make SIM=vcs
make or make SIM=verilator (default)

# Show help information
make help
```

## Python Utilities

The project includes powerful Python utilities for XML and SQLite database operations:

### XML to SQLite Conversion
Convert IP-XACT XML files to SQLite database format:
```bash
cd utils/py
python3 xml_to_sqlite.py input.xml -o database.db [-d]
```
or process multiple files:
```bash
python3 xml_to_sqlite.py -f file_list.txt -o database.db [-d]
```

### SQLite to XML Conversion
Convert SQLite database back to IP-XACT XML format:
```bash
cd utils/py
python3 sqlite_to_xml.py -i database.db -o output.xml [-d] [--force-namespace ipxact|spirit] [--validate-schema]
```

### Command-line Options

#### XML to SQLite Options
- `xml_file`: Input XML file (positional argument)
- `-f, --file-list`: File containing list of XML files to process
- `-o, --output`: Output SQLite database path (required)
- `-d, --debug`: Enable debug logging (optional)

#### SQLite to XML Options
- `-i, --input`: Input SQLite database path (required)
- `-o, --output`: Output XML file path (required)
- `-d, --debug`: Enable debug logging (optional)
- `--force-namespace`: Force specific namespace (ipxact or spirit)
- `--validate-schema`: Validate database schema against schema.sql

### Example Usage
```bash
# Convert single XML file to SQLite
python3 xml_to_sqlite.py design.xml -o design.db

# Convert multiple XML files to SQLite
echo "design1.xml" > file_list.txt
echo "design2.xml" >> file_list.txt
python3 xml_to_sqlite.py -f file_list.txt -o design.db

# Convert SQLite to XML with debug logging and schema validation
python3 sqlite_to_xml.py -i design.db -o design.xml -d --validate-schema

# Convert SQLite to XML forcing IP-XACT namespace
python3 sqlite_to_xml.py -i design.db -o design.xml --force-namespace ipxact
```

## Python Tests

The project includes sanity level Python tests to verify the functionality of the Python utilities:

### Running Python Tests
```bash
cd utils/tests/py
make
```

### Available Test Targets
- `make test_xml_to_sqlite`: Run the test for `xml_to_sqlite.py`
- `make test_sqlite_to_xml`: Run the test for `sqlite_to_xml.py`
- `make help`: Display help information for the available targets


## Test Results

The project includes a comprehensive test suite with **11 test cases**:

```
OVERALL TEST RESULT: PASS @0
Tests Passed: 11, Tests Failed: 0, Total: 11
```

## License

Released under the MIT License. See LICENSE file for details.

!["Copyright (c) 2025 IC Verimeter"](https://github.com/xver/svdb_gateway/blob/main/docs/IcVerimeter_logo.png)
Copyright (c) 2025 IC Verimeter

