# Welcome to the **SVDB Gateway**! [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

![](https://github.com/xver/svdb_gateway/blob/main/docs/svdb_log.jpg)

# SQLite Database Gateway for SystemVerilog

## Overview [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

SVDB Gateway provides a bridge between SystemVerilog and SQLite databases, allowing SystemVerilog code to interact with SQLite databases through a Direct Programming Interface (DPI).

Also, check out other open-source projects by IC Verimeter: 
 - [The Shunt](https://github.com/xver/Shunt): An Open Source Client/Server TCP/IP socket-based communication library designed for integrating SystemVerilog simulations with external applications in C, SystemC, and Python.
 - [icecream_sv](https://github.com/xver/icecream_sv): A Simplified Debugging Tool for SystemVerilog.Inspired by [IceCream](https://github.com/gruns/icecream) style debugging tools.

### Use Cases [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

#### Hardware Verification

- **Register Map Management**: Store and query register configurations during simulation
- **Configuration Storage**: Persist test configurations and results
- **Logging Systems**: Log simulation data and events to database
- **Coverage Tracking**: Track verification coverage metrics

 IP-XACT Integration

- **Component Libraries**: Convert IP-XACT component descriptions to database format
- **Register Map Generation**: Generate register maps from IP-XACT descriptions
- **Configuration Management**: Store and retrieve hardware configurations
- **Version Control**: Track component versions and changes

#### Database Operations

- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **Transaction Management**: ACID-compliant database transactions
- **Index Optimization**: Performance optimization through database indexing
- **Schema Management**: Comprehensive database schema validation

## Project Structure [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

```
svdb_gateway/
├── bin/                  # Compiled binaries output (libdbdpi.so)
├── docs/                # Auto-generated documentation
├── examples/            # Example code and demonstrations
│   ├── example_registers.xml      # IP-XACT component example
│   ├── example_registers.db       # Generated SQLite database
│   ├── sv_regs/                   # SystemVerilog register examples
│   │   ├── test_registers.sv      # Register testing module
│   │   ├── sim_main.cpp           # verilator simulation entry
│   │   └── Makefile               # Build configuration
│   └── svdb_ral_uvm/              # UVM RAL integration example
│       ├── icecream_pkg.sv        # Debug utility package
│       ├── test_register_sequence.sv  # Test sequence file
│       ├── tb_uvm/                # UVM testbench components
│       ├── sim/                   # Simulation files
│       └── scripts/               # Build and run scripts
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
│   │   └── schema.sql        # Database schema definition
│   └── tests/          # Test suite
│       ├── sv/         # SystemVerilog tests
│       │   ├── test_sqlite.sv    # Main test file (11 test cases)
│       │   ├── sim_main.cpp      # verilator simulation entry
│       │   ├── cs_common.svh     # Common definitions
│       │   └── Makefile          # Test build rules
│       └── py/         # Python tests
│           ├── test_xml_to_sqlite.py  # Test for xml_to_sqlite.py
│           └── Makefile          # Makefile for running Python tests
└── README.md           # This file
```

## HTML Documentation [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

 [API](https://rawcdn.githack.com/xver/svdb_gateway/ef452153546004b6913291132ab51816c446a68d/docs/index.html)

## Features [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

### Core Functionality

- **SQLite Database Operations**: Complete CRUD operations from SystemVerilog
- **DPI Bridge**: Direct Programming Interface for seamless integration
- **IP-XACT Support**: XML to SQLite conversion for component descriptions
- **XML to SQLite Conversion**: Convert IP-XACT XML files to SQLite database format
- **Index Management**: Database indexing for performance optimization

### Advanced Features

- **Register Management**: Specialized functions for hardware register operations
- **UVM RAL Integration**: Complete UVM Register Abstraction Layer support with dynamic register configuration
- **Cell-Level Access**: Granular data access with `get_cell_value` and `get_rowid_by_column_value`
- **Schema Validation**: Comprehensive database schema validation
- **Error Handling**: Robust error reporting and logging
- **Multi-Namespace Support**: IP-XACT and SPIRIT namespace handling

### Testing & Verification

- **Comprehensive Test Suite**: 11 test cases covering all major functionality
- **Register Examples**: Real-world IP-XACT component testing
- **Build System**: Automated compilation and testing with Verilator/VCS support

### Latest Changes

- **UVM RAL Integration**: Added UVM Register Abstraction Layer  with dynamic register configuration
- **Database Schema Optimization**: updated SQLite tables and

### Support

- For assistance with **SVDB Gateway** integration or customization, contact us at icshunt.help@gmail.com
- Report bugs to [Issues](https://github.com/xver/svdb_gateway/issues)

## Requirements [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

### System Requirements

- **C/C++ Compiler** (GCC recommended)
  - GCC 9.4.0 or later
  - Clang 12.0.0 or later
- **SQLite Development Libraries**
  - SQLite 3.37.0 or later
  - libsqlite3-dev package

### Verification Tools

- **For SystemVerilog Testing**:
  - Verilator 5.039 devel (gh pr checkout 6224)
  - Make 4.3 or later
  
  **Note**: The UVM example is broken in the latest Verilator 5.041 (development revision v5.040-1-g4eb030717).
 

  `Error example: %Error: svdb_gateway/utils/uvm/svdb_catcher.sv:28:12: Reference to 'uvm_object_registry' before declaration (IEEE 1800-2023 6.18)`
    
- **Optional**: VCS (Synopsys VCS) for alternative simulation
- **For UVM RAL Examples**:
  - UVM 2017 version with Verilator adoption (verified)
  - UVM_HOME environment variable must be set to UVM installation directory

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

## Quick Start [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

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

### Running UVM RAL Examples

#### UVM Setup Requirements

Before running the UVM RAL examples, ensure you have UVM properly installed and configured:

1. **Install UVM**: Download and install UVM from [Accellera](https://accellera.org/downloads/standards/uvm).
2. **Set UVM_HOME**: Set the environment variable to point to your UVM installation:

   ```bash
   export UVM_HOME=/path/to/uvm
   ```
3. **Verify Installation**: The Makefile will automatically check if UVM_HOME is properly set.

#### Running the Example

```bash
cd examples/svdb_ral_uvm/scripts
make
```

The UVM RAL example demonstrates advanced register testing using SVDB with UVM Register Abstraction Layer (RAL). This example includes:

- **Dynamic Register Model**: Uses SVDB's dynamic register capabilities to configure registers from SQLite database
- **UVM RAL Integration**: Complete UVM testbench with register agent, sequences, and coverage
- **Multiple Register Types**: Demonstrates various register access types (RO, WO, RW) and configurations
- **Database-Driven Testing**: Register definitions and configurations are loaded from SQLite database
- **Comprehensive Test Sequences**: Includes read/write verification, access type validation, and error checking

#### Example Structure

```
examples/svdb_ral_uvm/
├── icecream_pkg.sv              # Debug utility package for SystemVerilog
├── test_register_sequence.sv    # Main test sequence file
├── tb_uvm/                      # UVM testbench components
│   ├── env/                     # UVM environment and testbench
│   │   ├── register_example_reg_model.sv  # Dynamic register model
│   │   ├── test_register_sequence.sv      # Test sequences
│   │   ├── testbench.sv                   # Main testbench
│   │   ├── env.sv                         # UVM environment
│   │   └── tb_top.sv                      # Top-level testbench
│   ├── reg_agent/               # Register bus agent
│   ├── rtl/                     # RTL design files
│   └── tests/                   # Test files
├── sim/                         # Simulation files
│   └── files.f                  # File list for compilation
└── scripts/                     # Build and run scripts
    └── Makefile                 # Build configuration
```

#### Key Features

- **Dynamic Register Configuration**: Registers are configured at runtime from SQLite database
- **UVM RAL Compliance**: Full UVM Register Abstraction Layer implementation
- **Multiple Access Types**: Supports RO (Read-Only), WO (Write-Only), and RW (Read-Write) registers
- **Debug Utilities**: Includes IceCream package for enhanced debugging capabilities
- **Automated Testing**: Complete test automation with Verilator/VCS support

**Note**: This example was tested with UVM 1800.2-2017 with Verilator adoption changes.

#### Troubleshooting UVM Setup

If you encounter issues with the UVM RAL example:

1. **UVM_HOME not set**: Ensure UVM_HOME points to a valid UVM installation
   ```bash
   echo $UVM_HOME
   ls $UVM_HOME/src/uvm_pkg.sv
   ```

## API Overview [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

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

## Makefile Help [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

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

# Run UVM example
cd examples/svdb_ral_uvm/scripts
make

# Show help information
make help
```

## Python Utilities [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

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

### Command-line Options

#### XML to SQLite Options

- `xml_file`: Input XML file (positional argument)
- `-f, --file-list`: File containing list of XML files to process
- `-o, --output`: Output SQLite database path (required)
- `-d, --debug`: Enable debug logging (optional)

### Example Usage

```bash
# Convert single XML file to SQLite
python3 xml_to_sqlite.py design.xml -o design.db

# Convert multiple XML files to SQLite
echo "design1.xml" > file_list.txt
echo "design2.xml" >> file_list.txt
python3 xml_to_sqlite.py -f file_list.txt -o design.db


```

## Python Tests [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

The project includes sanity-level Python tests to verify the functionality of the Python utilities:

### Running Python Tests

```bash
cd utils/tests/py
make
```

### Available Test Targets

- `make test_xml_to_sqlite`: Run the test for `xml_to_sqlite.py`
- `make help`: Display help information for the available targets

## Test Results [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

The project includes a comprehensive test suite with **11 test cases**:

```
OVERALL TEST RESULT: PASS @0
Tests Passed: 11, Tests Failed: 0, Total: 11
```

## License [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)

Released under the MIT License. See LICENSE file for details.

![](https://github.com/xver/svdb_gateway/blob/main/docs/IcVerimeter_logo.png)
Copyright (c) 2025 IC Verimeter
