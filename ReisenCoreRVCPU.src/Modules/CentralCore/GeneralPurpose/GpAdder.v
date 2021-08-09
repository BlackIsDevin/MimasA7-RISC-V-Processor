/**
    This module implements a general-purpose adder with configurable width.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param WIDTH defines the width of the inputs and outputs
    
    @param a first input for the addition
    @param b second input for the addition
    @param s output of the addition of a and b
*/
module GpAdder #(
    parameter WIDTH = 64
) (
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,

    output [WIDTH - 1:0] s
);

    assign s = a + b;

endmodule
