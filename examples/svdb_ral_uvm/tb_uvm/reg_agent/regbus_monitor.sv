/*
 * File: regbus_monitor.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM monitor for REGBUS protocol implementation
 */

`ifndef REGBUS_MONITOR_SV
`define REGBUS_MONITOR_SV

/*
Class: regbus_monitor
UVM monitor for REGBUS protocol implementation

This monitor observes REGBUS transactions on the virtual interface and converts them
into REGBUS sequence items for analysis. It monitors the protocol signals and
captures both read and write transactions for coverage and checking purposes.

Inherits: uvm_monitor
*/
class regbus_monitor extends uvm_monitor;

  /*
  Variable: vif
  Virtual interface for REGBUS protocol

  This variable holds the virtual interface that provides the connection
  to the REGBUS protocol signals for monitoring transactions.
  */
  virtual regbus_if vif;

  /*
  Variable: item_collected_port
  Analysis port for collected REGBUS sequence items

  This variable provides an analysis port that broadcasts collected REGBUS
  sequence items to other components for analysis, coverage, and checking.
  */
  uvm_analysis_port#(regbus_seq_item) item_collected_port;

  `uvm_component_utils(regbus_monitor)

  /*
  Function: new
  Constructor for the REGBUS monitor

  Parameters:
    name - Name of the monitor instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  /*
  Function: build_phase
  Builds the monitor during the UVM build phase

  Parameter: phase
  Current UVM phase
  */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual regbus_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for regbus_monitor")
  endfunction

  /*
  Task: run_phase
  Main execution loop for the REGBUS monitor

  This task continuously monitors the REGBUS interface for transactions. When a
  valid transaction is detected (psel and penable both high), it creates a
  sequence item and sends it through the analysis port for further processing.

  Parameter: phase
  Current UVM phase
  */
  task run_phase(uvm_phase phase);
    regbus_seq_item txn;
    byte unsigned data[];
    bit [31:0] val;
    forever begin
      @(posedge vif.clk);
      if (vif.psel && vif.penable) begin
        txn = regbus_seq_item::type_id::create("txn");
        txn.m_command = vif.pwrite ? UVM_TLM_WRITE_COMMAND : UVM_TLM_READ_COMMAND;
        txn.m_address = vif.paddr;
        val = vif.pwrite ? vif.pwdata : vif.prdata;
        regbus_seq_item::unpack_word_to_bytes(val, data);
        txn.set_data(data);
        txn.response_err = vif.pslverr;
        item_collected_port.write(txn);
      end
    end
  endtask
endclass

`endif // REGBUS_MONITOR_SV
