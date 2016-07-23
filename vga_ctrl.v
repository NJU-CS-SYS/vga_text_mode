`timescale 1ns / 1ps

// This module interacts with vga_view

module vga_ctrl #(parameter h_disp = 1280,
                            v_disp = 1024,
                  localparam x_width = $clog2(h_disp),
                             y_width = $clog2(v_disp),
                             h_chars = h_disp / 8,
                             v_chars = v_disp / 8,
                             max_chars = h_chars * v_chars,
                             char_addr_width = $clog2(max_chars)) (
    // Global inputs
    input clk,
    input scroll,
    // Input from model: text data
    input [7:0] char_read,
    // Input from viewer: display status
    input disp,                     // is in disp area, high effective
    input [x_width - 1 : 0] x_pos,  // current pixel position.x, valid only if disp effective
    input [y_width - 1 : 0] y_pos,  // current pixel position.y, valid only if disp effective
    // Output to model: character address
    output reg [char_addr_width - 1 : 0] addr_read,
    output reg [char_addr_width - 1 : 0] addr_init,  // indicate the first line in screen
    // Output to pins
    output reg [3:0] vga_r,
    output reg [3:0] vga_g,
    output reg [3:0] vga_b
    );

    wire [9:0] font_bitmap_line_addr;
    wire [7:0] font_bitmap_line;

    // This block ram is set to always enable
    font_mem font (
        .addra ( font_bitmap_line_addr ),
        .dina  ( 0                     ),
        .douta ( font_bitmap_line      ),
        .clka  ( clk                   ),
        .wea   ( 0                     )
    );

    reg [7:0] curr_font_bitmap_line;

    assign font_bitmap_line_addr = { char_read[6:0], y_pos[2:0] };

    wire pixel = curr_font_bitmap_line[ x_pos[2:0] ];

    always @(posedge clk) begin
        vga_r <= (disp && pixel) ? 4'hf : 4'h0;
        vga_g <= (disp && pixel) ? 4'hf : 4'h0;
        vga_b <= (disp && pixel) ? 4'hf : 4'h0;
    end

    // Update top position.
    always @(posedge clk) begin
        if (scroll) begin
            if (addr_init >= max_chars - h_chars) begin
                addr_init <= 0;
            end
            else begin
                addr_init <= addr_init + h_chars;
            end
        end
    end

    wire [char_addr_width - 1 : 0] line_start;

    Rounder #( char_addr_width ) rnd (
        .in    ( y_pos[y_width - 1 : 3] * h_chars ),
        .start ( addr_init                        ),
        .limit ( max_chars                        ),
        .out   ( line_start                       )
    );

    // State machine to prepare font bitmap
    always @(posedge clk) begin
        if (!disp) begin
            // Not in print area, always get the first char.
            // The time is enough for the signal to be prepared.
            // y_pos is prepared before x_pos is prepared, so it is ok.
            addr_read <= line_start;
            curr_font_bitmap_line <= font_bitmap_line;
        end
        else if (x_pos[2:0] == 3'b000) begin
            // When print current char, we can previously fetch the next char's font
            // by updating the address.
            addr_read <= addr_read + 1;
        end
        else if (x_pos[2:0] == 3'b111) begin
            // At the end, update the font so that the next clock
            // we can print the correct pixels.
            curr_font_bitmap_line <= font_bitmap_line;
        end
    end

endmodule
