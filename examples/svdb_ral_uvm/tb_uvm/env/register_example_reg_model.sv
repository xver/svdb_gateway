`ifndef REGISTER_EXAMPLE_REG_MODEL_SV
`define REGISTER_EXAMPLE_REG_MODEL_SV
// register_example_reg_model.sv

// Dynamically reconfigurable register
class dynamic_config_reg extends svdb_dynamic_reg;
  `uvm_object_utils(dynamic_config_reg)
  
   function new(string name = "svdb_dynamic_reg", int unsigned n_bits = 32, int has_coverage = UVM_NO_COVERAGE);
    super.new(name, n_bits, has_coverage);
  endfunction
   
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

class status_register_reg extends uvm_reg;
  `uvm_object_utils(status_register_reg)
  rand uvm_reg_field system_ready;

  function new(string name = "status_register_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    system_ready = uvm_reg_field::type_id::create("system_ready",,get_full_name());
    system_ready.configure(.parent(this), .size(1), .lsb_pos(0), .access("RO"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
  endfunction
endclass

class control_register_reg extends uvm_reg;
  `uvm_object_utils(control_register_reg)
  rand uvm_reg_field reset_system;

  function new(string name = "control_register_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    reset_system = uvm_reg_field::type_id::create("reset_system",,get_full_name());
    reset_system.configure(.parent(this), .size(1), .lsb_pos(0), .access("WO"), .volatile(0), .reset(1'h1), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
  endfunction
endclass

class configuration_register_reg extends uvm_reg;
  `uvm_object_utils(configuration_register_reg)
  rand uvm_reg_field operation_mode;

  function new(string name = "configuration_register_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    operation_mode = uvm_reg_field::type_id::create("operation_mode",,get_full_name());
    operation_mode.configure(.parent(this), .size(2), .lsb_pos(0), .access("RW"), .volatile(0), .reset(2'h2), .has_reset(2'h3), .is_rand(0), .individually_accessible(0));
  endfunction
endclass

class security_register_reg extends uvm_reg;
  `uvm_object_utils(security_register_reg)
  rand uvm_reg_field security_level;

  function new(string name = "security_register_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    security_level = uvm_reg_field::type_id::create("security_level",,get_full_name());
    security_level.configure(.parent(this), .size(2), .lsb_pos(0), .access("RW"), .volatile(0), .reset(2'h3), .has_reset(2'h3), .is_rand(0), .individually_accessible(0));
  endfunction
endclass

class status_flags_reg extends uvm_reg;
  `uvm_object_utils(status_flags_reg)
  rand uvm_reg_field overflow_flag;
  rand uvm_reg_field underflow_flag;
  rand uvm_reg_field parity_error;
  rand uvm_reg_field timeout_error;
  rand uvm_reg_field reserved_flags;

  function new(string name = "status_flags_reg");
    super.new(name, 8, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    overflow_flag   = uvm_reg_field::type_id::create("overflow_flag",,get_full_name());
    underflow_flag  = uvm_reg_field::type_id::create("underflow_flag",,get_full_name());
    parity_error    = uvm_reg_field::type_id::create("parity_error",,get_full_name());
    timeout_error   = uvm_reg_field::type_id::create("timeout_error",,get_full_name());
    reserved_flags  = uvm_reg_field::type_id::create("reserved_flags",,get_full_name());

    overflow_flag.configure(.parent(this), .size(1), .lsb_pos(0), .access("RO"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    underflow_flag.configure(.parent(this), .size(1), .lsb_pos(1), .access("RO"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    parity_error.configure(.parent(this), .size(1), .lsb_pos(2), .access("RO"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    timeout_error.configure(.parent(this), .size(1), .lsb_pos(3), .access("RO"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    reserved_flags.configure(.parent(this), .size(4), .lsb_pos(4), .access("RO"), .volatile(0), .reset(4'h0), .has_reset(4'hF), .is_rand(0), .individually_accessible(0));
  endfunction
endclass

class control_bits_reg extends uvm_reg;
  `uvm_object_utils(control_bits_reg)
  rand uvm_reg_field feature_enable;
  rand uvm_reg_field system_reset;
  rand uvm_reg_field configuration_lock;
  rand uvm_reg_field mode_select;

  function new(string name = "control_bits_reg");
    super.new(name, 4, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    feature_enable      = uvm_reg_field::type_id::create("feature_enable",,get_full_name());
    system_reset        = uvm_reg_field::type_id::create("system_reset",,get_full_name());
    configuration_lock  = uvm_reg_field::type_id::create("configuration_lock",,get_full_name());
    mode_select         = uvm_reg_field::type_id::create("mode_select",,get_full_name());

    feature_enable.configure(.parent(this), .size(1), .lsb_pos(0), .access("RW"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    system_reset.configure(.parent(this), .size(1), .lsb_pos(1), .access("RW"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    configuration_lock.configure(.parent(this), .size(1), .lsb_pos(2), .access("RW"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
    mode_select.configure(.parent(this), .size(1), .lsb_pos(3), .access("RW"), .volatile(0), .reset(1'h0), .has_reset(1'h1), .is_rand(0), .individually_accessible(0));
  endfunction
endclass


class register_block extends uvm_reg_block;
  `uvm_object_utils(register_block)
  rand status_register_reg      status_register;
  rand control_register_reg     control_register;
  rand configuration_register_reg configuration_register;
  rand security_register_reg    security_register;
  rand status_flags_reg         status_flags;
  rand control_bits_reg         control_bits;

  rand dynamic_config_reg       dyn_config_reg;

  function new(string name = "register_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    status_register      = status_register_reg::type_id::create("status_register",,get_full_name());
    control_register     = control_register_reg::type_id::create("control_register",,get_full_name());
    configuration_register = configuration_register_reg::type_id::create("configuration_register",,get_full_name());
    security_register    = security_register_reg::type_id::create("security_register",,get_full_name());
    status_flags         = status_flags_reg::type_id::create("status_flags",,get_full_name());
    control_bits         = control_bits_reg::type_id::create("control_bits",,get_full_name());

    dyn_config_reg       = dynamic_config_reg::type_id::create("dyn_config_reg",,get_full_name());

    status_register.build();
    control_register.build();
    configuration_register.build();
    security_register.build();
    status_flags.build();
    control_bits.build();

    dyn_config_reg.build();

    // Register map
    status_register.configure(this, null, "status_register");
    control_register.configure(this, null, "control_register");
    configuration_register.configure(this, null, "configuration_register");
    security_register.configure(this, null, "security_register");
    status_flags.configure(this, null, "status_flags");
    control_bits.configure(this, null, "control_bits");

    dyn_config_reg.configure(this, null, "dyn_config_reg");

    // Add registers to block at correct offsets
    this.default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    default_map.add_reg(status_register,      'h0,  "RO");
    default_map.add_reg(control_register,     'h4,  "WO");
    default_map.add_reg(configuration_register, 'h8,  "RW");
    default_map.add_reg(security_register,    'hC,  "WO");
    default_map.add_reg(status_flags,         'h10, "RO");
    default_map.add_reg(control_bits,         'h14, "RW");
    default_map.add_reg(dyn_config_reg,       'h18, "RW");
  endfunction
endclass

`endif // REGISTER_EXAMPLE_REG_MODEL_SV
