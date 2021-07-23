/**
    This module implements the ALU of our pipelined RV64 CPU.
    @author: BlackIsDevin (https://github.com/BlackIsDevin)

    @param {64} ea: 64-bit input of the first operand
    @param {64} eb: 64-bit input of the second operand
    @param {4} ealuc: 4-bit input indicating the ALU operation to perform

    @param {64} alur: 64-bit output of the result of the ALU operation
*/

module ALU (
    input [63:0] ea, eb,
    input [3:0] ealuc,

    output reg [63:0] alur
);

    // temporary register for storing the result of 32-bit ALU operation
    reg [31:0] alur_lower;

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
            
            4'h8: begin             // 32-bit add
                alur_lower = ea[31:0] + eb[31:0];
                alur = {{32{alur_lower[31]}}, alur_lower[31:0]};
            end
            4'h9: begin             // 32-bit sub
                alur_lower = ea[31:0] - eb[31:0];
                alur = {{32{alur_lower[31]}}, alur_lower[31:0]};
            end
            4'hA: alur = ea;        // ea pass-through
            4'hB: alur = eb;        // eb pass-through
            4'hC: alur = 64'hx;     // undefined behavior, reserved for future use
            4'hD: begin             // 32-bit sll
                alur_lower = ea[31:0] << eb[31:0];
                alur = {{32{alur_lower[31]}}, alur_lower[31:0]};
            end
            4'hE: begin             // 32-bit srl
                alur_lower = ea[31:0] >> eb[31:0];
                alur = {{32{alur_lower[31]}}, alur_lower[31:0]};
            end
            4'hF: begin             // 32-bit sra
                alur_lower = ea[31:0] >>> eb[31:0];
                alur = {{32{alur_lower[31]}}, alur_lower[31:0]};
            end
        endcase
    end

endmodule