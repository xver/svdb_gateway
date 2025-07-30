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
      .lsb_pos(0),
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
    field_lsb_pos = 0;
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
  Function: build
  Builds the register block with default configuration

  This function creates the SVDB register model, builds it, and sets up
  a default register map for register access at address 0.
  */
  virtual function void build();
    svdb_reg_config = svdb_reg_model::type_id::create("svdb_reg_config",,get_full_name());
    svdb_reg_config.build();
    // Register map
    this.default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    svdb_reg_config.configure(this, null, "svdb_reg_config");
    default_map.add_reg(svdb_reg_config, 'h0, "RW");
  endfunction
endclass

`endif // SVDB_REG_MODEL_SV
