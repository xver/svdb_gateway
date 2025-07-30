/*
 * File: regbus2reg_adapter.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM RAL adapter for REGBUS bus protocol
 */

`ifndef REGBUS2REG_ADAPTER_SV
`define REGBUS2REG_ADAPTER_SV

/*
Class: regbus2reg_adapter
UVM RAL adapter for converting between UVM register operations and REGBUS protocol

This adapter provides the interface between UVM register model operations and the REGBUS
protocol implementation. It handles the conversion of register read/write operations
to and from REGBUS sequence items.

Inherits: uvm_reg_adapter
*/
class regbus2reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(regbus2reg_adapter)

  /*
  Function: new
  Constructor for the REGBUS to register adapter

  Parameter: name
  Name of the adapter instance
  */
  function new(string name = "regbus2reg_adapter");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses = 0;
  endfunction

  /*
  Function: reg2bus
  Converts a UVM register operation to a REGBUS sequence item

  Parameter: rw
  Reference to the UVM register bus operation

  Returns: UVM sequence item representing the REGBUS transaction
  */
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    regbus_seq_item bus_item;
    byte unsigned data[];
    bus_item = regbus_seq_item::type_id::create("bus_item");
    bus_item.m_address = rw.addr;
    regbus_seq_item::unpack_word_to_bytes(rw.data, data);
    bus_item.set_data(data);
    bus_item.m_command = (rw.kind == UVM_WRITE) ? UVM_TLM_WRITE_COMMAND : UVM_TLM_READ_COMMAND;
    return bus_item;
  endfunction

  /*
  Function: bus2reg
  Converts a REGBUS sequence item to a UVM register operation

  Parameters:
    bus_item - The REGBUS sequence item to convert
    rw - Reference to the UVM register bus operation to populate
  */
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    regbus_seq_item regbus_item;
    byte unsigned data[];
    if (!$cast(regbus_item, bus_item)) begin
      `uvm_fatal("REGBUS/REG ADAPTER", "bus_item is not of type regbus_seq_item")
    end
    rw.addr = regbus_item.m_address;
    regbus_item.get_data(data);
    rw.data = regbus_seq_item::pack_bytes_to_word(data);
    rw.kind = (regbus_item.m_command == UVM_TLM_WRITE_COMMAND) ? UVM_WRITE : UVM_READ;
    rw.status = UVM_IS_OK;
  endfunction
endclass

`endif // REGBUS2REG_ADAPTER_SV
