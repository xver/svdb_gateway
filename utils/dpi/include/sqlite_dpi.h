/*
 * File: sqlite_dpi.h
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Header file for SQLite DPI interface
 */

#ifndef SQLITE_DPI_H
#define SQLITE_DPI_H

#include "sqlite_primitive.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/************************************************
 * Section:Connection Management
 ************************************************/

/* Function: sqlite_dpi_open_database

   Opens a SQLite database connection.

   Parameters:

      db_path - Path to the SQLite database file.

   Returns:

      Pointer to the SQLite database connection, or NULL on failure.
*/
sqlite3 *sqlite_dpi_open_database(const char *db_path);

/* Function: sqlite_dpi_close_database

   Closes a SQLite database connection.

   Parameters:

      db - Pointer to the SQLite database connection to close.

   Returns:

      None.
*/
void sqlite_dpi_close_database(sqlite3 *db);

/* Function: sqlite_dpi_execute_query

   Executes a SQL query on the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      query - SQL query string to execute.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_execute_query(sqlite3 *db, const char *query);

/************************************************
 * Section: Table Operations
 ************************************************/

/* Function: sqlite_dpi_read_schema

   Reads the database schema.

   Parameters:

      db - Pointer to the SQLite database connection.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_read_schema(sqlite3 *db);

/* Function: sqlite_dpi_write_schema

   Writes a table schema to the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table.
      columns - Column definitions string.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_write_schema(sqlite3 *db, const char *table_name, const char *columns);

/* Function: sqlite_dpi_table_exists

   Checks if a table exists in the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table to check.

   Returns:

      1 if table exists, 0 if not, negative on error.
*/
int sqlite_dpi_table_exists(sqlite3 *db, const char *table_name);

/* Function: sqlite_dpi_insert_row

   Inserts a row into a table.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table.
      columns - Column names string.
      values - Values string.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_insert_row(sqlite3 *db, const char *table_name, const char *columns, const char *values);

/* Function: sqlite_dpi_delete_row

   Deletes a row from a table.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table.
      row_id - ID of the row to delete.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_delete_row(sqlite3 *db, const char *table_name, int row_id);

/* Function: sqlite_dpi_get_row

   Retrieves a row from a table.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table.
      row_id - ID of the row to retrieve.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_get_row(sqlite3 *db, const char *table_name, int row_id);

/* Function: sqlite_dpi_get_rowid_by_column_value

   Retrieves the first row ID that matches a specific column value.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table.
      column - Name of the column to search in.
      value - Value to search for.

   Returns:

      Row ID if found, -1 if not found or on error.
*/
extern int sqlite_dpi_get_rowid_by_column_value(void* db, const char* table_name, const char* column, const char* value);

/* Function: sqlite_dpi_get_cell_value
   Retrieves the value of a specific cell from a table.

   Parameters:
      db - The database handle.
      table_name - The name of the table.
      row_id - The ID of the row.
      column - The name of the column.

   Returns:
      The value of the cell as a string, or NULL on error.
*/
extern const char* sqlite_dpi_get_cell_value(void* db, const char* table_name, int row_id, const char* column);

/* Function: sqlite_dpi_create_table

   Creates a new table in the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table to create.
      columns - Column definitions string.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_create_table(sqlite3 *db, const char *table_name, const char *columns);

/* Function: sqlite_dpi_drop_table

   Drops a table from the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      table_name - Name of the table to drop.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_drop_table(sqlite3 *db, const char *table_name);

/************************************************
 * Section:  Index Management
 ************************************************/

/* Function: sqlite_dpi_create_index

   Creates an index on a table column.

   Parameters:

      db - Pointer to the SQLite database connection.
      index_name - Name of the index to create.
      table_name - Name of the table.
      column - Name of the column to index.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_create_index(sqlite3 *db, const char *index_name, const char *table_name, const char *column);

/* Function: sqlite_dpi_drop_index

   Drops an index from the database.

   Parameters:

      db - Pointer to the SQLite database connection.
      index_name - Name of the index to drop.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_drop_index(sqlite3 *db, const char *index_name);

/************************************************
 * Section: Transaction Control
 ************************************************/

/* Function: sqlite_dpi_begin_transaction

   Begins a database transaction.

   Parameters:

      db - Pointer to the SQLite database connection.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_begin_transaction(sqlite3 *db);

/* Function: sqlite_dpi_commit_transaction

   Commits a database transaction.

   Parameters:

      db - Pointer to the SQLite database connection.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_commit_transaction(sqlite3 *db);

/* Function: sqlite_dpi_rollback_transaction

   Rolls back a database transaction.

   Parameters:

      db - Pointer to the SQLite database connection.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_rollback_transaction(sqlite3 *db);

/************************************************
 * Section: Database Maintenance
 ************************************************/

/* Function: sqlite_dpi_vacuum_database

   Performs database vacuum operation.

   Parameters:

      db - Pointer to the SQLite database connection.

   Returns:

      SQLite result code (SQLITE_OK on success).
*/
int sqlite_dpi_vacuum_database(sqlite3 *db);

#ifdef __cplusplus
}
#endif

#endif // SQLITE_DPI_H