#  Welcome to the **SVDB Gateway**! [![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/xver)
![](https://github.com/xver/svdb_gateway/blob/main/docs/svdb_log_min.png)

 # SQLite Database Gateway for SystemVerilog

## Overview

SVDB Gateway provides a bridge between SystemVerilog and SQLite databases, allowing SystemVerilog code to interact with SQLite databases through a Direct Programming Interface (DPI).


## Project Structure

```
svdb_gateway/
├── bin/                  # Compiled binaries
├── docs/                # Documentation
├── examples/            # Example code
│   ├── test_component.xml  # Example IP-XACT component
│   └── test_system.xml     # Example IP-XACT system
├── utils/
│   ├── c/              # C utilities
│   │   ├── include/    # C header files
│   │   └── src/        # C source files
│   ├── dpi/            # DPI interface
│   │   ├── include/    # DPI header files
│   │   └── src/        # DPI source files
│   ├── makedir/        # Build system
│   ├── py/             # Python utilities
│   │   ├── xml_to_sqlite.py  # XML to SQLite converter
│   │   ├── sqlite_to_xml.py  # SQLite to XML converter
│   │   └── schema.sql        # Database schema
│   └── tests/          # Test cases
│       ├── sv/         # SystemVerilog tests
│       │   ├── test_sqlite.sv    # Main test file
│       │   ├── sim_main.cpp      # C++ simulation entry
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

- SQLite database operations from SystemVerilog
- Complete DPI bridge for database operations

### Support
Whether you need assistance with the **SVDV Gateawy** integration into your project or customization, please contact us at icshunt.help@gmail.com
Please, report bugs to [Issues](https://github.com/xver/svdb_gateway/issues)

## Requirements

- C/C++ compiler (GCC recommended)
  - GCC 9.4.0 or later
  - Clang 12.0.0 or later
- SQLite development libraries
  - SQLite 3.37.0 or later
  - libsqlite3-dev package
- For testing SystemVerilog code:
  - Verilator 5.014 or later
  - Make 4.3 or later
- For Python utilities:
  - Python 3.8.0 or later
  - Required Python packages (all built-in):
    - `sqlite3` (3.8.0 or later)
    - `xml.etree.ElementTree` (3.8.0 or later)
    - `argparse` (3.8.0 or later)
    - `hashlib` (3.8.0 or later)
    - `datetime` (3.8.0 or later)
    - `logging` (3.8.0 or later)
    - `typing` (3.8.0 or later)
    - `os` (3.8.0 or later)

## Building

To build the project:

```bash
cd utils/makedir
make
```

## Running Tests

To run the SystemVerilog tests with Verilator:

```bash
cd utils/tests/sv
make
```

The test suite includes:
- `test_sqlite.sv`: Main test file for SQLite DPI functionality
- `sim_main.cpp`: C++ simulation entry point
- `cs_common.svh`: Common SystemVerilog definitions
- Various log files for debugging and verification

## Makefile Help

The project includes a comprehensive Makefile with several useful targets and options:

### Available Targets
- `make` or `make all`: Default target that cleans, compiles SVDB libraries, compiles Verilator code, and runs simulation
- `make debug`: Same as all but with verbose debugging enabled
- `make svdb_compile`: Compiles the SVDB C libraries
- `make compile_verilator_sv`: Compiles SystemVerilog code with Verilator
- `make run`: Runs the simulation
- `make clean`: Removes all generated files and directories
- `make help`: Displays detailed help information

### Configuration Variables
- `OUTPUT_DIR`: Directory for output files (default: .)
- `VERILATOR`: Path to Verilator executable (default: verilator)
- `SVDB_HOME`: Path to svdb_gateway root directory (default: automatically detected)
- `DEBUG`: Set to 1 to enable verbose debugging (default: not set)

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

# Show help information
make help
```

## Python Utilities

The project includes Python utilities for XML and SQLite database operations:

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

The project includes Python tests to verify the functionality of the Python utilities. These tests are located in the `utils/tests/py` directory.

### Running Python Tests

To run the Python tests, navigate to the `utils/tests/py` directory and use the provided Makefile:

```bash
cd utils/tests/py
make
```

This will execute all available tests. You can also run individual tests using the following commands:

- `make test_xml_to_sqlite`: Run the test for `xml_to_sqlite.py`.
- `make test_sqlite_to_xml`: Run the test for `sqlite_to_xml.py`.
- `make help`: Display help information for the available targets.

### Makefile Help

The Makefile in the `utils/tests/py` directory includes the following targets:

- `all`: Run all tests (default target).
- `test_xml_to_sqlite`: Run the test for `xml_to_sqlite.py`.
- `test_sqlite_to_xml`: Run the test for `sqlite_to_xml.py`.
- `help`: Display help information for the available targets.

## License

Released under the MIT License. See LICENSE file for details.

!["Copyright (c) 2025 IC Verimeter"](https://github.com/xver/svdb_gateway/blob/main/docs/IcVerimeter_logo.png)
Copyright (c) 2025 IC Verimeter

