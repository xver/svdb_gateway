/*
 * File: env.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: 
 *  - UVM environment for REGBUS protocol with register model integration
 */

`ifndef ENV_SV
`define ENV_SV

/*
Class: env
UVM environment for REGBUS protocol with register model integration

This environment encapsulates the REGBUS agent, register models, and adapter
components. It provides the complete testbench infrastructure for REGBUS protocol
testing with both traditional and SVDB-based register models.

Inherits: uvm_env
*/
class env extends uvm_env;

  /*
  Variable: agent
  REGBUS agent instance

  This variable holds the REGBUS agent that provides the complete interface
  for generating and monitoring REGBUS transactions.
  */
  regbus_agent agent;

  /*
  Variable: ap
  Analysis port for REGBUS sequence items

  This variable provides an analysis port that broadcasts REGBUS sequence items
  collected by the monitor to other components for analysis and checking.
  */
  uvm_analysis_port#(regbus_seq_item) ap;

  /*
  Variable: regmodel
  Traditional register block instance

  This variable holds the traditional UVM register block that provides
  static register model functionality.
  */
  register_block regmodel;

  /*
  Variable: reg2regbus
  REGBUS to register adapter instance

  This variable holds the adapter that converts between UVM register operations
  and REGBUS protocol transactions.
  */
  regbus2reg_adapter reg2regbus;

  /*
  Variable: regmodel_svdb
  SVDB-based register block instance

  This variable holds the SVDB-based register block that provides dynamic
  register model functionality using database integration.
  */
  svdb_reg_block regmodel_svdb;

  `uvm_component_utils(env)

  /*
  Function: new
  Constructor for the UVM environment

  Parameters:
    name - Name of the environment instance
    parent - Parent component in the UVM hierarchy
  */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  /*
  Function: build_phase
  Builds the environment components during the UVM build phase

  This function creates the REGBUS agent, register models, and adapter components.
  It also configures the register models in the configuration database for global
  access by sequences.

  Parameter:
    phase - Current UVM phase
  */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = regbus_agent::type_id::create("agent", this);
    ap    = new("ap", this);
   
    regmodel = register_block::type_id::create("regmodel", this);
    regmodel_svdb = svdb_reg_block::type_id::create("regmodel_svdb", this);

    regmodel.build();
    regmodel_svdb.build();

    regmodel.lock_model();
    regmodel_svdb.lock_model();

    // Set regmodel in config DB for global access by sequences
    uvm_config_db#(uvm_reg_block)::set(null, "", "register_block", regmodel);
    uvm_config_db#(svdb_reg_block)::set(null, "", "register_block_svdb", regmodel_svdb);
    reg2regbus = regbus2reg_adapter::type_id::create("reg2regbus", this);

  endfunction

  /*
  Function: connect_phase
  Connects the environment components during the UVM connect phase

  This function connects the monitor's analysis port to the environment's analysis
  port and sets up the register model sequencer connections with the REGBUS adapter.

  Parameter:
    phase - Current UVM phase
  */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.item_collected_port.connect(ap);
    // Connect the register model to the REGBUS adapter
    regmodel.default_map.set_sequencer(agent.seq, reg2regbus);
    regmodel_svdb.default_map.set_sequencer(agent.seq, reg2regbus);

  endfunction
endclass

`endif // ENV_SV
