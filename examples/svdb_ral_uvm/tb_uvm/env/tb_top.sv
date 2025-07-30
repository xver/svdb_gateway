/*
 * File: tb_top.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Top-level testbench module for REGBUS protocol verification
 */

`ifndef TB_TOP_SV
`define TB_TOP_SV

/*
Module: tb_top
Top-level testbench module for REGBUS protocol verification

This module serves as the top-level testbench that instantiates the DUT, creates
the REGBUS interface (which is APB-like), generates clock and reset signals, and
initiates the UVM test. It provides the complete testbench infrastructure for
REGBUS protocol verification.
*/
module tb_top;
  
  bit clk = 0;
  bit rst_n;
  regbus_if dut_if(clk, rst_n);

  /*
  Instance: u_dut
  Device Under Test (DUT) instance

  This module instance represents the register block design that implements the
  REGBUS protocol interface. It connects to the REGBUS interface signals for
  verification.
  */
  register_block_dut  u_dut (
    .pclk   (clk),
    .rst_n  (rst_n),
    .paddr  (dut_if.paddr),
    .psel   (dut_if.psel),
    .penable(dut_if.penable),
    .pwrite (dut_if.pwrite),
    .pwdata (dut_if.pwdata),
    .pready (dut_if.pready),
    .prdata (dut_if.prdata),
    .pslverr(dut_if.pslverr)
  );
  

  /*
  Always block: Clock generation
  Generates a 100MHz clock signal (10ns period)

  This always block creates a continuous clock signal with a 50% duty cycle
  for the testbench and DUT.
  */
  always #5 clk = ~clk;

  /*
  Initial block: Reset generation
  Generates the reset signal sequence

  This initial block creates the reset sequence by asserting reset for 20ns
  and then deasserting it to start normal operation.
  */
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;

  end

  /*
  Initial block: UVM test initialization
  Initializes the UVM testbench and runs the test

  This initial block sets up the virtual interface binding in the configuration
  database and starts the UVM test execution.
  */
  initial begin
    // Wildcard virtual interface binding
    uvm_config_db#(virtual regbus_if)::set(null, "*", "vif", dut_if);
    // Invoke compile test explicitly
    //run_test("test_register_block_uvm_dynamic");
    run_test("test_register_block_sql_db");
  end
 

 /*
  initial begin
     $dumpfile("dump.vcd");
     $dumpvars();
  end
 */
 
 endmodule

`endif // TB_TOP_SV
