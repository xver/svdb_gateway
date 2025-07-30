/*
 * File: test_register_block_sql_db.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM test for REGBUS protocol with SQLite database integration
 */

`ifndef TEST_REGISTER_BLOCK_SQL_DB_SV
`define TEST_REGISTER_BLOCK_SQL_DB_SV

/*
Class: test_register_block_sql_db
UVM test for REGBUS protocol with SQLite database integration

This test demonstrates the use of SVDB (SystemVerilog Database) for dynamic
register testing with SQLite database integration. It creates the testbench
environment and runs the SVDB dynamic sequence to test register operations.

Inherits: uvm_test
*/
class test_register_block_sql_db extends uvm_test;
  env env_h;
  `uvm_component_utils(test_register_block_sql_db)

  /*
  Function: new
  Constructor for the SQLite database test

  Parameters:
    name - Name of the test instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  /*
  Function: build_phase
  Builds the test components during the UVM build phase

  This function creates the testbench environment and registers a custom report
  catcher for handling SVDB-specific messages.

  Parameter: phase
  Current UVM phase
  */
  function void build_phase(uvm_phase phase);
    svdb_catcher catcher;
    super.build_phase(phase);
    env_h = env::type_id::create("env_h", this);
    // Register the custom report catcher (correct usage)
    catcher = new();
    uvm_report_cb::add(null, catcher);
  endfunction

  /*
  Task: run_phase
  Main test execution during the UVM run phase

  This task creates and starts the SVDB dynamic sequence to perform register
  testing using the SQLite database integration.

  Parameter: phase
  Current UVM phase
  */
  task run_phase(uvm_phase phase);
    svdb_dynamic_seq seq;
    phase.raise_objection(this);
    seq = svdb_dynamic_seq::type_id::create("seq");
    seq.start(env_h.agent.seq);
    phase.drop_objection(this);
  endtask
endclass

`endif // TEST_REGISTER_BLOCK_SQL_DB_SV
