`timescale 1ns / 1ps

// This module handles text buffer's reading and writing

module vga_model #(parameter h_disp = 1280,
                             v_disp = 1024,
                   localparam addr_width = $clog2(h_disp * v_disp / (8 * 8))) (
    input clk,
    input [addr_width - 1 : 0] addr_write,
    input [7:0] char_write,
    input write_enable,
    input [addr_width - 1 : 0] addr_read,
    output [7:0] char_read
    );

    // Simple dual port BRAM
    // ena/enb is set to `always enable'
    text_mem text (
        // Write
        .clka  ( clk          ),
        .addra ( addr_write   ),
        .dina  ( char_write   ),
        .wea   ( write_enable ),
        // Read
        .clkb  ( clk          ),
        .addrb ( addr_read    ),
        .doutb ( char_read    )
    );

endmodule
