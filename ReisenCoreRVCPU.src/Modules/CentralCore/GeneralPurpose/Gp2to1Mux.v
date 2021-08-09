/**
    This module implements a general-purpose 2:1 multiplexer with a
        configurable input/output width.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param WIDTH defines the width of the inputs and outputs except select

    @param a first input into the multiplexer
    @param b second input into the multiplexer
    @param out output of the multiplexer
*/
module Gp2to1Mux #(
    parameter WIDTH = 64
) (
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,
    input select,

    output reg [WIDTH - 1:0] out
);

    always @(*) begin
        case(select)
            1'b0: out = a;
            1'b1: out = b;
            default: out = {WIDTH{1'bX}}; 
        endcase
    end

endmodule
