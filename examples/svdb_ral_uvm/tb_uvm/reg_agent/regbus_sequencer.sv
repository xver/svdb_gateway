/*
 * File: regbus_sequencer.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM sequencer for REGBUS protocol implementation
 */

`ifndef REGBUS_SEQUENCER_SV
`define REGBUS_SEQUENCER_SV

/*
Class: regbus_sequencer
UVM sequencer for REGBUS protocol implementation

This sequencer manages the generation of REGBUS sequence items and coordinates
between sequences and the driver. It provides the interface for sequences to
generate REGBUS transactions in a controlled manner.

Inherits: uvm_sequencer#(regbus_seq_item,regbus_seq_item)
*/
class regbus_sequencer extends uvm_sequencer#(regbus_seq_item,regbus_seq_item);
  `uvm_component_utils(regbus_sequencer)

  /*
  Function: new
  Constructor for the REGBUS sequencer

  Parameters:
    name - Name of the sequencer instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

`endif // REGBUS_SEQUENCER_SV
