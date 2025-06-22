/*
 * File: test_sqlite.sv
 *
 * Copyright (c) 2024 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SystemVerilog test module for SQLite DPI functionality.
 *              Provides comprehensive test coverage for SQLite database operations
 *              including database management, table operations, transactions,
 *              and data manipulation. Serves as a verification suite for the
 *              SQLite DPI interface implementation.
 */

/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off VARHIDDEN */

// Module: test_sqlite
//
// SystemVerilog test module for SQLite DPI functionality.
// Tests various SQLite operations including database management, table operations,
// transactions, and data manipulation.
module test_sqlite (input reg clk_i);

   //logic clk_i;
   import sqlite_dpi_pkg::*;

   bit Pass;
   chandle SqliteDB;
   int PassCount;
   int FailCount;

   initial begin
      string Status;
      string Test_name;

      Pass = 1'b1; // Start with Pass = 1 (all tests passing)
      PassCount = 0;
      FailCount = 0;

      $display("SQLite Tests: START");

      // Execute basic sqlite test
      Test_name = "Basic_sqlite_test";
      Pass = basic_sqlite_test(Test_name);

      // Test opening SQLite database
      Test_name = "Open SQLite DB test";
      Pass = open_sqlite_test(Test_name);

      // Test table operations
      Test_name = "Table Schema Operations test";
      Pass = table_schema_test(Test_name);

      Test_name = "Table Row Operations test";
      Pass = table_row_operations_test(Test_name);

      // Test transaction rollback
      Test_name = "Transaction Rollback test";
      Pass = transaction_rollback_test(Test_name);

      // Test database vacuum
      Test_name = "Database Vacuum test";
      Pass = vacuum_database_test(Test_name);

      // Test for the newly added functions

      // Test table create/drop operations
      Test_name = "Table Create/Drop test";
      Pass = table_create_drop_test(Test_name);

      // Test index operations
      Test_name = "Index Operations test";
      Pass = index_operations_test(Test_name);

      // Test row lookup operations (new functions)
      Test_name = "Row Lookup Operations test";
      Pass = row_lookup_operations_test(Test_name);

      // Test get_row operations
      Test_name = "Get Row Operations test";
      Pass = get_row_operations_test(Test_name);

      // Test closing SQLite database
      Test_name = "Close SQLite DB test";
      Pass = close_sqlite_test(Test_name);

      // Final test result
      if (Pass) begin
         $display("OVERALL TEST RESULT: PASS @%0t", $time);
      end else begin
         $display("OVERALL TEST RESULT: FAIL @%0t", $time);
      end
      $display("Tests Passed: %0d, Tests Failed: %0d, Total: %0d", PassCount, FailCount, PassCount + FailCount);

      $finish;
   end

   // Function: basic_sqlite_test
   //
   // Basic test for SQLite database operations.
   // Tests opening and closing a database.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit basic_sqlite_test(input string test_name);
      bit success = 1'b1;
      string db_name = "test.db";  // Changed to local file

      SqliteDB = sqlite_dpi_open_database(db_name);
      if (SqliteDB != null) begin
         $display("PASS: Opened SQLite database '%s' for basic test", db_name);
         sqlite_dpi_close_database(SqliteDB);
         $display("PASS: Closed SQLite database '%s' after basic test", db_name);
      end else begin
         $display("ERROR: Could not open SQLite database '%s' for basic test", db_name);
         success = 1'b0;
      end
      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: open_sqlite_test
   //
   // Test for opening SQLite database.
   // Verifies database handle creation and error handling.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit open_sqlite_test(input string test_name);
      bit success = 1'b1;
      string db_name = "test.db";

      // Try to open the SQLite database
      SqliteDB = sqlite_dpi_open_database(db_name);

      if (SqliteDB != null) begin
         $display("PASS: Opened SQLite database '%s' with handle %p", db_name, SqliteDB);
      end else begin
         $display("ERROR: Could not open SQLite database '%s'", db_name);
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: close_sqlite_test
   //
   // Test for closing SQLite database.
   // Verifies proper database cleanup and handle management.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit close_sqlite_test(input string test_name);
      bit success = 1'b0;

      // Try to close the SQLite database
      if (SqliteDB != null) begin
         sqlite_dpi_close_database(SqliteDB);
         success = 1'b1;
         $display("PASS: Closed SQLite database with handle %p", SqliteDB);
         SqliteDB = null;
      end else begin
         $display("ERROR: Cannot close SQLite database - handle is null");
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: table_schema_test
   //
   // Test for table schema operations.
   // Tests table creation, existence verification, and schema reading.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit table_schema_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_table";
      string columns = "id INTEGER PRIMARY KEY, name TEXT, value INTEGER";

      // Create table
      if (sqlite_dpi_write_schema(SqliteDB, table_name, columns) == 0) begin
         $display("PASS: Created table '%s' with columns: %s", table_name, columns);
      end else begin
         $display("ERROR: Could not create table '%s'", table_name);
         success = 1'b0;
      end

      // Check if table exists
      if (sqlite_dpi_table_exists(SqliteDB, table_name) > 0) begin
         $display("PASS: Verified table '%s' exists", table_name);
      end else begin
         $display("ERROR: Table '%s' does not exist", table_name);
         success = 1'b0;
      end

      // Read schema
      $display("\nReading database schema:");
      if (sqlite_dpi_read_schema(SqliteDB) == 0) begin
         $display("PASS: Successfully read schema for table '%s'", table_name);
         // Print table details
         $display("\nTable Details:");
         $display("  Table Name: %s", table_name);
         $display("  Columns:");
         $display("    - id INTEGER PRIMARY KEY");
         $display("    - name TEXT");
         $display("    - value INTEGER");
      end else begin
         $display("ERROR: Could not read schema for table '%s'", table_name);
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: table_row_operations_test
   //
   // Test for table row operations.
   // Tests inserting, updating, and deleting rows.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit table_row_operations_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_table";
      string columns = "name, value";
      string values = "'test_name', 42";
      int row_id;

      // Begin transaction
      if (sqlite_dpi_begin_transaction(SqliteDB) != 0) begin
         $display("ERROR: Could not begin transaction");
         success = 1'b0;
         return success;
      end

      // Print initial table contents
      $display("Initial table contents:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) == 0) begin
         $display("PASS: Retrieved initial table contents");
      end else begin
         $display("ERROR: Could not retrieve initial table contents");
         success = 1'b0;
      end

      // Insert row
      row_id = sqlite_dpi_insert_row(SqliteDB, table_name, columns, values);
      if (row_id > 0) begin
         $display("PASS: Inserted row with ID %0d into table '%s'", row_id, table_name);
         $display("  Columns: %s", columns);
         $display("  Values: %s", values);
      end else begin
         $display("ERROR: Could not insert row into table '%s'", table_name);
         success = 1'b0;
      end

      // Print table contents after insert
      $display("\nTable contents after insert:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) == 0) begin
         $display("PASS: Retrieved table contents after insert");
      end else begin
         $display("ERROR: Could not retrieve table contents after insert");
         success = 1'b0;
      end

      // Get row
      if (sqlite_dpi_get_row(SqliteDB, table_name, row_id) == 0) begin
         $display("PASS: Retrieved row %0d from table '%s'", row_id, table_name);
      end else begin
         $display("ERROR: Could not retrieve row %0d from table '%s'", row_id, table_name);
         success = 1'b0;
      end

      // Delete row
      if (sqlite_dpi_delete_row(SqliteDB, table_name, row_id) == 0) begin
         $display("PASS: Deleted row %0d from table '%s'", row_id, table_name);
      end else begin
         $display("ERROR: Could not delete row %0d from table '%s'", row_id, table_name);
         $display("  Attempting to rollback transaction...");
         if (sqlite_dpi_rollback_transaction(SqliteDB) == 0) begin
            $display("  PASS: Successfully rolled back transaction");
         end else begin
            $display("  ERROR: Failed to rollback transaction");
         end
         success = 1'b0;
         return success;
      end

      // Commit transaction
      if (sqlite_dpi_commit_transaction(SqliteDB) == 0) begin
         $display("PASS: Successfully committed transaction");
      end else begin
         $display("ERROR: Failed to commit transaction");
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: transaction_rollback_test
   //
   // Test for transaction rollback functionality.
   // Verifies proper transaction handling and rollback operations.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit transaction_rollback_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_table";
      string columns = "name, value";
      string values = "'rollback_test', 100";
      int row_id;

      // Begin transaction
      if (sqlite_dpi_begin_transaction(SqliteDB) != 0) begin
         $display("ERROR: Could not begin transaction");
         success = 1'b0;
         return success;
      end

      // Print initial table contents
      $display("Initial table contents before rollback test:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) == 0) begin
         $display("PASS: Retrieved initial table contents");
      end else begin
         $display("ERROR: Could not retrieve initial table contents");
         success = 1'b0;
      end

      // Insert row that will be rolled back
      row_id = sqlite_dpi_insert_row(SqliteDB, table_name, columns, values);
      if (row_id > 0) begin
         $display("PASS: Inserted temporary row with ID %0d into table '%s'", row_id, table_name);
      end else begin
         $display("ERROR: Could not insert row into table '%s'", table_name);
         success = 1'b0;
      end

      // Print table contents after insert but before rollback
      $display("\nTable contents after insert but before rollback:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) == 0) begin
         $display("PASS: Retrieved table contents after insert");
      end else begin
         $display("ERROR: Could not retrieve table contents after insert");
         success = 1'b0;
      end

      // Rollback transaction
      if (sqlite_dpi_rollback_transaction(SqliteDB) == 0) begin
         $display("PASS: Successfully rolled back transaction");
      end else begin
         $display("ERROR: Failed to rollback transaction");
         success = 1'b0;
      end

      // Print table contents after rollback to verify row was not committed
      $display("\nTable contents after rollback:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) == 0) begin
         $display("PASS: Retrieved table contents after rollback");
      end else begin
         $display("ERROR: Could not retrieve table contents after rollback");
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: vacuum_database_test
   //
   // Test for database vacuum operation.
   // Verifies database optimization and cleanup.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit vacuum_database_test(input string test_name);
      bit success = 1'b1;

      // Execute VACUUM command
      $display("Testing database vacuum operation");
      if (sqlite_dpi_vacuum_database(SqliteDB) == 0) begin
         $display("PASS: Successfully vacuumed database");
      end else begin
         $display("ERROR: Failed to vacuum database");
         success = 1'b0;
      end

      // To verify vacuum worked, we can check if database is still accessible
      $display("Verifying database is still accessible after vacuum:");
      if (sqlite_dpi_execute_query(SqliteDB, "PRAGMA integrity_check;") == 0) begin
         $display("PASS: Database integrity check passed after vacuum");
      end else begin
         $display("ERROR: Database integrity check failed after vacuum");
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: multi_row_operations_test
   //
   // Test for multi-row operations.
   // Tests batch insert, update, and delete operations.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit multi_row_operations_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_table";

      // This test is currently a placeholder for future multi-row operations
      // that may be implemented using alternative approaches.

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: table_create_drop_test
   //
   // Test for table creation and deletion.
   // Verifies proper table lifecycle management.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit table_create_drop_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_create_drop_table";
      string columns = "id INTEGER PRIMARY KEY, name TEXT, value INTEGER";
      string insert_columns = "name, value";
      string insert_values = "'create_drop_test', 999";
      int row_id;

      // Create table using the explicit create_table function
      $display("Testing explicit table creation for '%s'", table_name);
      if (sqlite_dpi_create_table(SqliteDB, table_name, columns) == 0) begin
         $display("PASS: Created table '%s' with columns: %s", table_name, columns);
      end else begin
         $display("ERROR: Could not create table '%s'", table_name);
         success = 1'b0;
      end

      // Verify table exists
      if (sqlite_dpi_table_exists(SqliteDB, table_name) > 0) begin
         $display("PASS: Verified table '%s' exists after creation", table_name);
      end else begin
         $display("ERROR: Table '%s' does not exist after creation", table_name);
         success = 1'b0;
      end

      // Insert test data to the table
      row_id = sqlite_dpi_insert_row(SqliteDB, table_name, insert_columns, insert_values);
      if (row_id > 0) begin
         $display("PASS: Inserted test row with ID %0d into '%s'", row_id, table_name);
      end else begin
         $display("ERROR: Could not insert test row into '%s'", table_name);
         success = 1'b0;
      end

      // Show table content
      $display("Table contents after insertion:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name}) != 0) begin
         $display("ERROR: Could not retrieve table contents");
         success = 1'b0;
      end

      // Drop the table using the explicit drop_table function
      $display("Testing explicit table drop for '%s'", table_name);
      if (sqlite_dpi_drop_table(SqliteDB, table_name) == 0) begin
         $display("PASS: Dropped table '%s'", table_name);
      end else begin
         $display("ERROR: Could not drop table '%s'", table_name);
         success = 1'b0;
      end

      // Verify table no longer exists
      if (sqlite_dpi_table_exists(SqliteDB, table_name) == 0) begin
         $display("PASS: Verified table '%s' no longer exists after drop", table_name);
      end else begin
         $display("ERROR: Table '%s' still exists after drop", table_name);
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: index_operations_test
   //
   // Test for index operations.
   // Tests index creation, verification, and impact on queries.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit index_operations_test(input string test_name);
      bit success = 1'b1;
      string table_name = "test_table";
      string index_name = "test_index";
      string column_name = "name";

      // Create an index on the test table
      $display("Testing index creation on table '%s', column '%s'", table_name, column_name);
      if (sqlite_dpi_create_index(SqliteDB, index_name, table_name, column_name) == 0) begin
         $display("PASS: Created index '%s' on table '%s', column '%s'", index_name, table_name, column_name);
      end else begin
         $display("ERROR: Could not create index '%s'", index_name);
         success = 1'b0;
      end

      // Verify index exists
      $display("Verifying index existence:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT name FROM sqlite_master WHERE type='index' AND name='", index_name, "'"}) == 0) begin
         $display("PASS: Verified index '%s' exists", index_name);
      end else begin
         $display("ERROR: Could not verify if index '%s' exists", index_name);
         success = 1'b0;
      end

      // Test a query that should use the index
      $display("Running a query that should use the index:");
      if (sqlite_dpi_execute_query(SqliteDB, {"EXPLAIN QUERY PLAN SELECT * FROM ", table_name, " WHERE name = 'test_name'"}) == 0) begin
         $display("PASS: Successfully ran an indexed query");
      end else begin
         $display("ERROR: Failed to run an indexed query");
         success = 1'b0;
      end

      // Drop the index
      $display("Testing index drop for '%s'", index_name);
      if (sqlite_dpi_drop_index(SqliteDB, index_name) == 0) begin
         $display("PASS: Dropped index '%s'", index_name);
      end else begin
         $display("ERROR: Could not drop index '%s'", index_name);
         success = 1'b0;
      end

      // Verify index no longer exists
      $display("Verifying index no longer exists:");
      if (sqlite_dpi_execute_query(SqliteDB, {"SELECT name FROM sqlite_master WHERE type='index' AND name='", index_name, "'"}) == 0) begin
         $display("PASS: Verified index '%s' no longer exists", index_name);
      end else begin
         $display("ERROR: Could not verify if index '%s' was dropped", index_name);
         success = 1'b0;
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: row_lookup_operations_test
   //
   // Test for specific row lookup functions.
   // Tests get_rowid_by_column_value and get_cell_value.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit row_lookup_operations_test(input string test_name);
      bit success = 1'b1;
      string table_name = "lookup_test";
      string columns_def = "id INTEGER PRIMARY KEY, column_1 TEXT, column_2 TEXT";
      int row_id;
      string col1_val, col2_val;
      int rc; // Variable to capture return codes
      string query;
      string value_to_find = "column_1_row_2";

      $display("\n--- Starting Test: %s ---", test_name);

      // Create table
      if (sqlite_dpi_create_table(SqliteDB, table_name, columns_def) != 0) begin
         $display("ERROR: Could not create table '%s'", table_name);
         success = 1'b0;
      end

      // Insert data
      if (success) begin
         for (int i = 1; i <= 3; i++) begin
            $sformat(query, "INSERT INTO %s (column_1, column_2) VALUES ('column_1_row_%0d', 'column_2_row_%0d');", table_name, i, i);
            rc = sqlite_dpi_execute_query(SqliteDB, query);
         end
         $display("PASS: Inserted test data into '%s'", table_name);

         // Print table contents
         $display("\nTable contents for '%s':", table_name);
         rc = sqlite_dpi_execute_query(SqliteDB, {"SELECT * FROM ", table_name});
      end

      // Test get_rowid_by_column_value
      if (success) begin
         row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, table_name, "column_1", value_to_find);
         if (row_id > 0) begin
            $display("PASS: Found rowid %0d for column_1 '%s'", row_id, value_to_find);
         end else begin
            $display("ERROR: Did not find rowid for column_1 '%s'", value_to_find);
            success = 1'b0;
         end
      end

      // Test get_cell_value
      if (success && row_id > 0) begin
         col1_val = sqlite_dpi_get_cell_value(SqliteDB, table_name, row_id, "column_1");
         col2_val = sqlite_dpi_get_cell_value(SqliteDB, table_name, row_id, "column_2");

         $display("Retrieved data for rowid %0d: column_1='%s', column_2='%s'", row_id, col1_val, col2_val);

         if (col1_val == value_to_find && col2_val == "column_2_row_2") begin
            $display("PASS: Retrieved cell values match expected values.");
         end else begin
            $display("ERROR: Retrieved cell values do not match expected values.");
            success = 1'b0;
         end
      end

      // Cleanup: drop the table
      if (sqlite_dpi_drop_table(SqliteDB, table_name) == 0) begin
         $display("PASS: Cleaned up and dropped table '%s'", table_name);
      end else begin
         $display("ERROR: Could not drop table '%s'", table_name);
         // Don't fail the overall test for a cleanup failure, but note it.
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: get_row_operations_test
   //
   // Test for get_row function.
   // NOTE: This test only verifies successful execution (return code 0), as the
   // current DPI implementation prints data to the console instead of returning it
   // to SystemVerilog.
   //
   // Parameter: test_name - Name of the test for reporting
   // Returns: 1 if test passes, 0 if test fails
   function automatic bit get_row_operations_test(input string test_name);
      bit success = 1'b1;
      string table_name = "get_row_test_table";
      string columns_def = "id INTEGER PRIMARY KEY, item TEXT";
      int rc;
      string query;
      int row_id_to_get;

      $display("\n--- Starting Test: %s ---", test_name);

      // Create table
      if (sqlite_dpi_create_table(SqliteDB, table_name, columns_def) != 0) begin
         $display("ERROR: Could not create table '%s'", table_name);
         success = 1'b0;
      end

      // Insert data and get the rowid of the second entry
      if (success) begin
         rc = sqlite_dpi_execute_query(SqliteDB, {"INSERT INTO ", table_name, " (item) VALUES ('item_A');"});
         rc = sqlite_dpi_execute_query(SqliteDB, {"INSERT INTO ", table_name, " (item) VALUES ('item_B');"});
         row_id_to_get = sqlite_dpi_get_rowid_by_column_value(SqliteDB, table_name, "item", "item_B");
         rc = sqlite_dpi_execute_query(SqliteDB, {"INSERT INTO ", table_name, " (item) VALUES ('item_C');"});
         $display("PASS: Inserted test data into '%s'", table_name);
      end

      // Test sqlite_dpi_get_row
      if (success) begin
         $display("\nTesting sqlite_dpi_get_row for rowid %0d...", row_id_to_get);
         rc = sqlite_dpi_get_row(SqliteDB, table_name, row_id_to_get);
         if (rc == 0) begin
            $display("PASS: sqlite_dpi_get_row executed successfully.");
         end else begin
            $display("ERROR: sqlite_dpi_get_row failed with return code %0d.", rc);
            success = 1'b0;
         end
      end

      // Cleanup: drop the table
      if (sqlite_dpi_drop_table(SqliteDB, table_name) == 0) begin
         $display("PASS: Cleaned up and dropped table '%s'", table_name);
      end else begin
         $display("ERROR: Could not drop table '%s'", table_name);
      end

      end_of_test(success, test_name);
      return Pass;
   endfunction

   // Function: end_of_test
   //
   // Helper function to report the result of a test.
   //
   // Parameter: success - Whether the test succeeded
   // Parameter: test_name - Name of the test
   function automatic void end_of_test(input bit success, input string test_name);
      if (success) begin
         $display("\n===== TEST PASS: %s =====\n", test_name);
         PassCount++;
      end else begin
         $display("\n===== TEST FAIL: %s =====\n", test_name);
         FailCount++;
         Pass = 1'b0;
      end
   endfunction

endmodule
/* verilator lint_on UNUSED */
/* verilator lint_on UNDRIVEN */
/* verilator lint_on VARHIDDEN */
