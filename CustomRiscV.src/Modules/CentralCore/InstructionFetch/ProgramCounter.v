/**
    This modules implements a 64-bit wide program counter, which is
        effectively just a D flip flop array. 
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param nextPc input of next state of the program counter
    @param clk input clock signal
    @param stall input signal for stalling the program counter
    @param pc output current state of the program counter
*/
module ProgramCounter(
    input [63:0] nextPc,
    input clk,
    input stall, 
    
    output reg [63:0] pc
);

    initial pc = 64'h0;

    always @(posedge clk)
        if (stall == 0)
            pc <= nextPc;

endmodule
