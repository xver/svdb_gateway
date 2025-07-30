/*
 * File: regbus_seq_item.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM sequence item for REGBUS protocol implementation
 */

`ifndef REGBUS_SEQ_ITEM_SV
`define REGBUS_SEQ_ITEM_SV

/*
Class: regbus_seq_item
UVM sequence item for REGBUS protocol implementation

This sequence item represents a single REGBUS transaction and extends the UVM TLM
generic payload. It includes methods for data conversion between byte arrays and
word format, and provides a string representation for debugging.

Inherits: uvm_tlm_generic_payload
*/
class regbus_seq_item extends uvm_tlm_generic_payload;

  /*
  Variable: response_err
  Error flag for REGBUS transaction response

  This variable indicates whether the REGBUS transaction resulted in an error
  response from the target device. It is set by the driver based on the
  protocol response signals.
  */
  bit response_err;

  `uvm_object_utils(regbus_seq_item)

  /*
  Function: new
  Constructor for the REGBUS sequence item

  Parameter: name
  Name of the sequence item instance
  */
  function new(string name = "regbus_seq_item"); 
    super.new(name); 
  endfunction 

  /*
  Function: pack_bytes_to_word
  Converts a byte array to a 32-bit word

  This static function takes a byte array and packs it into a 32-bit word using
  little-endian byte ordering.

  Parameter: data
  Byte array to convert

  Returns: 32-bit word representation of the byte array
  */
  static function bit [31:0] pack_bytes_to_word(byte unsigned data[]);
    bit [31:0] word = 0;
    for (int i = 0; i < 4; i++)
      word |= (data[i] & 8'hFF) << (i*8);
    return word;
  endfunction

  /*
  Function: unpack_word_to_bytes
  Converts a 32-bit word to a byte array

  This static function takes a 32-bit word and unpacks it into a byte array using
  little-endian byte ordering.

  Parameters:
    word - 32-bit word to convert
    data - Reference to byte array to populate
  */
  static function void unpack_word_to_bytes(bit [31:0] word, ref byte unsigned data[]);
    data = new[4];
    for (int i = 0; i < 4; i++)
      data[i] = (word >> (i*8)) & 8'hFF;
  endfunction

  /*
  Function: convert2string
  Converts the sequence item to a string representation

  This function creates a human-readable string representation of the REGBUS
  transaction for debugging and logging purposes.

  Returns: String representation of the transaction
  */
  function string convert2string();
    byte unsigned data[];
    bit [31:0] val;
    get_data(data);
    val = pack_bytes_to_word(data);
    return $sformatf("REGBUS: %s Addr=0x%0h Data=0x%0h", m_command==UVM_TLM_WRITE_COMMAND?"WR":"RD", m_address, val);
  endfunction
endclass

`endif // REGBUS_SEQ_ITEM_SV
