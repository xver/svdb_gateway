/*
 * File: svdb_uvm_pkg.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SystemVerilog package for SVDB UVM register abstraction
 */

package svdb_uvm_pkg;

/*
Section: Data structures for SVDB register abstraction
Defines structures for field and register information
*/

/*
Struct: field_info_t
Structure to hold field information from database

This structure contains all the necessary information for a register field
including name, access type, reset value, bit offset, width, and various
configuration flags.

Members:
  name - Field name
  access - Access type (RO, WO, RW)
  resetValue - Reset value as string
  bitOffset - Bit offset within register
  bitWidth - Bit width of the field
  individually_accessible - Flag for individual field access
  is_random - Flag for random field generation
  mirror - Flag for field mirroring
  volatile_val - Flag for volatile field behavior
  has_reset_val - Flag indicating if field has reset value
*/
typedef struct {
  string name;
  string access;
  string resetValue;
  int bitOffset;
  int bitWidth;
  int individually_accessible;
  int is_random;
  int mirror;
  int volatile_val;
  int has_reset_val;
} field_info_t;
  
/*
Struct: register_fields_t
Structure to hold all fields for a register

This structure contains an array of field information and a count of the
number of fields for a specific register.

Members:
  fields - Array of field_info_t structures
  num_fields - Number of fields in the register
*/
typedef struct {
  field_info_t fields[];
  int num_fields;
} register_fields_t;
  
/*
Struct: register_attributes_t
Structure to hold register attributes from database

This structure contains all the necessary information for a register
including address offset, size, access type, reset value, and various
configuration parameters.

Members:
  addressOffset - Register address offset as string
  size - Register size as string
  access - Access type as string
  resetValue - Reset value as string
  lsb_pos_str - LSB position as string
  volatile_str - Volatile flag as string
  has_reset_str - Has reset flag as string
  is_rand_str - Is random flag as string
  individually_accessible_str - Individually accessible flag as string
  width - Register width in bits
  reset_value - Reset value as 32-bit logic
  lsb_pos - LSB position as integer
  volatile_val - Volatile flag as integer
  has_reset_val - Has reset flag as integer
  is_rand_val - Is random flag as integer
  individually_accessible_val - Individually accessible flag as integer
  acc - Access type for UVM (RO, WO, RW)
*/
typedef struct {
  string addressOffset;
  string size;
  string access;
  string resetValue;
  string lsb_pos_str;
  string volatile_str;
  string has_reset_str;
  string is_rand_str;
  string individually_accessible_str;
  int width;
  logic [31:0] reset_value;
  int lsb_pos;
  int volatile_val;
  int has_reset_val;
  int is_rand_val;
  int individually_accessible_val;
  string acc;
} register_attributes_t;

/*
Section: Package includes
Includes all SVDB UVM components
*/
`include "svdb_catcher.sv"
`include "svdb_dynamic_reg.sv"
`include "svdb_reg_model.sv"

endpackage
