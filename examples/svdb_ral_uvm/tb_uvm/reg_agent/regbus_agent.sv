/*
 * File: regbus_agent.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM agent for REGBUS protocol implementation
 */

`ifndef REGBUS_AGENT_SV
`define REGBUS_AGENT_SV

/*
Class: regbus_agent
UVM agent for REGBUS protocol implementation

This agent encapsulates the driver, sequencer, and monitor components for the REGBUS
protocol. It provides a complete interface for generating and monitoring REGBUS
transactions in a UVM testbench environment.

Inherits: uvm_agent
*/
class regbus_agent extends uvm_agent;

  /*
  Variable: drv
  REGBUS driver instance

  This variable holds the REGBUS driver that converts sequence items into
  protocol transactions on the virtual interface.
  */
  regbus_driver    drv;

  /*
  Variable: seq
  REGBUS sequencer instance

  This variable holds the REGBUS sequencer that manages sequence item
  generation and coordinates between sequences and the driver.
  */
  regbus_sequencer seq;

  /*
  Variable: mon
  REGBUS monitor instance

  This variable holds the REGBUS monitor that observes protocol transactions
  and converts them into sequence items for analysis.
  */
  regbus_monitor   mon;

  `uvm_component_utils(regbus_agent)

  /*
  Function: new
  Constructor for the REGBUS agent

  Parameters:
    name - Name of the agent instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  /*
  Function: build_phase
  Builds the agent components during the UVM build phase

  Parameter: phase
  Current UVM phase
  */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = regbus_driver::type_id::create("drv", this);
    seq = regbus_sequencer::type_id::create("seq", this);
    mon = regbus_monitor::type_id::create("mon", this);
  endfunction

  /*
  Function: connect_phase
  Connects the agent components during the UVM connect phase

  Parameter: phase
  Current UVM phase
  */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seq.seq_item_export);
  endfunction
endclass

`endif // REGBUS_AGENT_SV
