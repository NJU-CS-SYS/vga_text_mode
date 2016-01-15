`timescale 1ns / 1ps

module vga_view(
    input clk,
    input reset,
    output disp,
    output [31:0] x_pos,
    output [31:0] y_pos,
    output vga_hs,
    output vga_vs
    );

    parameter h_sync = 112;
    parameter h_back = 248;
    parameter h_disp = 1280;
    parameter h_front = 48;

    parameter v_sync = 3;
    parameter v_back = 38;
    parameter v_disp = 1024;
    parameter v_front = 1;

    parameter h_limit = h_sync + h_back + h_disp + h_front;
    parameter v_limit = v_sync + v_back + v_disp + v_front;

    reg [31:0] x_cnt;
    reg [31:0] y_cnt;

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

    assign vga_hs = (x_cnt >= h_sync) ? 1'b1 : 1'b0;
    assign vga_vs = (y_cnt >= v_sync) ? 1'b1 : 1'b0;

    assign disp = (x_cnt >= (h_sync + h_back))
                    && (x_cnt < (h_sync + h_back + h_disp))
                    && (y_cnt >= (v_sync + v_back))
                    && (y_cnt < (v_sync + v_back + v_disp));

    assign x_pos = x_cnt - h_sync - h_back;
    assign y_pos = y_cnt - v_sync - v_back;

endmodule
