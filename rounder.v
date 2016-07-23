`timescale 1ns / 1ps

module Rounder #(parameter width = 15)
(
    input      [width - 1 : 0] in,
    input      [width - 1 : 0] start,
    input      [width - 1 : 0] limit,  // Exclusive!
    output reg [width - 1 : 0] out
);

wire [width - 1 : 0] spare = limit - start;

always @(*) begin
    if (in < spare) begin
        out = start + in;
    end
    else begin
        out = in - spare;
    end
end

endmodule
