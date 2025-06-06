#ifndef SQLITE_PRIMITIVE_H
#define SQLITE_PRIMITIVE_H

#include "svdb_typedef.h"
#include <stdarg.h>

/************************************************
 * Debug and Error Printing
 ************************************************/
void dbg_print(const char *prefix, const char *func_name, const char *format, ...);
void err_print(const char *prefix, const char *func_name, const char *format, ...);

/************************************************
 * Connection Management
 ************************************************/
sqlite3 *sqlite_prim_open_database(const char *db_path);
void sqlite_prim_close_database(sqlite3 *db);
int sqlite_prim_execute_query(sqlite3 *db, const char *query);

/************************************************
 * Single Row/Column Operations
 ************************************************/
int sqlite_prim_get_row(sqlite3 *db, const char *table, int row_id, char ***columns, char ***values, int *col_count);
int sqlite_prim_insert_row(sqlite3 *db, const char *table, const char **columns, const char **values, int count);
int sqlite_prim_delete_row(sqlite3 *db, const char *table, int row_id);

/************************************************
 * Multi-Row Operations
 ************************************************/
int sqlite_prim_get_all_rows(sqlite3 *db, const char *table, char ****rows, int *row_count, int *col_count);

/************************************************
 * Table Operations
 ************************************************/
int sqlite_prim_create_table(sqlite3 *db, const char *table_name, const char *columns);
int sqlite_prim_drop_table(sqlite3 *db, const char *table_name);
int sqlite_prim_read_table_schema(sqlite3 *db);

/************************************************
 * Index Management
 ************************************************/
int sqlite_prim_create_index(sqlite3 *db, const char *index_name, const char *table_name, const char *column);
int sqlite_prim_drop_index(sqlite3 *db, const char *index_name);

/************************************************
 * Transaction Control
 ************************************************/
int sqlite_prim_begin_transaction(sqlite3 *db);
int sqlite_prim_commit_transaction(sqlite3 *db);
int sqlite_prim_rollback_transaction(sqlite3 *db);

/************************************************
 * Database Maintenance
 ************************************************/
int sqlite_prim_vacuum_database(sqlite3 *db);
int sqlite_prim_table_exists(sqlite3 *db, const char *table_name);

#endif // SQLITE_PRIMITIVE_H