/*
 * File: regbus_if.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: SystemVerilog interface for REGBUS protocol implementation
 */

`ifndef REGBUS_IF_SV
`define REGBUS_IF_SV
`timescale 1ns/1ps

/*
Interface: regbus_if
SystemVerilog interface for REGBUS protocol implementation

This interface defines the signals and methods for the REGBUS protocol, which is
APB-like (Advanced Peripheral Bus-like). It provides modports for both DUT and
testbench connections, and includes a transaction task for UVM driver usage.

The REGBUS protocol follows the APB protocol structure with peripheral select,
enable, and handshake signals for reliable register access.

Parameters:
  clk - Clock signal for the interface
  rst_n - Active-low reset signal
*/
interface regbus_if(input bit clk, input bit rst_n);
  logic        psel;    // Peripheral select signal
  logic        penable; // Peripheral enable signal
  logic        pwrite;  // Write/read control signal
  logic [31:0] paddr;   // Address bus
  logic [31:0] pwdata;  // Write data bus
  logic        pready;  // Peripheral ready signal
  logic [31:0] prdata;  // Read data bus
  logic        pslverr; // Slave error signal

  import icecream_pkg::*;

  /*
  Modport: DUT
  Modport for DUT (Device Under Test) connection

  This modport defines the signal directions for connecting to the DUT side
  of the REGBUS interface.
  */
  modport DUT (
    input  clk, rst_n,
    input  psel, penable, pwrite, paddr, pwdata,
    output pready, prdata, pslverr
  );

  /*
  Modport: TB
  Modport for testbench connection

  This modport defines the signal directions for connecting to the testbench side
  of the REGBUS interface.
  */
  modport TB (
    input  clk, rst_n, pready, prdata, pslverr,
    output psel, penable, pwrite, paddr, pwdata
  );

  /*
  Task: do_regbus_transfer
  Performs a complete REGBUS transaction

  This task implements the REGBUS protocol handshake for both read and write
  operations. It handles the proper timing and signal sequencing required by
  the REGBUS protocol.

  Parameters:
    is_write - Flag indicating write (1) or read (0) operation
    addr - Address for the transaction
    data - Data for write operations or returned data for read operations
    response_err - Error flag returned from the transaction
  */
  task automatic do_regbus_transfer(
    input  bit        is_write,
    input  logic[31:0] addr,
    inout  logic[31:0] data,
    output bit        response_err
  );
    psel    <= 1;
    pwrite  <= is_write;
    paddr   <= addr;
    pwdata  <= is_write ? data : '0;
    penable <= 0;
    @(posedge clk);
    penable <= 1;
    // Wait for pready to be asserted
    do @(posedge clk); while (!pready);
    // Add a clock to allow prdata to become valid
    @(posedge clk);
    response_err = pslverr;
    if (!is_write) begin
      data = prdata;
    end
    psel    <= 0;
    penable <= 0;
  endtask
endinterface

`endif // REGBUS_IF_SV
