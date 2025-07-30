/*
 * File: regbus_driver.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM driver for REGBUS protocol implementation
 */

`ifndef REGBUS_DRIVER_SV
`define REGBUS_DRIVER_SV

/*
Class: regbus_driver
UVM driver for REGBUS protocol implementation

This driver receives REGBUS sequence items from the sequencer and converts them into
actual REGBUS protocol transactions on the virtual interface. It handles both read
and write operations and manages the data conversion between byte arrays and word
format.

Inherits: uvm_driver#(regbus_seq_item)
*/
class regbus_driver extends uvm_driver#(regbus_seq_item);

  /*
  Variable: vif
  Virtual interface for REGBUS protocol

  This variable holds the virtual interface that provides the connection
  to the REGBUS protocol signals for driving transactions.
  */
  virtual regbus_if vif;

  `uvm_component_utils(regbus_driver)

  /*
  Function: new
  Constructor for the REGBUS driver

  Parameters:
    name - Name of the driver instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  /*
  Function: build_phase
  Builds the driver during the UVM build phase

  Parameter: phase
  Current UVM phase
  */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual regbus_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for regbus_driver")
  endfunction

  /*
  Task: run_phase
  Main execution loop for the REGBUS driver

  This task continuously processes sequence items from the sequencer, converts them
  to REGBUS protocol transactions, and handles the data conversion between byte
  arrays and word format.

  Parameter: phase
  Current UVM phase
  */
  task run_phase(uvm_phase phase);
    regbus_seq_item req;
    byte unsigned data[];
    bit [31:0] wr_val;
    bit [31:0] rd_val;
    bit response_err;
    forever begin
      seq_item_port.get_next_item(req);
      req.get_data(data);
      wr_val = regbus_seq_item::pack_bytes_to_word(data);
      rd_val = wr_val;
      vif.do_regbus_transfer(
        req.m_command == UVM_TLM_WRITE_COMMAND,
        req.m_address,
        rd_val,
        response_err
      );
      req.response_err = response_err;
      if (req.m_command != UVM_TLM_WRITE_COMMAND) begin
        regbus_seq_item::unpack_word_to_bytes(rd_val, data);
        req.set_data(data);
      end
      seq_item_port.item_done();
    end
  endtask
endclass

`endif // REGBUS_DRIVER_SV
