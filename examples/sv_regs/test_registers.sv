/*
 * File: test_registers.sv
 *
 * Copyright (c) 2024 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SystemVerilog test module for reading registers from SQLite database
 */

/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off VARHIDDEN */

module test_registers (input reg clk_i);

   import sqlite_dpi_pkg::*;

   // Global variables for test management
   bit Pass;
   chandle SqliteDB;
   int PassCount;
   int FailCount;
   string specific_registers[4];

   initial begin
      string db_path = "../example_registers.db";
      bit current_test_success;

      // Initialize global state
      Pass = 1'b1;
      PassCount = 0;
      FailCount = 0;

      // Initialize register names
      specific_registers[0] = "status_register";
      specific_registers[1] = "control_register";
      specific_registers[2] = "configuration_register";
      specific_registers[3] = "security_register";

      $display("\n[SVDB] Register Table Iteration Test: START");
      SqliteDB = sqlite_dpi_open_database(db_path);

      if (SqliteDB == null) begin
         $display("FATAL ERROR: Could not open SQLite database: %s", db_path);
         Pass = 1'b0;
      end else begin
         $display("Successfully opened SQLite database: %s", db_path);

         // --- Execute Tests ---
         current_test_success = test_table_existence();
         end_of_test(current_test_success, "Table Existence");

         current_test_success = test_retrieve_all_registers();
         end_of_test(current_test_success, "Retrieve All Registers");

         current_test_success = test_retrieve_specific_by_query();
         end_of_test(current_test_success, "Retrieve Specific by Query");

         current_test_success = test_retrieve_specific_by_cell();
         end_of_test(current_test_success, "Retrieve Specific by Cell");

         // --- Cleanup ---
         sqlite_dpi_close_database(SqliteDB);
         $display("\n[SVDB] Register Table Iteration Test: %s", Pass ? "PASS" : "FAIL");
      end

      $display("Tests Passed: %0d, Tests Failed: %0d, Total: %0d", PassCount, FailCount, PassCount + FailCount);
      $finish;
   end

   // Task: end_of_test
   //
   // Helper task to report the result of a test and update global counters.
   //
   // Parameters:
   //   success   - Whether the test succeeded.
   //   test_name - The name of the test for reporting.
   task automatic end_of_test(input bit success, input string test_name);
      if (success) begin
         $display("===== TEST PASS: %s =====", test_name);
         PassCount++;
      end else begin
         $display("===== TEST FAIL: %s =====", test_name);
         FailCount++;
         Pass = 1'b0; // Mark overall test as failed
      end
   endtask

   // Function: test_table_existence
   //
   // Test 1: Check if the 'registers' table exists in the database.
   function automatic bit test_table_existence();
      $display("\n[TEST 1] Checking if registers table exists...");
      if (sqlite_dpi_table_exists(SqliteDB, "registers") > 0) begin
         $display("PASS: registers table exists");
         return 1'b1;
      end else begin
         $display("ERROR: registers table does not exist");
         return 1'b0;
      end
   endfunction

   // Function: test_retrieve_all_registers
   //
   // Test 2: Retrieve all registers from the 'registers' table.
   function automatic bit test_retrieve_all_registers();
      $display("\n[TEST 2] Retrieving all registers from registers table...");
      $display("All registers in the database:");
      if (sqlite_dpi_execute_query(SqliteDB, "SELECT id, name, addressOffset, size, access FROM registers") == 0) begin
         $display("PASS: Successfully executed query for all registers");
         return 1'b1;
      end else begin
         $display("ERROR: Failed to execute query for all registers");
         return 1'b0;
      end
   endfunction

   // Function: test_retrieve_specific_by_query
   //
   // Test 3: Retrieve specific registers by constructing a query.
   function automatic bit test_retrieve_specific_by_query();
      bit success = 1'b1;
      int row_id;
      string query;
      int rc;

      $display("\n[TEST 3] Retrieving specific registers by name using manual query...");
      foreach (specific_registers[i]) begin
         $display("\nLooking for register: %s", specific_registers[i]);
         row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "registers", "name", specific_registers[i]);
         if (row_id > 0) begin
            $display("PASS: Found %s with row ID: %0d", specific_registers[i], row_id);
            $sformat(query, "SELECT id, name, addressOffset, size, access, resetValue FROM registers WHERE rowid = %0d", row_id);
            rc = sqlite_dpi_execute_query(SqliteDB, query);
            if (rc != 0) begin
               $display("ERROR: Failed to retrieve data for %s", specific_registers[i]);
               success = 1'b0;
            end
         end else begin
            $display("ERROR: Register %s not found in database", specific_registers[i]);
            success = 1'b0;
         end
      end
      return success;
   endfunction

   // Function: test_retrieve_specific_by_cell
   //
   // Test 4: Retrieve specific registers using the get_cell_value DPI function.
   function automatic bit test_retrieve_specific_by_cell();
      bit success = 1'b1;
      int row_id;
      string name, addressOffset, size, access, resetValue;

      $display("\n[TEST 4] Retrieving specific registers and printing cell values from SV...");
      foreach (specific_registers[i]) begin
         $display("\nLooking for register: %s", specific_registers[i]);
         row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "registers", "name", specific_registers[i]);
         if (row_id > 0) begin
            $display("PASS: Found %s with row ID: %0d", specific_registers[i], row_id);
            name = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "name");
            addressOffset = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "addressOffset");
            size = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "size");
            access = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "access");
            resetValue = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "resetValue");

            $display("  Name: %s, AddressOffset: %s, Size: %s, Access: %s, ResetValue: %s", name, addressOffset, size, access, resetValue);

            if (name != specific_registers[i]) begin
               $display("ERROR: Data mismatch for %s", specific_registers[i]);
               success = 1'b0;
            end
         end else begin
            $display("ERROR: Register %s not found in database", specific_registers[i]);
            success = 1'b0;
         end
      end
      return success;
   endfunction



endmodule
