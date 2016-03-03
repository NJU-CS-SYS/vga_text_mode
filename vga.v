`timescale 1ns / 1ps

// VGA top module

module vga (
    input CLK100MHZ,
    input RESET,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    );

    wire pixel_clk;

    pixel_clock_gen pixel_clock (
        .clk_in1  ( CLK100MHZ ),
        .clk_out1 ( pixel_clk )
    );

    wire [7:0] char_read;
    wire [31:0] addr_read;

    vga_model model (
        .clk ( pixel_clk ),
        .addr_read ( addr_read ),
        .char_read ( char_read )
    );

    wire disp;
    wire [31:0] x_pos;
    wire [31:0] y_pos;

    vga_view view (
        // Global input
        .clk    ( pixel_clk ),
        .reset  ( RESET     ),
        // Output to pins
        .vga_hs ( VGA_HS    ),
        .vga_vs ( VGA_VS    ),
        // Output to controller
        .disp   ( disp      ),
        .x_pos  ( x_pos     ),
        .y_pos  ( y_pos     )
    );

    vga_ctrl ctrl (
        // Global input
        .clk    ( pixel_clk    ),
        .reset  ( RESET        ),
        // Input from model
        .char_read ( char_read ),
        // Input from viewer
        .disp   ( disp         ),
        .x_pos  ( x_pos        ),
        .y_pos  ( y_pos        ),
        // Output to model
        .addr_read ( addr_read ),
        // Output to pins
        .vga_r  ( VGA_R        ),
        .vga_g  ( VGA_G        ),
        .vga_b  ( VGA_B        )
    );

endmodule
