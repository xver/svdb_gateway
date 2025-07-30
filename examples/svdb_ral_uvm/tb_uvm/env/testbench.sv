/*
 * File: testbench.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Testbench file with all necessary includes for REGBUS protocol verification
 */

/*
Section: Package imports
Imports all required packages for the testbench
*/
import uvm_pkg::*;
import icecream_pkg::*;
import sqlite_dpi_pkg::*;
import svdb_uvm_pkg::*;

`include "uvm_macros.svh"

/*
Section: REGBUS agent includes
Includes all REGBUS protocol implementation files
*/
`include "regbus_seq_item.sv"
`include "regbus_driver.sv"
`include "regbus_monitor.sv"
`include "regbus_sequencer.sv"
`include "regbus2reg_adapter.sv"

/*
Section: Register model includes
Includes register model and SVDB dynamic register files
*/
`include "svdb_dynamic_reg.sv"
`include "register_example_reg_model.sv"
`include "regbus_agent.sv"

/*
Section: Environment and test includes
Includes the UVM environment and test files
*/
`include "env.sv"
`include "test_register_block_sql_db.sv"
`include "tb_top.sv"

