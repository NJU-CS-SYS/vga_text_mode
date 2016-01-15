`timescale 1ns / 1ps

// This module interacts with vga_view

module vga_ctrl(
    input clk,
    input reset,
    output vga_hs,
    output vga_vs,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b
    );

    parameter h_disp = 1280;

    wire pixel_clk;

    pixel_clock_gen pixel_clock(
        .clk_in1  ( clk ),
        .clk_out1 ( pixel_clk )
    );

    wire [31:0] x_pos, y_pos;  // coordination in print area
    wire disp;                 // is in print area

    vga_view view(
        .clk    ( pixel_clk ),
        .reset  ( reset ),
        .disp   ( disp ),
        .x_pos  ( x_pos ),
        .y_pos  ( y_pos ),
        .vga_hs ( vga_hs ),
        .vga_vs ( vga_vs )
    );

    wire [9:0] font_bitmap_line_addr;
    wire [7:0] font_bitmap_line;

    font_mem font(
        .addra ( font_bitmap_line_addr ),
        .dina  ( 0 ),
        .douta ( font_bitmap_line ),
        .clka  ( pixel_clk ),
        .ena   ( 1 ),
        .wea   ( 0 )
    );

    reg [31:0] char_addr;
    wire [7:0] text_char;

    text_mem text(
        .addra ( char_addr ),
        .dina  ( 0 ),
        .douta ( text_char ),
        .clka  ( pixel_clk ),
        .ena   ( 1 ),
        .wea   ( 0 )
    );

    reg [7:0] curr_font_bitmap_line;
    assign font_bitmap_line_addr = { text_char[6:0], y_pos[2:0] };

    wire pixel = curr_font_bitmap_line[ x_pos[2:0] ];

    assign vga_r = (disp && pixel) ? 4'hf : 4'h0;
    assign vga_g = (disp && pixel) ? 4'hf : 4'h0;
    assign vga_b = (disp && pixel) ? 4'hf : 4'h0;

    // State machine to prepare font bitmap
    always @(posedge pixel_clk) begin
        if (!disp) begin
            // Not in print area, always get the first char.
            // The time is enough for the signal to be prepared.
            // y_pos is prepared before x_pos is prepared, so it is ok.
            char_addr <= y_pos[31:3] * h_disp;
            curr_font_bitmap_line <= font_bitmap_line;
        end
        else if (x_pos[2:0] == 3'b000) begin
            // When print current char, we can previously fetch the next char's font
            // by updating the address.
            char_addr <= char_addr + 1;
        end
        else if (x_pos[2:0] == 3'b111) begin
            // At the end, update the font so that the next clock
            // we can print the correct pixels.
            curr_font_bitmap_line <= font_bitmap_line;
        end
    end

endmodule
