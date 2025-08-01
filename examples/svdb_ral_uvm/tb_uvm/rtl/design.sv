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

Ports:
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
  
  /**
   * Parameter: BASE_ADDR
   *
   * Base address for the register block. This parameter defines the starting
   * address of the register block in the memory map. All register addresses
   * are calculated relative to this base address.
   *
   * Value: 32'h0000_0000
   * Type: logic [31:0]
   * Access: localparam
   *
   * Example:
   * > Register at offset 0x4 will be accessed at BASE_ADDR + 0x4 = 0x0000_0004
   */
  localparam logic [31:0] BASE_ADDR = 32'h0000_0000;
  
  /**
   * Parameter: RANGE
   *
   * Address range for the register block. This parameter defines the total
   * address space allocated to the register block. Used for address validation
   * to ensure accesses are within the valid range.
   *
   * Value: 32'h0000_1000 (4KB address space)
   * Type: logic [31:0]
   * Access: localparam
   *
   * Example:
   * > Valid addresses: BASE_ADDR to BASE_ADDR + RANGE - 1
   * > Address validation: (paddr >= BASE_ADDR) && (paddr < BASE_ADDR + RANGE)
   */
  localparam logic [31:0] RANGE     = 32'h0000_1000;

  /*
  Section: Register offset parameters
  Defines the address offsets for each register in the block
  */
  
  /**
   * Parameter: OFF_STATUS
   *
   * Address offset for the status register. This register is read-only and
   * contains system status information including the system_ready bit.
   *
   * Value: 32'h0
   * Type: logic [31:0]
   * Access: localparam
   * Register: status_register (read-only)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_STATUS = 0x0000_0000
   */
  localparam logic [31:0] OFF_STATUS   = 32'h0;
  
  /**
   * Parameter: OFF_CONTROL
   *
   * Address offset for the control register. This register is write-only and
   * contains control bits including the reset_system bit.
   *
   * Value: 32'h4
   * Type: logic [31:0]
   * Access: localparam
   * Register: control_register (write-only)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_CONTROL = 0x0000_0004
   */
  localparam logic [31:0] OFF_CONTROL  = 32'h4;
  
  /**
   * Parameter: OFF_CONFIG
   *
   * Address offset for the configuration register. This register is read/write
   * and contains configuration settings including the operation_mode field.
   *
   * Value: 32'h8
   * Type: logic [31:0]
   * Access: localparam
   * Register: configuration_register (read/write)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_CONFIG = 0x0000_0008
   */
  localparam logic [31:0] OFF_CONFIG   = 32'h8;
  
  /**
   * Parameter: OFF_SECURITY
   *
   * Address offset for the security register. This register is read/write-once
   * and contains security level settings. Can only be written once after reset.
   *
   * Value: 32'hC
   * Type: logic [31:0]
   * Access: localparam
   * Register: security_register (read/write-once)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_SECURITY = 0x0000_000C
   */
  localparam logic [31:0] OFF_SECURITY = 32'hC;
  
  /**
   * Parameter: OFF_FLAGS
   *
   * Address offset for the status flags register. This register is read-only
   * and contains various status flags and error indicators.
   *
   * Value: 32'h10
   * Type: logic [31:0]
   * Access: localparam
   * Register: status_flags (read-only, 8-bit)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_FLAGS = 0x0000_0010
   */
  localparam logic [31:0] OFF_FLAGS    = 32'h10;
  
  /**
   * Parameter: OFF_BITS
   *
   * Address offset for the control bits register. This register is read/write
   * and contains control bits for fine-grained control operations.
   *
   * Value: 32'h14
   * Type: logic [31:0]
   * Access: localparam
   * Register: control_bits (read/write, 4-bit)
   *
   * Example:
   * > Access address: BASE_ADDR + OFF_BITS = 0x0000_0014
   */
  localparam logic [31:0] OFF_BITS     = 32'h14;

  /*
  Section: Internal register storage
  Internal registers with different access types
  */
  
  /**
   * Variable: status_register
   *
   * Read-only status register containing system status information. This register
   * holds the system_ready bit and other status indicators. Can only be read
   * by the bus interface, writes are ignored and generate error responses.
   *
   * Size: 32 bits
   * Type: logic [31:0]
   * Access: Read-only
   * Reset Value: 32'h0000_0000 (system_ready=0)
   *
   * Example:
   * > Read operation: prdata = status_register
   * > Write operation: Generates pslverr = 1'b1
   */
  logic [31:0] status_register;        // read-only
  
  /**
   * Variable: control_register
   *
   * Write-only control register containing system control bits. This register
   * holds the reset_system bit and other control signals. Can only be written
   * by the bus interface, reads generate error responses.
   *
   * Size: 32 bits
   * Type: logic [31:0]
   * Access: Write-only
   * Reset Value: 32'h0000_0001 (reset_system=1)
   *
   * Example:
   * > Write operation: control_register <= pwdata
   * > Read operation: Generates pslverr = 1'b1
   */
  logic [31:0] control_register;       // write-only
  
  /**
   * Variable: configuration_register
   *
   * Read/write configuration register containing system configuration settings.
   * This register holds the operation_mode field and other configuration bits.
   * Supports both read and write operations through the bus interface.
   *
   * Size: 32 bits
   * Type: logic [31:0]
   * Access: Read/Write
   * Reset Value: 32'h0000_0002 (operation_mode=2)
   *
   * Example:
   * > Read operation: prdata = configuration_register
   * > Write operation: configuration_register <= pwdata
   */
  logic [31:0] configuration_register; // read/write
  
  /**
   * Variable: security_register
   *
   * Read/write-once security register containing security level settings.
   * This register can only be written once after reset. Subsequent write
   * attempts are ignored. Read operations always return the current value.
   *
   * Size: 32 bits
   * Type: logic [31:0]
   * Access: Read/Write-once
   * Reset Value: 32'h0000_0003 (security_level=3)
   *
   * Example:
   * > Read operation: prdata = security_register
   * > Write operation: Only allowed once after reset
   */
  logic [31:0] security_register;      // read/write-once
  
  /**
   * Variable: status_flags
   *
   * Read-only status flags register containing various status indicators and
   * error flags. This 8-bit register provides detailed status information
   * and is zero-extended to 32 bits when read.
   *
   * Size: 8 bits
   * Type: logic [7:0]
   * Access: Read-only
   * Reset Value: 8'h0A
   *
   * Example:
   * > Read operation: prdata = {24'h0, status_flags}
   * > Write operation: Generates pslverr = 1'b1
   */
  logic  [7:0] status_flags;           // read-only
  
  /**
   * Variable: control_bits
   *
   * Read/write control bits register containing fine-grained control signals.
   * This 4-bit register provides additional control capabilities and is
   * zero-extended to 32 bits when read.
   *
   * Size: 4 bits
   * Type: logic [3:0]
   * Access: Read/Write
   * Reset Value: 4'h7
   *
   * Example:
   * > Read operation: prdata = {28'h0, control_bits}
   * > Write operation: control_bits <= pwdata[3:0]
   */
  logic  [3:0] control_bits;           // read/write

  /**
   * Variable: security_written
   *
   * Flag to track if the security_register has been written once after reset.
   * This signal prevents multiple writes to the write-once security register.
   * Set to 1'b1 after the first write to security_register.
   *
   * Size: 1 bit
   * Type: logic
   * Access: Internal control signal
   * Reset Value: 1'b0
   *
   * Example:
   * > Check: if (!security_written) begin
   * > Set: security_written <= 1'b1
   */
  logic        security_written;

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
