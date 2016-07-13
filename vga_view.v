`timescale 1ns / 1ps

module vga_view #(parameter h_sync  = 112,
                            h_back  = 248,
                            h_disp  = 1280,
                            h_front = 48,
                            v_sync  = 3,
                            v_back  = 38,
                            v_disp  = 1024,
                            v_front = 1,
                  localparam x_width = $clog2(h_disp),
                             y_width = $clog2(v_disp)) (
    input clk,
    input reset,
    output disp,
    output [x_width - 1 : 0] x_pos,
    output [y_width - 1 : 0] y_pos,
    output reg vga_hs,
    output reg vga_vs
    );

    localparam h_limit = h_sync + h_back + h_disp + h_front;
    localparam v_limit = v_sync + v_back + v_disp + v_front;
    localparam x_cnt_width = $clog2(h_limit);
    localparam y_cnt_width = $clog2(v_limit);

    reg [x_cnt_width - 1 : 0] x_cnt;
    reg [y_cnt_width - 1 : 0] y_cnt;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            x_cnt <= 0;
        end
        else if (x_cnt >= h_limit - 1) begin
            x_cnt <= 0;
        end
        else begin
            x_cnt <= x_cnt + 1;
        end
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            y_cnt <= 0;
        end
        else if (x_cnt >= h_limit - 1) begin
            if (y_cnt >= v_limit - 1) begin
                y_cnt <= 0;
            end
            else begin
                y_cnt <= y_cnt + 1;
            end
        end
    end

    // | sync | back porch | disp | front porch | sync ...

    always @(posedge clk) begin
        vga_hs <= (x_cnt >= h_sync) ? 1'b0 : 1'b1;
    end

    always @(posedge clk) begin
        vga_vs <= (y_cnt >= v_sync) ? 1'b0 : 1'b1;
    end

    assign disp = (x_cnt >= (h_sync + h_back))
                    && (x_cnt < (h_sync + h_back + h_disp))
                    && (y_cnt >= (v_sync + v_back))
                    && (y_cnt < (v_sync + v_back + v_disp));

    assign x_pos = x_cnt - h_sync - h_back;
    assign y_pos = y_cnt - v_sync - v_back;

endmodule
