/*
 * File: svdb_dynamic_reg.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Dynamically reconfigurable UVM register with SQLite database integration
 */

`ifndef SVDB_DYNAMIC_REG_SV
`define SVDB_DYNAMIC_REG_SV

// Import the DPI SQLite package
import sqlite_dpi_pkg::*;

/*
Class: svdb_dynamic_reg
Dynamically reconfigurable UVM register with SQLite database integration

This class extends uvm_reg to provide dynamic register configuration capabilities
using a SQLite database. It allows registers to be configured at runtime based
on database contents, supporting dynamic field creation, access mode changes,
and register attribute updates.

The class provides methods for:
- Database connection management
- Dynamic register configuration
- Field management and validation
- Register attribute retrieval
- HDL path resolution

Inherits: uvm_reg
*/
class svdb_dynamic_reg extends uvm_reg;

  `uvm_object_utils(svdb_dynamic_reg)

  /*
  Variable: dyn_field
  Dynamic register field for runtime configuration

  This field is created and configured dynamically based on database contents.
  It represents the main field of the register and can be reconfigured at runtime.
  */
  rand uvm_reg_field dyn_field;
  
  /*
  Section: Configuration parameters
  Store config params for possible reporting/debug
  */

  /*
  Variable: access_mode
  Access mode of the register field (RO, WO, RW)

  This variable stores the access mode configuration for the register field
  and is used for reporting and debugging purposes.
  */
  string access_mode;

  /*
  Variable: field_size
  Size of the register field in bits

  This variable stores the size of the register field and is used for
  validation and reporting purposes.
  */
  int unsigned field_size;

  /*
  Variable: field_lsb_pos
  LSB position of the register field

  This variable stores the least significant bit position of the register
  field within the register.
  */
  int unsigned field_lsb_pos;

  /*
  Variable: field_volatile
  Volatile flag for the register field

  This variable indicates whether the register field is volatile and should
  not be cached during read operations.
  */
  bit field_volatile;

  /*
  Variable: field_reset
  Reset value for the register field

  This variable stores the reset value for the register field and is used
  during field configuration.
  */
  uvm_reg_data_t field_reset;

  /*
  Variable: field_has_reset
  Flag indicating if the field has a reset value

  This variable indicates whether the register field has a defined reset
  value or not.
  */
  bit field_has_reset;

  /*
  Variable: field_is_rand
  Flag indicating if the field is randomizable

  This variable indicates whether the register field can be randomized
  during test generation.
  */
  bit field_is_rand;

  /*
  Variable: field_individually_accessible
  Flag indicating if the field is individually accessible

  This variable indicates whether the register field can be accessed
  individually or only as part of the register.
  */
  bit field_individually_accessible;
 
  /*
  Section: SVDB-specific member variables
  Internal state variables for SVDB functionality
  */

  /*
  Variable: svdb_m_n_bits
  Total number of bits in the register

  This variable stores the total number of bits available in the register
  for field allocation.
  */
  int unsigned      svdb_m_n_bits;

  /*
  Variable: svdb_m_n_used_bits
  Number of bits currently used by fields

  This variable tracks how many bits are currently allocated to fields
  in the register.
  */
  int unsigned      svdb_m_n_used_bits;

  /*
  Variable: svdb_m_locked
  Flag indicating if the register is locked from modification

  This variable indicates whether the register configuration is locked
  and cannot be modified further.
  */
  bit               svdb_m_locked;

  /*
  Variable: svdb_name
  Name of the register in the SVDB system

  This variable stores the name of the register as used in the SVDB
  database and configuration system.
  */
  string svdb_name;

  /*
  Section: Database connection
  Database handle and path for SQLite operations
  */

  /*
  Variable: SqliteDB
  Handle to the SQLite database connection

  This variable stores the handle to the SQLite database that contains
  the register configuration information.
  */
  chandle SqliteDB;

  /*
  Variable: SqliteDB_path
  Path to the SQLite database file

  This variable stores the file path to the SQLite database that contains
  the register configuration information.
  */
  string SqliteDB_path;

  /*
  Function: new
  Constructor for the SVDB dynamic register

  Parameters:
    name - Name of the register instance
    n_bits - Number of bits in the register (default: 32)
    has_coverage - Coverage mode for the register (default: UVM_NO_COVERAGE)
  */
  extern function new(string name = "svdb_dynamic_reg", int unsigned n_bits = 32, int has_coverage = UVM_NO_COVERAGE);
   
  /*
  Function: add_field
  Adds a field to the register

  Parameter: field
  UVM register field to add to the register
  */
  extern function void add_field(uvm_reg_field field);

  /*
  Function: test_table_existence
  Tests if the registers table exists in the database

  Returns: 1 if table exists, 0 otherwise
  */
  extern function bit test_table_existence();

  /*
  Function: get_svdb_name
  Accessor to get the current register name

  Returns: Current register name
  */
  extern function string get_svdb_name();

  /*
  Function: set_svdb_name
  Accessor to set the current register name

  Parameter: name
  New name for the register
  */
  extern function void set_svdb_name(string name);

  /*
  Function: delete_fields
  Deletes all fields from the register

  This function removes all fields from the register and resets the used bits
  counter to zero.
  */
  extern function void delete_fields();

  /*
  Function: open_db
  Opens a SQLite database connection

  Parameter: path
  Path to the SQLite database file
  */
  extern function void open_db(string path);

  /*
  Function: close_db
  Closes the SQLite database connection

  This function safely closes the database connection and nullifies the handle.
  */
  extern function void close_db();

  /*
  Function: table_exists
  Checks if a table exists in the database

  Parameter: table_name
  Name of the table to check (default: "registers")

  Returns: 1 if table exists, 0 otherwise
  */
  extern function bit table_exists(string table_name = "registers");

  /*
  Function: load_register_by_name
  Loads register configuration from database by name

  Parameter: reg_name
  Name of the register to load from database

  Returns: 1 on success, 0 on failure
  */
  extern function bit load_register_by_name(string reg_name);

  /*
  Function: get_hdlpath
  Gets the HDL path for a register from the database

  Parameter: reg_name
  Name of the register

  Returns: HDL path string, empty if not found
  */
  extern function string get_hdlpath(string reg_name);

  /*
  Function: get_register_attributes
  Gets register attributes by name from the database

  Parameter: reg_name
  Name of the register

  Returns: register_attributes_t structure with register attributes
  */
  extern function register_attributes_t get_register_attributes(string reg_name);
  
  /*
  Function: configure_register
  Configures register with all fields from database

  Parameter: reg_name
  Name of the register to configure

  Returns: Configured register instance, null on failure
  */
  extern function svdb_dynamic_reg configure_register(string reg_name);

  /*
  Function: str_to_hex
  Helper function to convert string to hex

  Parameter: s
  String to convert to hex

  Returns: 32-bit hex value
  */
  extern function bit [31:0] str_to_hex(string s);
  
  /*
  Function: get_fields_for_register
  Helper function to get fields for a register

  Parameter: reg_row_id
  Database row ID of the register

  Returns: register_fields_t structure with field information
  */
  extern function register_fields_t get_fields_for_register(int reg_row_id);

  /*
  Function: print_fields_for_register
  Function to print all fields of this register instance

  This function prints detailed information about all fields in the register
  for debugging purposes.
  */
  extern function void print_fields_for_register();

endclass // svdb_dynamic_reg


// Implementations
function svdb_dynamic_reg::new(string name = "svdb_dynamic_reg", int unsigned n_bits = 32, int has_coverage = UVM_NO_COVERAGE);
  super.new(name, n_bits, has_coverage);
  svdb_m_n_used_bits = 0;
  svdb_m_n_bits = 0;
  svdb_m_locked= 0;
endfunction // new


function bit svdb_dynamic_reg::test_table_existence();
  $display("\n[TEST 1] Checking if registers table exists...");
  if (sqlite_dpi_table_exists(SqliteDB, "registers") > 0) begin
     $display("PASS: registers table exists");
     return 1'b1;
  end else begin
     $display("ERROR: registers table does not exist");
     return 1'b0;
  end
endfunction // test_table_existence

function void svdb_dynamic_reg::add_field(uvm_reg_field field);
  int offset;
  int idx;
  if (svdb_m_locked) begin
    `uvm_error("RegModel", "Cannot add field to locked register model")
    return;
  end
  if (field == null) `uvm_fatal("RegModel", "Attempting to register NULL field")
  // Store fields in LSB to MSB order
  offset = field.get_lsb_pos();
  idx = -1;
  foreach (m_fields[i]) begin
    if (offset < m_fields[i].get_lsb_pos()) begin
      int j = i;
      m_fields.insert(j, field);
      idx = i;
      break;
    end
  end
  if (idx < 0) begin
    m_fields.push_back(field);
    idx = m_fields.size()-1;
  end
  svdb_m_n_used_bits += field.get_n_bits();
  // Check if there are too many fields in the register
  svdb_m_n_bits = get_n_bits();
  if (svdb_m_n_used_bits > svdb_m_n_bits) begin
    `uvm_error("RegModel",
      $sformatf("Fields use more bits (%0d) than available in register \"%s\" (%0d)",
        svdb_m_n_used_bits, get_name(), svdb_m_n_bits))
  end
  // Check if there are overlapping fields
  if (idx > 0) begin
    if (m_fields[idx-1].get_lsb_pos() +
        m_fields[idx-1].get_n_bits() > offset) begin
      `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in register \"%s\"",
        m_fields[idx-1].get_name(),
        field.get_name(), get_name()))
    end
  end
  if (idx < m_fields.size()-1) begin
    if (offset + field.get_n_bits() >
        m_fields[idx+1].get_lsb_pos()) begin
      `uvm_error("RegModel", $sformatf("Field %s overlaps field %s in register \"%s\"",
        field.get_name(),
        m_fields[idx+1].get_name(),
        get_name()))
    end
  end
endfunction

function void svdb_dynamic_reg::open_db(string path);
  SqliteDB_path = path;
  SqliteDB = sqlite_dpi_open_database(SqliteDB_path);
  if (SqliteDB == null) begin
    `uvm_fatal("RegModel", $sformatf("Could not open SQLite database: %s", SqliteDB_path))
  end
endfunction

function void svdb_dynamic_reg::close_db();
  if (SqliteDB != null) begin
    sqlite_dpi_close_database(SqliteDB);
    SqliteDB = null;
  end
endfunction

/*
Function: table_exists
Checks if a table exists in the database
*/
function bit svdb_dynamic_reg::table_exists(string table_name = "registers");
  if (SqliteDB == null) begin
    `uvm_error("RegModel", "Database not open")
    return 0;
  end
  return (sqlite_dpi_table_exists(SqliteDB, table_name) > 0);
endfunction

/*
Function: load_register_by_name
Loads register configuration from database by name
*/
function bit svdb_dynamic_reg::load_register_by_name(string reg_name);
  int row_id;
  string name, addressOffset, size, access, resetValue;
  string volatile_str, is_rand_str, individually_accessible_str;
  int n_bits, lsb_pos, reset_val;
  int volatile_val, is_rand_val, individually_accessible_val;
  bit has_reset = 1;
  string acc;
  if (SqliteDB == null) begin
    `uvm_error("RegModel", "Database not open")
    return 0;
  end
  row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "registers", "name", reg_name);
  if (row_id <= 0) begin
    `uvm_error("RegModel", $sformatf("Register '%s' not found in database", reg_name))
    return 0;
  end
  name         = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "name");
  addressOffset= sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "addressOffset");
  size         = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "size");
  access       = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "access");
  resetValue   = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "resetValue");
  volatile_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "volatile");
  is_rand_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "rand");
  individually_accessible_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "individually_accessible");
  
  // Convert string fields to int as needed
  n_bits = size.atoi();
  lsb_pos = 0; // Default to 0, can be extended
  reset_val = resetValue.atoi();
  volatile_val = (volatile_str == "") ? 0 : volatile_str.atoi();
  is_rand_val = (is_rand_str == "") ? 0 : is_rand_str.atoi();
  individually_accessible_val = (individually_accessible_str == "") ? 0 : individually_accessible_str.atoi();
  
  // Map access string to UVM access
  if (access == "read-only" || access == "RO") acc = "RO";
  else if (access == "write-only" || access == "WO") acc = "WO";
  else acc = "RW";
  // Remove any existing fields
  delete_fields();
  // Create and configure the dynamic field
  dyn_field = uvm_reg_field::type_id::create("dyn_field",,get_full_name());
  dyn_field.configure(
    .parent(this),
    .size(n_bits),
    .lsb_pos(lsb_pos),
    .access(acc),
    .volatile(volatile_val),
    .reset(reset_val),
    .has_reset(has_reset),
    .is_rand(is_rand_val),
    .individually_accessible(individually_accessible_val)
  );
  set_svdb_name(name);
  svdb_m_n_used_bits = n_bits;
  svdb_m_n_bits = n_bits;
  return 1;
endfunction

/*
Function: get_hdlpath
Gets the HDL path for a register from the database
*/
function string svdb_dynamic_reg::get_hdlpath(string reg_name);
  string hdlpath_key, query, hdlpath;
  int rc, row_id;
  if (SqliteDB == null) begin
    `uvm_error("RegModel", "Database not open")
    return "";
  end
  hdlpath_key = {"register:", reg_name, ":hdlPath"};
  row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "vendorExtensions", "key", hdlpath_key);
  if (row_id > 0)
    hdlpath = sqlite_dpi_get_cell_value(SqliteDB, "vendorExtensions", row_id, "value");
  else
    hdlpath = "";
  return hdlpath;
endfunction

/*
Function: get_svdb_name
Accessor to get the current register name
*/
function string svdb_dynamic_reg::get_svdb_name();
  return svdb_name;
endfunction

/*
Function: set_svdb_name
Accessor to set the current register name
*/
function void svdb_dynamic_reg::set_svdb_name(string name);
  svdb_name = name;
endfunction

/*
Function: delete_fields
Deletes all fields from the register
*/
function void svdb_dynamic_reg::delete_fields();
  this.m_fields.delete();
  this.svdb_m_n_used_bits = 0;
  dyn_field = null;
endfunction

/*
Function: str_to_hex
Helper function to convert string to hex
*/
function bit [31:0] svdb_dynamic_reg::str_to_hex(string s);
  bit [31:0] result=0;
  string hex_digits;
  int width;

  // Try to match [WIDTH]'h[HEX]
  if ($sscanf(s, "%d'h%s", width, hex_digits) == 2) begin
      if (!$sscanf(hex_digits, "%h", result)) begin
          `uvm_error("str_to_hex", $sformatf("Failed to parse hex string '%s'", s))
      end
      return result;
  end

  // Try other formats
  if (s.len() >= 2 && s.substr(0,1) == "'h") begin
    hex_digits = s.substr(2, s.len()-1);
  end else if (s.len() >= 1 && s.substr(0,0) == "h") begin
    hex_digits = s.substr(1, s.len()-1);
  end else begin
    hex_digits = s;
  end
  
  if (!$sscanf(hex_digits, "%h", result)) begin
      `uvm_error("str_to_hex", $sformatf("Unsupported hex format: '%s'", s))
  end

  return result;
endfunction

/*
Function: get_fields_for_register
Helper function to get fields for a register
*/
function register_fields_t svdb_dynamic_reg::get_fields_for_register(int reg_row_id);
  register_fields_t fields_struct;
  int field_row_id;
  string reg_id_str;
  int max_field_rows = 256;
  int field_idx;
  fields_struct.num_fields = 0;
  
  // First pass: count the number of fields for this register
  for (field_row_id = 1; field_row_id <= max_field_rows; field_row_id++) begin
    reg_id_str = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "register_id");
    if (reg_id_str == "") continue;
    if (reg_id_str.atoi() != reg_row_id) continue;
    fields_struct.num_fields++;
  end
  
  // Allocate the fields array
  fields_struct.fields = new[fields_struct.num_fields];
  
  // Second pass: populate the fields
  field_idx = 0;
  for (field_row_id = 1; field_row_id <= max_field_rows; field_row_id++) begin
    reg_id_str = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "register_id");
    if (reg_id_str == "") continue;
    if (reg_id_str.atoi() != reg_row_id) continue;
    
    fields_struct.fields[field_idx].name = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "name");
    fields_struct.fields[field_idx].access = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "access");
    fields_struct.fields[field_idx].resetValue = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "resetValue");
    fields_struct.fields[field_idx].bitOffset = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "bitOffset").atoi();
    fields_struct.fields[field_idx].bitWidth = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "bitWidth").atoi();
    fields_struct.fields[field_idx].individually_accessible = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "individually_accessible").atoi();
    fields_struct.fields[field_idx].is_random = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "rand").atoi();
    fields_struct.fields[field_idx].mirror = sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "mirror").atoi();
    fields_struct.fields[field_idx].volatile_val = (sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "volatile") == "") ? 0 : sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "volatile").atoi();
    fields_struct.fields[field_idx].has_reset_val = (sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "has_reset") == "") ? 1 : sqlite_dpi_get_cell_value(SqliteDB, "fields", field_row_id, "has_reset").atoi();
    field_idx++;
  end
  return fields_struct;
endfunction

/*
Function: get_register_attributes
Gets register attributes by name from the database
*/
function register_attributes_t svdb_dynamic_reg::get_register_attributes(string reg_name);
  register_attributes_t reg_attrs;
  int row_id;
  
  if (SqliteDB == null) begin
    `uvm_error("RegModel", "Database not open")
    return reg_attrs;
  end
  
  // Get register row ID
  row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "registers", "name", reg_name);
  if (row_id <= 0) begin
    `uvm_error("RegModel", $sformatf("Register '%s' not found in database", reg_name))
    return reg_attrs;
  end
  
  // Retrieve raw string values from database
  reg_attrs.addressOffset = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "addressOffset");
  reg_attrs.size = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "size");
  reg_attrs.access = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "access");
  reg_attrs.resetValue = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "resetValue");
  reg_attrs.lsb_pos_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "lsb_pos");
  reg_attrs.volatile_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "volatile");
  reg_attrs.has_reset_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "has_reset");
  reg_attrs.is_rand_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "rand");
  reg_attrs.individually_accessible_str = sqlite_dpi_get_cell_value(SqliteDB, "registers", row_id, "individually_accessible");
  
  // Process and convert values
  reg_attrs.reset_value = str_to_hex(reg_attrs.resetValue);
  reg_attrs.lsb_pos = (reg_attrs.lsb_pos_str == "") ? 0 : reg_attrs.lsb_pos_str.atoi();
  reg_attrs.volatile_val = (reg_attrs.volatile_str == "") ? 0 : reg_attrs.volatile_str.atoi();
  reg_attrs.has_reset_val = (reg_attrs.has_reset_str == "") ? 1 : reg_attrs.has_reset_str.atoi();
  reg_attrs.is_rand_val = (reg_attrs.is_rand_str == "") ? 0 : reg_attrs.is_rand_str.atoi();
  reg_attrs.individually_accessible_val = (reg_attrs.individually_accessible_str == "") ? 0 : reg_attrs.individually_accessible_str.atoi();
  
  // Convert size to width
  reg_attrs.width = reg_attrs.size.atoi();
  
  // Map access string to UVM access
  if (reg_attrs.access == "read-only" || reg_attrs.access == "RO") reg_attrs.acc = "RO";
  else if (reg_attrs.access == "write-only" || reg_attrs.access == "WO") reg_attrs.acc = "WO";
  else reg_attrs.acc = "RW";
  
  return reg_attrs;
endfunction

/*
Function: configure_register
Configures register with all fields from database
*/
function svdb_dynamic_reg svdb_dynamic_reg::configure_register(string reg_name);
  int row_id;
  register_attributes_t reg_attrs;
  register_fields_t fields_struct;
  int f;
  string acc_f;
  bit [31:0] reset_val_f;
  uvm_reg_field field;
  logic [31:0] address;
  
  if (SqliteDB == null) begin
    `uvm_error("RegModel", "Database not open")
    return null;
  end
  
  // Get register row ID
  row_id = sqlite_dpi_get_rowid_by_column_value(SqliteDB, "registers", "name", reg_name);
  if (row_id <= 0) begin
    `uvm_error("RegModel", $sformatf("Register '%s' not found in database", reg_name))
    return null;
  end
  
  // Retrieve register attributes using struct
  reg_attrs = get_register_attributes(reg_name);
  
  if (reg_attrs.addressOffset == "" || reg_attrs.size == "" || reg_attrs.access == "" || reg_attrs.resetValue == "") begin
    `uvm_error("RegModel", $sformatf("Invalid register attributes for '%s'", reg_name))
    return null;
  end
  
  // Remove any existing fields
  delete_fields();
  
  // Retrieve all fields for this register from DB using struct
  fields_struct = get_fields_for_register(row_id);
  
  // For each field, create and configure
  for (f = 0; f < fields_struct.num_fields; f++) begin
    if (fields_struct.fields[f].access == "read-only" || fields_struct.fields[f].access == "RO") acc_f = "RO";
    else if (fields_struct.fields[f].access == "write-only" || fields_struct.fields[f].access == "WO") acc_f = "WO";
    else acc_f = "RW";
    reset_val_f = str_to_hex(fields_struct.fields[f].resetValue);
    field = uvm_reg_field::type_id::create(fields_struct.fields[f].name,,get_full_name());
    field.configure(
      .parent(this),
      .size(fields_struct.fields[f].bitWidth),
      .lsb_pos(fields_struct.fields[f].bitOffset),
      .access(acc_f),
      .volatile(fields_struct.fields[f].volatile_val),
      .reset(reset_val_f),
      .has_reset(fields_struct.fields[f].has_reset_val),
      .is_rand(fields_struct.fields[f].is_random),
      .individually_accessible(fields_struct.fields[f].individually_accessible)
    );
  end
  
  set_svdb_name(reg_name);
  reset();
  
  return this;
endfunction

/*
Function: print_fields_for_register
Function to print all fields of this register instance
*/
function void svdb_dynamic_reg::print_fields_for_register();
  uvm_reg_field field;
  /*
  foreach (m_fields[i]) begin
    field = m_fields[i];
    $display("Field: %s, Offset: %0d, Width: %0d, Access: %s, Reset: %0h, Individually Accessible: %0d, Rand: %0d, Mirror: %0d, Volatile: %0d, Has Reset: %0d",
      field.get_name(),
      field.get_lsb_pos(),
      field.get_n_bits(),
      field.get_access(),
      field.get_reset(),
      field.is_individually_accessible(),
      field.is_rand(),
      field.get_mirrored(),
      field.is_volatile(),
      field.has_reset()
    );
  end
  */
endfunction

`endif // SVDB_DYNAMIC_REG_SV

