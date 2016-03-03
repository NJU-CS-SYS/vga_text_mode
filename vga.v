`timescale 1ns / 1ps

// VGA top module

module vga(
    input CLK100MHZ,
    input RESET,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    );

    vga_ctrl ctrl(
        .clk    ( CLK100MHZ ),
        .reset  ( RESET ),
        .vga_r  ( VGA_R ),
        .vga_g  ( VGA_G ),
        .vga_b  ( VGA_B ),
        .vga_hs ( VGA_HS ),
        .vga_vs ( VGA_VS )
    );

endmodule
