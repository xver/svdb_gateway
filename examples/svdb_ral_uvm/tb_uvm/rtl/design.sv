/*
 * File: design.sv
 *
 * Copyright (c) 2025 IC Verimeter. All rights reserved.
 *
 * Licensed under the MIT License.
 *
 * See LICENSE file in the project root for full license information.
 *
 * Description: Register block DUT implementing REGBUS protocol interface
 */

`ifndef DESIGN_SV
`define DESIGN_SV
`include "regbus_if.sv"

/*
Module: register_block_dut
Register block DUT implementing REGBUS protocol interface

This module implements a register block that responds to REGBUS protocol transactions.
The REGBUS interface is APB-like (Advanced Peripheral Bus-like) with peripheral
select, enable, and handshake signals. It contains various registers with different
access types (RO, WO, RW, RW1) and implements proper error handling for invalid
operations.

Parameters:
  pclk - Clock signal
  rst_n - Active-low reset signal
  paddr - Address bus
  psel - Peripheral select signal
  penable - Peripheral enable signal
  pwrite - Write/read control signal
  pwdata - Write data bus
  pready - Peripheral ready signal
  prdata - Read data bus
  pslverr - Slave error signal
*/
module register_block_dut (
  // REGBUS interface
  input  logic         pclk,
  input  logic         rst_n,
  input  logic [31:0]  paddr,
  input  logic         psel,
  input  logic         penable,
  input  logic         pwrite,
  input  logic [31:0]  pwdata,
  output logic         pready,
  output logic [31:0]  prdata,
  output logic         pslverr
);

import icecream_pkg::*;

  /*
  Section: Address and range parameters
  Defines the base address and address range for the register block
  */
  localparam logic [31:0] BASE_ADDR = 32'h0000_0000;
  localparam logic [31:0] RANGE     = 32'h0000_1000;

  /*
  Section: Register offset parameters
  Defines the address offsets for each register in the block
  */
  localparam logic [31:0] OFF_STATUS   = 32'h0;
  localparam logic [31:0] OFF_CONTROL  = 32'h4;
  localparam logic [31:0] OFF_CONFIG   = 32'h8;
  localparam logic [31:0] OFF_SECURITY = 32'hC;
  localparam logic [31:0] OFF_FLAGS    = 32'h10;
  localparam logic [31:0] OFF_BITS     = 32'h14;

  /*
  Section: Internal register storage
  Internal registers with different access types
  */
  logic [31:0] status_register;        // read-only
  logic [31:0] control_register;       // write-only
  logic [31:0] configuration_register; // read/write
  logic [31:0] security_register;      // read/write-once
  logic  [7:0] status_flags;           // read-only
  logic  [3:0] control_bits;           // read/write

  // Track if security_register has been written once
  logic        security_written;

  /*
  Always block: Reset and write logic
  Handles register reset and write operations

  This always block implements the reset logic and write operations for the
  registers. It handles different register access types and implements the
  write-once behavior for the security register.
  */
  always_ff @(posedge pclk or negedge rst_n) begin
    if (!rst_n) begin
      status_register        <= 32'h0000_0000;  // system_ready=0
      control_register       <= 32'h0000_0001;  // reset_system=1
      configuration_register <= 32'h0000_0002;  // operation_mode=2
      security_register      <= 32'h0000_0003;  // security_level=3
      status_flags           <= 8'h0A;          // 0xA
      control_bits           <= 4'h7;           // 0x7
      security_written       <= 1'b0;
    end else begin
      if (psel & penable & pwrite) begin
        unique case (paddr - BASE_ADDR)
          OFF_CONTROL: begin
            control_register <= pwdata;
          end
          OFF_CONFIG: begin
            configuration_register <= pwdata;
          end
          OFF_SECURITY: if (!security_written) begin
            security_register <= pwdata;
            security_written  <= 1'b1;
          end
          OFF_BITS: begin
            control_bits <= pwdata[3:0];
          end
          default: begin
            // no store for read-only or illegal addresses
          end
        endcase
      end
    end
  end

  /*
  Always block: Read logic and error handling
  Handles read operations and error generation

  This always block implements the read logic and error handling for the
  register block. It generates appropriate error signals for invalid
  operations and provides read data for valid operations.
  */
  always_comb begin
    pready   = 1'b1;
    prdata   = 32'h0000_0000;
    pslverr  = 1'b0;

    if (psel & penable) begin
      // Address out of block?
      if ((paddr < BASE_ADDR) || (paddr >= BASE_ADDR + RANGE)) begin
        pslverr = 1'b1;
      end else begin
        unique case (paddr - BASE_ADDR)
          OFF_STATUS: begin
            if (pwrite) pslverr = 1'b1;               // write to RO
            prdata = status_register;
          end
          OFF_CONTROL: begin
            if (!pwrite) pslverr = 1'b1;              // read from WO
          end
          OFF_CONFIG: begin
            prdata = configuration_register;
          end
          OFF_SECURITY: begin
            prdata = security_register;
          end
          OFF_FLAGS: begin
            if (pwrite) pslverr = 1'b1;              // write to RO
            prdata = {24'h0, status_flags};
          end
          OFF_BITS: begin
            prdata = {28'h0, control_bits};
          end
          default: begin
            pslverr = 1'b1;                          // no such register
          end
        endcase
      end
    end
  end

endmodule // register_block_dut

`endif // DESIGN_SV
