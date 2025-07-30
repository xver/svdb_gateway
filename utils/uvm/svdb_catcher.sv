/*
 * File: svdb_catcher.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: UVM report catcher for filtering SVDB dynamic register messages
 */

`ifndef SVDB_CATCHER_SV
`define SVDB_CATCHER_SV

/*
Class: svdb_catcher
UVM report catcher for filtering SVDB dynamic register messages

This class extends uvm_report_catcher to filter specific warning messages related
to SVDB dynamic register configuration. It helps suppress expected warnings that
occur during dynamic register model setup and configuration.

Inherits: uvm_report_catcher
*/
class svdb_catcher extends uvm_report_catcher;
 
  `uvm_object_utils(svdb_catcher)

  /*
  Function: new
  Constructor for the svdb_catcher class

  Parameter: name
  Name of the catcher instance
  */
  function new(string name = "svdb_catcher");
    super.new(name);
  endfunction
  // Portable substring search for SystemVerilog
  /*
  Function: contains_str
  Checks if a string contains a substring

  Parameter: s
  String to search in
  */
 virtual function bit contains_str(string s, string sub);
  int i;
  if (sub.len() == 0) return 1;
  for (i = 0; i <= s.len() - sub.len(); i++) begin
    if (s.substr(i, i+sub.len()-1) == sub)
      return 1;
  end
  return 0;
endfunction

  /*
  Function: catch
  Catches and handles warning messages
  */
  virtual function action_e catch();
    if ((get_severity() == UVM_WARNING) &&
        (get_id() == "RegModel") &&
        contains_str(get_message(), "dyn_config_reg")) begin
      // Suppress this warning
      return CAUGHT;
    end
    return THROW;
  endfunction
endclass: svdb_catcher

`endif // SVDB_CATCHER_SV
