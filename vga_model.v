`timescale 1ns / 1ps

// This module handles text buffer's reading and writing

module vga_model #(parameter h_disp = 1280,
                             v_disp = 1024,
                   localparam x_limit = h_disp / 8,
                              y_limit = v_disp / 8,
                              addr_width = $clog2(x_limit * y_limit)) (
    input clk,
    input reset,
    input mov_up,
    input mov_down,
    input mov_left,
    input mov_right,
    input mov_return,
    input write_enable,
    input [7:0] char_write,
    input [addr_width - 1 : 0] addr_read,
    output [7:0] char_read
    );

    reg [x_limit - 1 : 0] x_pos;

    always @(posedge clk) begin: x_update_logic
        if (!reset) begin
            x_pos <= 0;
        end
        else if (mov_left && (x_pos >= 0)) begin
            x_pos <= x_pos - 1;
        end
        else if (mov_right && (x_pos < x_limit)) begin
            x_pos <= x_pos + 1;
        end
        else if (mov_return) begin
            x_pos <= 0;
        end
    end

    reg [y_limit - 1 : 0] y_pos;

    always @(posedge clk) begin: y_update_logic
        if (!reset) begin
            y_pos <= 0;
        end
        else if (mov_up && (y_pos >= 0)) begin
            y_pos <= y_pos - 1;
        end
        else if (mov_down && (y_pos < y_limit)) begin
            y_pos <= y_pos + 1;
        end
    end

    // Simple dual port BRAM
    // ena/enb is set to `always enable'

    wire [addr_width - 1 : 0] addr_write = x_pos + y_pos * x_limit;

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
