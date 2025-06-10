/*
 * File: sqlite_primitive.h
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Header file for SQLite primitive operations. Provides low-level
 *              database operations for SQLite database management, including
 *              connection handling, table operations, data manipulation,
 *              transaction control, and database maintenance.
 */

#ifndef SQLITE_PRIMITIVE_H
#define SQLITE_PRIMITIVE_H

#include "svdb_typedef.h"
#include <stdarg.h>

/************************************************
 * Section: Debug and Error Printing
 ************************************************/

/* Function: dbg_print
   Prints debug messages with variable arguments.

   Parameters:
      prefix - Prefix string for the debug message
      func_name - Name of the function generating the debug message
      format - Format string for the message
      ... - Variable arguments for the format string
*/
void dbg_print(const char *prefix, const char *func_name, const char *format, ...);

/* Function: err_print
   Prints error messages with variable arguments.

   Parameters:
      prefix - Prefix string for the error message
      func_name - Name of the function generating the error message
      format - Format string for the message
      ... - Variable arguments for the format string
*/
void err_print(const char *prefix, const char *func_name, const char *format, ...);

/************************************************
 * Section: Connection Management
 ************************************************/

/* Function: sqlite_prim_open_database
   Opens a SQLite database connection.

   Parameters:
      db_path - Path to the SQLite database file

   Returns:
      Pointer to the SQLite database connection, or NULL on failure
*/
sqlite3 *sqlite_prim_open_database(const char *db_path);

/* Function: sqlite_prim_close_database
   Closes a SQLite database connection.

   Parameters:
      db - Pointer to the SQLite database connection to close
*/
void sqlite_prim_close_database(sqlite3 *db);

/* Function: sqlite_prim_execute_query
   Executes a SQL query on the database.

   Parameters:
      db - Pointer to the SQLite database connection
      query - SQL query string to execute

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_execute_query(sqlite3 *db, const char *query);

/************************************************
 * Section: Single Row/Column Operations
 ************************************************/

/* Function: sqlite_prim_get_row
   Retrieves a single row from a table by ID.

   Parameters:
      db - Pointer to the SQLite database connection
      table - Name of the table
      row_id - ID of the row to retrieve
      columns - Pointer to store column names
      values - Pointer to store row values
      col_count - Pointer to store number of columns

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_get_row(sqlite3 *db, const char *table, int row_id, char ***columns, char ***values, int *col_count);

/* Function: sqlite_prim_insert_row
   Inserts a new row into a table.

   Parameters:
      db - Pointer to the SQLite database connection
      table - Name of the table
      columns - Array of column names
      values - Array of values to insert
      count - Number of columns/values

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_insert_row(sqlite3 *db, const char *table, const char **columns, const char **values, int count);

/* Function: sqlite_prim_delete_row
   Deletes a row from a table by ID.

   Parameters:
      db - Pointer to the SQLite database connection
      table - Name of the table
      row_id - ID of the row to delete

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_delete_row(sqlite3 *db, const char *table, int row_id);

/************************************************
 * Section: Multi-Row Operations
 ************************************************/

/* Function: sqlite_prim_get_all_rows
   Retrieves all rows from a table.

   Parameters:
      db - Pointer to the SQLite database connection
      table - Name of the table
      rows - Pointer to store the retrieved rows
      row_count - Pointer to store number of rows
      col_count - Pointer to store number of columns

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_get_all_rows(sqlite3 *db, const char *table, char ****rows, int *row_count, int *col_count);

/************************************************
 * Section: Table Operations
 ************************************************/

/* Function: sqlite_prim_create_table
   Creates a new table in the database.

   Parameters:
      db - Pointer to the SQLite database connection
      table_name - Name of the table to create
      columns - Column definitions string

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_create_table(sqlite3 *db, const char *table_name, const char *columns);

/* Function: sqlite_prim_drop_table
   Drops a table from the database.

   Parameters:
      db - Pointer to the SQLite database connection
      table_name - Name of the table to drop

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_drop_table(sqlite3 *db, const char *table_name);

/* Function: sqlite_prim_read_table_schema
   Reads the schema of a table.

   Parameters:
      db - Pointer to the SQLite database connection

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_read_table_schema(sqlite3 *db);

/************************************************
 * Section: Index Management
 ************************************************/

/* Function: sqlite_prim_create_index
   Creates an index on a table column.

   Parameters:
      db - Pointer to the SQLite database connection
      index_name - Name of the index to create
      table_name - Name of the table
      column - Name of the column to index

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_create_index(sqlite3 *db, const char *index_name, const char *table_name, const char *column);

/* Function: sqlite_prim_drop_index
   Drops an index from the database.

   Parameters:
      db - Pointer to the SQLite database connection
      index_name - Name of the index to drop

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_drop_index(sqlite3 *db, const char *index_name);

/************************************************
 * Section: Transaction Control
 ************************************************/

/* Function: sqlite_prim_begin_transaction
   Begins a database transaction.

   Parameters:
      db - Pointer to the SQLite database connection

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_begin_transaction(sqlite3 *db);

/* Function: sqlite_prim_commit_transaction
   Commits a database transaction.

   Parameters:
      db - Pointer to the SQLite database connection

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_commit_transaction(sqlite3 *db);

/* Function: sqlite_prim_rollback_transaction
   Rolls back a database transaction.

   Parameters:
      db - Pointer to the SQLite database connection

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_rollback_transaction(sqlite3 *db);

/************************************************
 * Section: Database Maintenance
 ************************************************/

/* Function: sqlite_prim_vacuum_database
   Performs database vacuum operation to optimize storage.

   Parameters:
      db - Pointer to the SQLite database connection

   Returns:
      SQLite result code (SQLITE_OK on success)
*/
int sqlite_prim_vacuum_database(sqlite3 *db);

/* Function: sqlite_prim_table_exists
   Checks if a table exists in the database.

   Parameters:
      db - Pointer to the SQLite database connection
      table_name - Name of the table to check

   Returns:
      1 if table exists, 0 if not, negative on error
*/
int sqlite_prim_table_exists(sqlite3 *db, const char *table_name);

#endif // SQLITE_PRIMITIVE_H