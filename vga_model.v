`timescale 1ns / 1ps

// This module handles text buffer's reading and writing

module vga_model #(parameter h_disp = 1280,
                             v_disp = 1024,
                   localparam x_limit = h_disp / 8,
                              y_limit = v_disp / 8,
                              addr_limit = x_limit * y_limit,
                              addr_width = $clog2(addr_limit)) (
    input clk,
    input [addr_width - 1 : 0] addr_init,
    input [addr_width - 1 : 0] addr_write,
    input write_enable,
    input [7:0] char_write,
    input [addr_width - 1 : 0] addr_read,
    output [7:0] char_read
    );

    // We don't need round read, as it
    // has been done by controller.
    wire [addr_width - 1 : 0] wr_addr;

    Rounder #( addr_width ) rnd_for_wr (
        .in    ( addr_write ),
        .start ( addr_init  ),
        .limit ( addr_limit ),
        .out   ( wr_addr    )
    );

    // Simple dual port BRAM
    // ena/enb is set to `always enable'
    text_mem text (
        // Write
        .clka  ( clk          ),
        .addra ( wr_addr      ),
        .dina  ( char_write   ),
        .wea   ( write_enable ),
        // Read
        .clkb  ( clk          ),
        .addrb ( addr_read    ),
        .doutb ( char_read    )
    );

endmodule
