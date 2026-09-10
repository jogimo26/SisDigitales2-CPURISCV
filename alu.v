module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  op,
    output reg [31:0] ALU_out
);

  always @(*) begin
    case (op)
      4'b0000: ALU_out = a + b;                  // ADD
      4'b1000: ALU_out = a - b;                  // SUB
      4'b0001: ALU_out = a << b[4:0];            // SLL
      4'b0010: ALU_out = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
      4'b0011: ALU_out = (a < b) ? 32'b1 : 32'b0; // SLTU
      4'b0100: ALU_out = a ^ b;                  // XOR
      4'b0101: ALU_out = a >> b[4:0];            // SRL
      4'b1101: ALU_out = $signed(a) >>> b[4:0];  // SRA
      4'b0110: ALU_out = a | b;                  // OR
      4'b0111: ALU_out = a & b;                  // AND
      default: ALU_out = 32'h00000000;
    endcase
  end

endmodule