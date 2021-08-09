/**
    This modules implements the IF/ID pipeline register in our pipelined
        RV64 CPU. This is effectively just an array of D flip flops.
    @author BlackIsDevin (https://github.com/BlackIsDevin)

    @param pc input program counter from fetch stage
    @param inst input instruction from fetch stage
    @param clk input clock signal
    @param stall input signal for stalling the pipeline register
    @param dpc output program counter for decode stage
    @param dinst output instruction for decode stage
*/

module PipelineRegIFID (
    input [63:0] pc,
    input [31:0] inst,
    input clk,
    input stall,

    output reg [63:0] dpc,
    output reg [31:0] dinst
);

    always @(posedge clk) begin
        if (stall == 1'b0) begin
            dpc <= pc;
            dinst <= inst;
        end
    end

endmodule
