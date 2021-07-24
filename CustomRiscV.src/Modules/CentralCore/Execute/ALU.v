/**
    This module implements the ALU of our pipelined RV64 CPU.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} ea: 64-bit input of the first operand
    @param {64} eb: 64-bit input of the second operand
    @param {4} ealuc: 4-bit input indicating the ALU operation to perform

    @param {64} alur: 64-bit output of the result of the ALU operation
*/

module ALU (
    input signed [63:0] ea, eb,
    input [3:0] ealuc,

    output reg [63:0] alur
);

    // temporary register for storing the result of 32-bit ALU operation
    reg [31:0] alur_lower;
    
    // wires for operands of 32-bit ALU operations, make case statement simpler
    wire signed [31:0] ea_lower = ea[31:0];
    wire signed [31:0] eb_lower = eb[31:0];

    always @(*) begin
        case (ealuc)
            4'h0: alur = ea + eb;   // add
            4'h1: alur = ea - eb;   // sub
            4'h2: alur = ea & eb;   // and
            4'h3: alur = ea | eb;   // or
            4'h4: alur = ea ^ eb;   // xor
            4'h5: alur = ea << eb;  // sll
            4'h6: alur = ea >> eb;  // srl
            4'h7: alur = ea >>> eb; // sra
            
            4'h8: alur = $signed(ea_lower + eb_lower);   // 32-bit add
            4'h9: alur = $signed(ea_lower - eb_lower);   // 32-bit sub
            4'hA: alur = ea;                             // ea pass-through
            4'hB: alur = eb;                             // eb pass-through
            4'hC: alur = 64'hx;                          // undefined opcode
            4'hD: alur = $signed(ea_lower << eb_lower);  // 32-bit sll
            4'hE: alur = $signed(ea_lower >> eb_lower);  // 32-bit srl
            4'hF: alur = $signed(ea_lower >>> eb_lower); // 32-bit sra
        endcase
    end

endmodule