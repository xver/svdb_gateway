/*
 * File: sqlite_dpi_pkg.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SystemVerilog package for SQLite DPI interface
 */


package sqlite_dpi_pkg;

/*
Variable: SQLITE_MAX_PATH
Maximum length of database file path
*/
`define SQLITE_MAX_PATH  256;

/*
Variable: SQLITE_MAX_QUERY
Maximum length of SQL query string
*/
`define SQLITE_MAX_QUERY 1024;

/*
Section: Data exchange structures and utilities
*/

/*
Variable: sqlite_data_type_e
SQLite data types enumeration

Values:
- SQLITE_NULL     - NULL value
- SQLITE_INTEGER  - 64-bit signed integer
- SQLITE_FLOAT    - 64-bit IEEE floating point number
- SQLITE_TEXT     - UTF-8 or UTF-16 string
- SQLITE_BLOB     - Binary large object
*/
/* verilator lint_off UNDRIVEN */
typedef enum {SQLITE_NULL, SQLITE_INTEGER, SQLITE_FLOAT, SQLITE_TEXT, SQLITE_BLOB} sqlite_data_type_e;
/* verilator lint_on UNDRIVEN */

/*
Section: SQLite database operations
*/

/*
Function: sqlite_dpi_open_database
Opens a SQLite database connection

Parameter: db_path
Path to the SQLite database file

Returns: Database handle on success, null on failure

Note: Can be disabled with `define NO_SQLITE_DPI_OPEN_DATABASE
*/
`ifndef NO_SQLITE_DPI_OPEN_DATABASE
import "DPI-C" function chandle sqlite_dpi_open_database(input string db_path);
`endif

/*
Function: sqlite_dpi_close_database
Closes a SQLite database connection

Parameter: db
Database handle to close

Note: Can be disabled with `define NO_SQLITE_DPI_CLOSE_DATABASE
*/
`ifndef NO_SQLITE_DPI_CLOSE_DATABASE
import "DPI-C" function void sqlite_dpi_close_database(input chandle db);
`endif

/*
Function: sqlite_dpi_execute_query
Executes an SQL query

Parameter: db
Database handle

Parameter: query
SQL query string

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_EXECUTE_QUERY
*/
`ifndef NO_SQLITE_DPI_EXECUTE_QUERY
import "DPI-C" function int sqlite_dpi_execute_query(input chandle db, input string query);
`endif

/*
Function: sqlite_dpi_read_schema
Reads the database schema

Parameters:

   db - Database handle.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_READ_SCHEMA
*/
`ifndef NO_SQLITE_DPI_READ_SCHEMA
import "DPI-C" function int sqlite_dpi_read_schema(input chandle db);
`endif

/*
Function: sqlite_dpi_write_schema
Creates a new table in the database

Parameters:

   db - Database handle.
   table_name - Name of the table to create.
   columns - Column definitions.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_WRITE_SCHEMA
*/
`ifndef NO_SQLITE_DPI_WRITE_SCHEMA
import "DPI-C" function int sqlite_dpi_write_schema(input chandle db, input string table_name, input string columns);
`endif

/*
Function: sqlite_dpi_table_exists
Checks if a table exists in the database

Parameters:

   db - Database handle.
   table_name - Name of the table to check.

Returns:

   1 if table exists, 0 if not, -1 on error.

Note: Can be disabled with `define NO_SQLITE_DPI_TABLE_EXISTS
*/
`ifndef NO_SQLITE_DPI_TABLE_EXISTS
import "DPI-C" function int sqlite_dpi_table_exists(input chandle db, input string table_name);
`endif

/*
Function: sqlite_dpi_get_row
Retrieves a single row from a table

Parameters:

   db - Database handle.
   table_name - Name of the table to retrieve.
   row_id - ID of the row to retrieve.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_GET_ROW
*/
`ifndef NO_SQLITE_DPI_GET_ROW
import "DPI-C" function int sqlite_dpi_get_row(input chandle db, input string table_name, input int row_id);
`endif

/*
Function: sqlite_dpi_get_rowid_by_column_value
Retrieves the first row ID that matches a specific column value

Parameters:

   db - Database handle.
   table_name - Name of the table.
   column - Name of the column to search in.
   value - Value to search for.

Returns:

   Row ID if found, -1 if not found or on error.

Note: Can be disabled with `define NO_SQLITE_DPI_GET_ROWID_BY_COLUMN_VALUE
*/
`ifndef NO_SQLITE_DPI_GET_ROWID_BY_COLUMN_VALUE
import "DPI-C" function int sqlite_dpi_get_rowid_by_column_value(input chandle db, input string table_name, input string column, input string value);
`endif

/*
Function: sqlite_dpi_get_cell_value
Retrieves the value of a specific cell (column in a row)

Parameters:

   db - Database handle.
   table_name - Name of the table.
   row_id - ID of the row.
   column - Name of the column.

Returns:

   The cell value as a string, or an empty string on error.

Note: Can be disabled with `define NO_SQLITE_DPI_GET_CELL_VALUE
*/
`ifndef NO_SQLITE_DPI_GET_CELL_VALUE
import "DPI-C" function string sqlite_dpi_get_cell_value(input chandle db, input string table_name, input int row_id, input string column);
`endif

/*
Function: sqlite_dpi_create_table
Creates a new table in the database

Parameters:

   db - Database handle.
   table_name - Name of the table to create.
   columns - Column definitions.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_CREATE_TABLE
*/
`ifndef NO_SQLITE_DPI_CREATE_TABLE
import "DPI-C" function int sqlite_dpi_create_table(input chandle db, input string table_name, input string columns);
`endif

/*
Function: sqlite_dpi_delete_row
Deletes a row from a table

Parameters:

   db - Database handle.
   table - Table name.
   row_id - ID of the row to delete.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_DELETE_ROW
*/
`ifndef NO_SQLITE_DPI_DELETE_ROW
import "DPI-C" function int sqlite_dpi_delete_row(input chandle db, input string table_name, input int row_id);
`endif

/*
Function: sqlite_dpi_drop_table
Drops a table from the database

Parameters:

   db - Database handle.
   table_name - Name of the table to drop.

Returns:

   0 on success, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_DROP_TABLE
*/
`ifndef NO_SQLITE_DPI_DROP_TABLE
import "DPI-C" function int sqlite_dpi_drop_table(input chandle db, input string table_name);
`endif

/*
Function: sqlite_dpi_create_index
Creates an index on a table column

Parameter: db
Database handle

Parameter: index_name
Name of the index to create

Parameter: table
Name of the table

Parameter: column
Name of the column to index

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_CREATE_INDEX
*/
`ifndef NO_SQLITE_DPI_CREATE_INDEX
import "DPI-C" function int sqlite_dpi_create_index(input chandle db, input string index_name, input string table_name, input string column);
`endif

/*
Function: sqlite_dpi_drop_index
Drops an index from the database

Parameter: db
Database handle

Parameter: index_name
Name of the index to drop

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_DROP_INDEX
*/
`ifndef NO_SQLITE_DPI_DROP_INDEX
import "DPI-C" function int sqlite_dpi_drop_index(input chandle db, input string index_name);
`endif

/*
Function: sqlite_dpi_begin_transaction
Begins a transaction

Parameter: db
Database handle

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_BEGIN_TRANSACTION
*/
`ifndef NO_SQLITE_DPI_BEGIN_TRANSACTION
import "DPI-C" function int sqlite_dpi_begin_transaction(input chandle db);
`endif

/*
Function: sqlite_dpi_commit_transaction
Commits a transaction

Parameter: db
Database handle

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_COMMIT_TRANSACTION
*/
`ifndef NO_SQLITE_DPI_COMMIT_TRANSACTION
import "DPI-C" function int sqlite_dpi_commit_transaction(input chandle db);
`endif

/*
Function: sqlite_dpi_rollback_transaction
Rollbacks a transaction

Parameter: db
Database handle

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_ROLLBACK_TRANSACTION
*/
`ifndef NO_SQLITE_DPI_ROLLBACK_TRANSACTION
import "DPI-C" function int sqlite_dpi_rollback_transaction(input chandle db);
`endif

/*
Function: sqlite_dpi_vacuum_database
Optimizes the database by rebuilding it

Parameter: db
Database handle

Returns: 0 on success, -1 on failure

Note: Can be disabled with `define NO_SQLITE_DPI_VACUUM_DATABASE
*/
`ifndef NO_SQLITE_DPI_VACUUM_DATABASE
import "DPI-C" function int sqlite_dpi_vacuum_database(input chandle db);
`endif

/*
Function: sqlite_dpi_insert_row
Inserts a row into a table

Parameters:

   db - Database handle.
   table - Table name.
   columns - JSON string containing column names.
   values - JSON string containing values to insert.

Returns:

   ID of the inserted row, -1 on failure.

Note: Can be disabled with `define NO_SQLITE_DPI_INSERT_ROW
*/
`ifndef NO_SQLITE_DPI_INSERT_ROW
import "DPI-C" function int sqlite_dpi_insert_row(input chandle db, input string table_name, input string columns, input string values);
`endif

endpackage

