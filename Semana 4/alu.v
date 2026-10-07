module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  op,
    output reg [31:0] ALU_out
);

    // GUIA 4 - REQUERIMIENTO 3
    // Nuevas señales internas
    wire [4:0]  shamt;
    wire [63:0] a_ext;
    wire [31:0] sltu_result;
    wire [31:0] slt_result;

    // Valor del shift
    assign shamt = b[4:0];

    // Extension de signo de la entrada a para 64 bits
    assign a_ext = {{32{a[31]}}, a};

    // Valor obtenido por set if less than unsigned (SLTU)
    assign sltu_result = {31'b0, a < b};

    // Valor obtenido por set if less than signed (SLT)
    assign slt_result =
        (a[31] == b[31])
        ? sltu_result
        : {31'b0, a[31]};

    // ALU
    always @(*) begin
        case (op)
            4'b0000: ALU_out = a + b;          // ADD
            4'b1000: ALU_out = a - b;          // SUB
            4'b0001: ALU_out = a << shamt;     // SLL
            4'b0010: ALU_out = slt_result;     // SLT
            4'b0011: ALU_out = sltu_result;    // SLTU
            4'b0100: ALU_out = a ^ b;          // XOR
            4'b0101: ALU_out = a >> shamt;     // SRL
            4'b1101: ALU_out = a_ext >> shamt; // SRA
            4'b0110: ALU_out = a | b;          // OR
            4'b0111: ALU_out = a & b;          // AND

            default: ALU_out = 32'h00000000;
        endcase
    end

endmodule
