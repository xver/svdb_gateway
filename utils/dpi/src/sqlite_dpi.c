#include "sqlite_dpi.h"
#include <string.h>
#include <stdlib.h>

/************************************************
 * Connection Management
 ************************************************/

sqlite3 *sqlite_dpi_open_database(const char *db_path) {
    dbg_print("DPI", "sqlite_dpi_open_database", "Opening database at path: %s", db_path);
    sqlite3 *db = sqlite_prim_open_database(db_path);
    return db;
}

void sqlite_dpi_close_database(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_close_database", "Closing database");
    sqlite_prim_close_database(db);
}

int sqlite_dpi_execute_query(sqlite3 *db, const char *query) {
    dbg_print("DPI", "sqlite_dpi_execute_query", "Executing query: %s", query);
    return sqlite_prim_execute_query(db, query);
}

/************************************************
 * Table Operations
 ************************************************/

int sqlite_dpi_read_schema(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_read_schema", "Reading database schema");
    return sqlite_prim_read_table_schema(db);
}

int sqlite_dpi_write_schema(sqlite3 *db, const char *table_name, const char *columns) {
    dbg_print("DPI", "sqlite_dpi_write_schema", "Writing schema for table '%s' with columns: %s", table_name, columns);
    return sqlite_prim_create_table(db, table_name, columns);
}

int sqlite_dpi_table_exists(sqlite3 *db, const char *table_name) {
    dbg_print("DPI", "sqlite_dpi_table_exists", "Checking if table '%s' exists", table_name);
    return sqlite_prim_table_exists(db, table_name);
}

int sqlite_dpi_insert_row(sqlite3 *db, const char *table_name, const char *columns_str, const char *values_str) {
    dbg_print("DPI", "sqlite_dpi_insert_row", "Inserting row into table '%s'", table_name);
    dbg_print("DPI", "sqlite_dpi_insert_row", "Columns: %s", columns_str);
    dbg_print("DPI", "sqlite_dpi_insert_row", "Values: %s", values_str);

    // Parse comma-separated columns string
    char **columns = NULL;
    int col_count = 0;
    char *columns_copy = strdup(columns_str);
    char *token = strtok(columns_copy, ",");

    while (token != NULL) {
        columns = realloc(columns, sizeof(char*) * (col_count + 1));
        columns[col_count] = strdup(token);
        col_count++;
        token = strtok(NULL, ",");
    }
    free(columns_copy);

    // Parse comma-separated values string
    char **values = NULL;
    char *values_copy = strdup(values_str);
    token = strtok(values_copy, ",");
    int val_count = 0;

    while (token != NULL) {
        values = realloc(values, sizeof(char*) * (val_count + 1));
        values[val_count] = strdup(token);
        val_count++;
        token = strtok(NULL, ",");
    }
    free(values_copy);

    // Verify counts match
    if (col_count != val_count) {
        err_print("DPI", "sqlite_dpi_insert_row", "Column count (%d) does not match value count (%d)", col_count, val_count);
        // Clean up
        for (int i = 0; i < col_count; i++) {
            free(columns[i]);
        }
        free(columns);

        for (int i = 0; i < val_count; i++) {
            free(values[i]);
        }
        free(values);

        return -1;
    }

    int result = sqlite_prim_insert_row(db, table_name, (const char **)columns, (const char **)values, col_count);

    // Clean up
    for (int i = 0; i < col_count; i++) {
        free(columns[i]);
    }
    free(columns);

    for (int i = 0; i < val_count; i++) {
        free(values[i]);
    }
    free(values);

    return result;
}

int sqlite_dpi_delete_row(sqlite3 *db, const char *table_name, int row_id) {
    dbg_print("DPI", "sqlite_dpi_delete_row", "Deleting row %d from table '%s'", row_id, table_name);
    return sqlite_prim_delete_row(db, table_name, row_id);
}

int sqlite_dpi_get_row(sqlite3 *db, const char *table_name, int row_id) {
    dbg_print("DPI", "sqlite_dpi_get_row", "Getting row %d from table '%s'", row_id, table_name);
    char **columns = NULL;
    char **values = NULL;
    int col_count = 0;

    int result = sqlite_prim_get_row(db, table_name, row_id, &columns, &values, &col_count);

    // Here we would need to handle returning the data to SystemVerilog
    // For now, just print the values and free memory
    if (result == 0) {
        for (int i = 0; i < col_count; i++) {
            free(columns[i]);
            free(values[i]);
        }
        free(columns);
        free(values);
    }

    return result;
}

int sqlite_dpi_get_rowid_by_column_value(void *db, const char *table_name, const char *column, const char *value) {
    if (!db) {
        err_print("C_DPI", "sqlite_dpi_get_rowid_by_column_value", "Database handle is NULL\n");
        return -1;
    }
    return sqlite_prim_get_rowid_by_column_value((sqlite3*)db, table_name, column, value);
}

int sqlite_dpi_create_table(sqlite3 *db, const char *table_name, const char *columns) {
    dbg_print("DPI", "sqlite_dpi_create_table", "Creating table '%s' with columns: %s", table_name, columns);
    return sqlite_prim_create_table(db, table_name, columns);
}

int sqlite_dpi_drop_table(sqlite3 *db, const char *table_name) {
    dbg_print("DPI", "sqlite_dpi_drop_table", "Dropping table '%s'", table_name);
    return sqlite_prim_drop_table(db, table_name);
}

/************************************************
 * Multi-Row Operations
 ************************************************/

int sqlite_dpi_get_all_rows(sqlite3 *db, const char *table_name, char ****rows, int *row_count, int *col_count) {
    dbg_print("DPI", "sqlite_dpi_get_all_rows", "Getting all rows from table '%s'", table_name);
    return sqlite_prim_get_all_rows(db, table_name, rows, row_count, col_count);
}

/************************************************
 * Index Management
 ************************************************/

int sqlite_dpi_create_index(sqlite3 *db, const char *index_name, const char *table_name, const char *column) {
    dbg_print("DPI", "sqlite_dpi_create_index", "Creating index '%s' on table '%s', column '%s'",
              index_name, table_name, column);
    return sqlite_prim_create_index(db, index_name, table_name, column);
}

int sqlite_dpi_drop_index(sqlite3 *db, const char *index_name) {
    dbg_print("DPI", "sqlite_dpi_drop_index", "Dropping index '%s'", index_name);
    return sqlite_prim_drop_index(db, index_name);
}

/************************************************
 * Transaction Control
 ************************************************/

int sqlite_dpi_begin_transaction(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_begin_transaction", "Beginning transaction");
    return sqlite_prim_begin_transaction(db);
}

int sqlite_dpi_commit_transaction(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_commit_transaction", "Committing transaction");
    return sqlite_prim_commit_transaction(db);
}

int sqlite_dpi_rollback_transaction(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_rollback_transaction", "Rolling back transaction");
    return sqlite_prim_rollback_transaction(db);
}

/************************************************
 * Database Maintenance
 ************************************************/

int sqlite_dpi_vacuum_database(sqlite3 *db) {
    dbg_print("DPI", "sqlite_dpi_vacuum_database", "Vacuuming database");
    return sqlite_prim_vacuum_database(db);
}

const char* sqlite_dpi_get_cell_value(void* db, const char* table_name, int row_id, const char* column) {
    if (!db) {
        err_print("C_DPI", "sqlite_dpi_get_cell_value", "Database handle is NULL\n");
        return NULL;
    }
    return sqlite_prim_get_cell_value((sqlite3*)db, table_name, row_id, column);
}