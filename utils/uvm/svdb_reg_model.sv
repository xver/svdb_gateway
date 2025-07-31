/*
 * File: svdb_reg_model.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SVDB register model classes for UVM register abstraction
 */

`ifndef SVDB_REG_MODEL_SV
`define SVDB_REG_MODEL_SV

/*
Class: svdb_reg_model
Dynamically reconfigurable register model for SVDB

This class extends svdb_dynamic_reg to provide a concrete implementation of
the dynamic register model. It includes a build function that creates a default
32-bit read/write field configuration.

Inherits: svdb_dynamic_reg
*/
class svdb_reg_model extends svdb_dynamic_reg;
  `uvm_object_utils(svdb_reg_model)
  
  /*
  Function: new
  Constructor for the SVDB register model

  Parameters:
    name - Name of the register model instance
    n_bits - Number of bits in the register (default: 32)
    has_coverage - Coverage mode for the register (default: UVM_NO_COVERAGE)
  */
  function new(string name = "svdb_dynamic_reg", int unsigned n_bits = 32, int has_coverage = UVM_NO_COVERAGE);
    super.new(name, n_bits, has_coverage);
  endfunction
   
  /*
  Function: build
  Builds the register model with default configuration

  This function creates a default 32-bit read/write field configuration and
  stores the configuration parameters for later use.
  */
  virtual function void build();
    dyn_field = uvm_reg_field::type_id::create("dyn_field",,get_full_name());
    // Default config: 32b RW, lsb 0, reset 0
    dyn_field.configure(
      .parent(this),
      .size(32),
      .lsb_pos(0), // Using default lsb_pos
      .access("RW"),
      .volatile(0),
      .reset(32'h0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    // Store config
    access_mode = "RW";
    field_size = 32;
    field_lsb_pos = 0; // Using default lsb_pos
    field_volatile = 0;
    field_reset = 32'h0;
    field_has_reset = 1;
    field_is_rand = 0;
    field_individually_accessible = 0;
  endfunction

endclass

/*
Class: svdb_reg_block
SVDB register block for UVM register abstraction

This class extends uvm_reg_block to provide a complete register block
implementation for SVDB. It includes a configurable register model and
creates a default register map for register access.

Inherits: uvm_reg_block
*/
class svdb_reg_block extends uvm_reg_block;
  `uvm_object_utils(svdb_reg_block)

  /*
  Variable: base_addr
  Base address for the register block

  This variable holds the base address for the register block.
  Default value is 0.
  */
  protected uvm_reg_addr_t base_addr = 0;

  /*
  Variable: n_bytes
  Number of bytes for the register block

  This variable holds the number of bytes for the register block.
  Default value is 4.
  */
  protected int unsigned n_bytes = 4;

  /*
  Variable: byte_addressing
  Byte addressing mode for the register block

  This variable controls whether the register block uses byte addressing (1)
  or word addressing (0). Default value is 1 (byte addressing).
  */
  protected bit byte_addressing = 1;

  /*
  Variable: svdb_reg_config
  Configurable register model instance

  This variable holds the SVDB register model instance that can be
  dynamically configured based on database contents. It provides the
  interface for dynamic register configuration and access.
  */
  rand svdb_reg_model       svdb_reg_config;

  /*
  Function: new
  Constructor for the SVDB register block

  Parameter: name
  Name of the register block instance
  */
  function new(string name = "svdb_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  /*
  Function: set_base_addr
  Sets the base address for the register block

  Parameter: addr
  Base address to set for the register block
  */
  virtual function void set_base_addr(uvm_reg_addr_t addr);
    base_addr = addr;
  endfunction

  /*
  Function: get_base_addr
  Gets the base address for the register block

  Returns: uvm_reg_addr_t
  Current base address of the register block
  */
  virtual function uvm_reg_addr_t get_base_addr();
    return base_addr;
  endfunction

  /*
  Function: set_n_bytes
  Sets the number of bytes for the register block

  Parameter: bytes
  Number of bytes to set for the register block
  */
  virtual function void set_n_bytes(int unsigned bytes);
    n_bytes = bytes;
  endfunction

  /*
  Function: get_n_bytes
  Gets the number of bytes for the register block

  Returns: int unsigned
  Current number of bytes of the register block
  */
  virtual function int unsigned get_n_bytes();
    return n_bytes;
  endfunction

  /*
  Function: set_byte_addressing
  Sets the byte addressing mode for the register block

  Parameter: mode
  Byte addressing mode: 1 for byte addressing, 0 for word addressing
  */
  virtual function void set_byte_addressing(bit mode);
    byte_addressing = mode;
  endfunction

  /*
  Function: get_byte_addressing
  Gets the byte addressing mode for the register block

  Returns: bit
  Current byte addressing mode: 1 for byte addressing, 0 for word addressing
  */
  virtual function bit get_byte_addressing();
    return byte_addressing;
  endfunction

  /*
  Function: build
  Builds the register block with default configuration

  This function creates the SVDB register model, builds it, and sets up
  a default register map for register access at address 0.
  */
  virtual function void build();
    svdb_reg_config = svdb_reg_model::type_id::create("svdb_reg_config",,get_full_name());
    svdb_reg_config.build();
    // Register map
    this.default_map = create_map(.name("default_map"), .base_addr(base_addr), .n_bytes(n_bytes), .endian(UVM_LITTLE_ENDIAN), .byte_addressing(byte_addressing));
    svdb_reg_config.configure(this, null, "svdb_reg_config");
    default_map.add_reg(svdb_reg_config, 'h0, "RW");
  endfunction
endclass

`endif // SVDB_REG_MODEL_SV
