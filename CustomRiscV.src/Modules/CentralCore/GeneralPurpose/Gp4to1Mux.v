/**
    This module implements a general-purpose 4:1 multiplexer with a
        configurable input/output width.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param WIDTH defines the width of the inputs and outputs except select

    @param {WIDTH} a: first input into the multiplexer
    @param {WIDTH} b: second input into the multiplexer
    @param {WIDTH} c: third input into the multiplexer
    @param {WIDTH} d: fourth input into the multiplexer
    @param {2} select: select input into the multiplexer
    @param {WIDTH} out: output of the multiplexer
*/
module Gp4to1Mux #(
    parameter WIDTH = 64
) (
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,
    input [WIDTH - 1:0] c,
    input [WIDTH - 1:0] d,
    input [1:0] select,

    output reg [WIDTH - 1:0] out
);

    always @(*) begin
        case(select)
            2'h0: out = a;
            2'h1: out = b;
            2'h2: out = c;
            2'h3: out = d;
            default: out = {WIDTH{1'bX}}; 
        endcase
    end

endmodule
