/*
 * File: test_register_sequence.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM sequence for testing REGBUS protocol with SVDB dynamic register model
 */

`include "uvm_macros.svh"
`ifndef TEST_REGISTER_SEQUENCE_SV
`define TEST_REGISTER_SEQUENCE_SV
import svdb_uvm_pkg::*;

/*
Class: svdb_dynamic_seq
SVDB Dynamic Register sequence using svdb_reg_model

This sequence demonstrates the use of SVDB (SystemVerilog Database) for dynamic
register testing. It reads register definitions from a SQLite database and performs
read/write operations on registers with different access types (RO, WO, RW).

Inherits: uvm_sequence#(regbus_seq_item)
*/
class svdb_dynamic_seq extends uvm_sequence#(regbus_seq_item);
  `uvm_object_utils(svdb_dynamic_seq)
  
  /*
  Variable: db_path
  Path to the SQLite database file containing register definitions

  This variable stores the file path to the SQLite database that contains
  the register configuration information for dynamic register testing.
  */
  string db_path;

  /*
  Variable: last_written
  Array storing the last written values for each register

  This array tracks the last value written to each register during testing.
  It is used to verify read operations by comparing against expected values
  based on the register access type and previous write operations.
  */
  int unsigned last_written[6];

  /*
  Variable: default_map
  Default register map for register access

  This variable holds the default register map that provides the address
  mapping for register access operations during testing.
  */
  uvm_reg_map default_map;

  /*
  Variable: reg_names
  Array of register names to test

  This array contains the names of registers that will be tested during
  the sequence execution. Each name corresponds to a register defined
  in the SQLite database.
  */
  string reg_names[6] = '{
    "status_register",
    "control_register", 
    "configuration_register",
    "security_register",
    "status_flags",
    "control_bits"
  };

  /*
  Function: new
  Constructor for the SVDB dynamic sequence

  Parameter: name
  Name of the sequence instance
  */
  function new(string name = "svdb_dynamic_seq");
    super.new(name);
    db_path = "../../example_registers.db";
  endfunction

  /*
  Task: body
  Main sequence execution body

  This task performs the following operations:
  1. Retrieves the SVDB register block from configuration database
  2. Opens the SQLite database containing register definitions
  3. Iterates through predefined register names
  4. Configures each register using SVDB dynamic methods
  5. Performs write operations (if not read-only)
  6. Performs read operations and verifies expected values
  7. Reports test results

  The sequence handles different register access types:
  - RO (Read-Only): Only reads are performed, expected value is reset value
  - WO (Write-Only): Only writes are performed, reads return 0
  - RW (Read-Write): Both reads and writes are performed
  */
  task body();
    // Variable declarations
    uvm_status_e status;
    uvm_reg_data_t data;
    int unsigned wr_val;
    int unsigned exp_val;
    bit pass;
    string name;
    int i;
    svdb_reg_block blk;
    svdb_reg_model svdb_reg;
    svdb_uvm_pkg::register_attributes_t reg_attrs;
    logic [31:0] address;
    
    pass = 1;
    
    // Get the register block from the config DB
    if (!uvm_config_db#(svdb_reg_block)::get(null, "", "register_block_svdb", blk)) begin
      `uvm_fatal(get_name(), "register_block_svdb not found in config DB")
    end
    
    // Get the svdb_reg_config directly from the block
    svdb_reg = blk.svdb_reg_config;
    
    if (svdb_reg == null) begin
      `uvm_fatal(get_name(), "svdb_reg_config is null in register_block_svdb")
    end
    
    // Open the database using svdb_reg_model method
    svdb_reg.open_db(db_path);
    
    if (!svdb_reg.table_exists()) begin
      `uvm_fatal(get_name(), $sformatf("registers table does not exist in DB: %s", db_path))
    end
    
    // Loop over known register names
    for (i = 0; i < 6; i++) begin
      name = reg_names[i];
      
      // Configure the svdb_reg_model for the current register
      void'(svdb_reg.configure_register(name));
      
      // Get register attributes using svdb_reg_model's method
      reg_attrs = svdb_reg.get_register_attributes(name);
      
      // Set the offset in the default_map to mimic the current register's address
      address = svdb_reg.str_to_hex(reg_attrs.addressOffset);
      svdb_reg.set_offset(blk.get_default_map(), address);
      
      // Write phase (if not read-only)
      wr_val = $urandom();
      wr_val = wr_val & ((32'hFFFFFFFF) >> (32 - reg_attrs.width));
      
      if (reg_attrs.acc != "RO") begin
        svdb_reg.write(status, wr_val);
        if (status != UVM_IS_OK) begin
          `uvm_error(get_name(), $sformatf("[SVDB_DYN] Write error on %s (width=%0d, value=0x%0h)", name, reg_attrs.width, wr_val))
          pass = 0;
        end else begin
          last_written[i] = wr_val;
        end
      end
      
      // Read phase (always attempt to read)
      svdb_reg.read(status, data);
      if (status != UVM_IS_OK) begin
        `uvm_error(get_name(), $sformatf("[SVDB_DYN] Read error on %s (width=%0d)", name, reg_attrs.width))
        pass = 0;
      end else begin
        if (reg_attrs.acc == "RO") begin
          exp_val = reg_attrs.reset_value;
        end else if (reg_attrs.acc == "WO") begin
          exp_val = 0;
        end else begin
          exp_val = last_written[i];
        end

        exp_val = exp_val & ((32'hFFFFFFFF) >> (32 - reg_attrs.width));
        if (data !== exp_val) begin
          `uvm_error(get_name(), $sformatf("[SVDB_DYN] Read mismatch on %s, got 0x%0h, exp 0x%0h", name, data, exp_val))
          pass = 0;
        end else begin
          `uvm_info(get_name(), $sformatf("[SVDB_DYN] PASS: %s value=0x%0h", name, data), UVM_MEDIUM)
        end
      end
    end
    
    svdb_reg.close_db();
    
    if (pass) `uvm_info(get_name(), "All SVDB Dynamic register tests passed", UVM_MEDIUM)
    else      `uvm_error(get_name(), "Some SVDB Dynamic register tests failed")
  endtask
endclass

`endif // TEST_REGISTER_SEQUENCE_SV
