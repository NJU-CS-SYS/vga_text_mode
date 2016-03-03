`timescale 1ns / 1ps

// This module handles text buffer's reading and writing

module vga_model #(parameter addr_width = 31) (
    input clk,
    input [addr_width - 1 : 0] addr_read,
    output [7:0] char_read
    );

    text_mem text (
        .addra ( addr_read ),
        .dina  ( 0         ),
        .douta ( char_read ),
        .clka  ( clk       ),
        .ena   ( 1         ),
        .wea   ( 0         )
    );

endmodule
