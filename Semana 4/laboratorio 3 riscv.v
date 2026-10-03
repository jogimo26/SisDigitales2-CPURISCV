module riscv (
    input clk,
    input rst,
    input [31:0] instr,

    // Conexion con IMEM
    output wire [31:0] iaddr,

    // Conexion con DMEM
    output wire [31:0] daddr,
    input wire [31:0] ddata_in,
    output wire [31:0] ddata_out,
    output wire dwr_en,
    output wire drd_en
);

// 1. CONTADOR DE PROGRAMA
// 

reg [31:0] PC;

// Direccion hacia la memoria de instrucciones
assign iaddr = PC;


// 2. CONTROL DE CICLOS

reg state_fetch;
reg state_decode;
reg state_execute;

// Contador en anillo de tres estados
always @(negedge clk) begin
    if (rst) begin
        state_fetch   <= 1'b1;
        state_decode  <= 1'b0;
        state_execute <= 1'b0;
    end
    else begin
        state_fetch   <= state_execute;
        state_decode  <= state_fetch;
        state_execute <= state_decode;
    end
end


// 3. REGISTRO DE INSTRUCCION
// 

reg [31:0] IR;

always @(posedge clk) begin
    if (rst)
        IR <= 32'd0;
    else if (state_fetch)
        IR <= instr;
end


// 4. CAMPOS DE LA INSTRUCCION

wire [6:0] funct7;
wire [4:0] rs2;
wire [4:0] rs1;
wire [2:0] funct3;
wire [4:0] rd;
wire [6:0] opcode;

assign funct7 = IR[31:25];
assign rs2    = IR[24:20];
assign rs1    = IR[19:15];
assign funct3 = IR[14:12];
assign rd     = IR[11:7];
assign opcode = IR[6:0];


// 5. REGISTER FILE Y ALU

wire [31:0] src1_value;
wire [31:0] src2_value;

wire [31:0] alu_a;
wire [31:0] alu_b;
wire [31:0] alu_out;

wire [3:0] alu_op;
wire wr_en;

 
// 6. SEÑALES DE DECODIFICACION


wire [10:0] dec_bits;
wire [9:0] dec_bits2;

// Instrucciones tipo R
wire is_add;
wire is_sub;
wire is_sll;
wire is_slt;
wire is_sltu;
wire is_xor;
wire is_srl;
wire is_sra;
wire is_or;
wire is_and;

// Instrucciones tipo I aritmeticas
wire is_addi;
wire is_xori;
wire is_ori;
wire is_andi;

// Instrucciones tipo B
wire is_beq;
wire is_bne;
wire is_blt;
wire is_bge;
wire is_bltu;
wire is_bgeu;

// Tipos de instrucciones
wire is_valid;
wire is_u_instr;
wire is_j_instr;
wire is_b_instr;
wire is_s_instr;
wire is_r_instr;
wire is_i_instr;

// Inmediato
wire [31:0] imm;
wire imm_valid;

// 7. INSTANCIA DEL REGISTER FILE


register_file rf (
    .clk(clk),
    .wr_en(wr_en),
    .wr_index(rd),
    .wr_data(alu_out),
    .rd_index1(rs1),
    .rd_data1(src1_value),
    .rd_index2(rs2),
    .rd_data2(src2_value)
);


// 
// 8. INSTANCIA DE LA ALU

alu rv_alu (
    .a(alu_a),
    .b(alu_b),
    .ALU_out(alu_out),
    .op(alu_op)
);


// 9. CONEXION REGISTER FILE - ALU
// 

assign alu_a = src1_value;

// MUX para seleccionar registro o inmediato
assign alu_b = imm_valid ? imm : src2_value;


// 10. UNIDAD DE CONTROL

assign is_valid = (opcode[1:0] == 2'b11);


// 
// 11. DETECCION DE FORMATOS

// Tipo U
assign is_u_instr =
    (opcode[6:2] == 5'b00101) ||
    (opcode[6:2] == 5'b01101);

// Tipo J
assign is_j_instr =
    (opcode[6:2] == 5'b11011);

// Tipo B
assign is_b_instr =
    (opcode[6:2] == 5'b11000);

// Tipo S
assign is_s_instr =
    (opcode[6:2] == 5'b01000) ||
    (opcode[6:2] == 5'b01001);

// Tipo R
assign is_r_instr =
    (opcode[6:2] == 5'b01011) ||
    (opcode[6:2] == 5'b01100) ||
    (opcode[6:2] == 5'b01110) ||
    (opcode[6:2] == 5'b10100);

// Tipo I
assign is_i_instr =
    (opcode[6:2] == 5'b00000) ||
    (opcode[6:2] == 5'b00001) ||
    (opcode[6:2] == 5'b00100) ||
    (opcode[6:2] == 5'b00110) ||
    (opcode[6:2] == 5'b11001) ||
    (opcode[6:2] == 5'b11100);


// 12. DECODIFICACION DE INSTRUCCIONES BRANCH

assign is_beq =
    is_b_instr && (funct3 == 3'b000);

assign is_bne =
    is_b_instr && (funct3 == 3'b001);

assign is_blt =
    is_b_instr && (funct3 == 3'b100);

assign is_bge =
    is_b_instr && (funct3 == 3'b101);

assign is_bltu =
    is_b_instr && (funct3 == 3'b110);

assign is_bgeu =
    is_b_instr && (funct3 == 3'b111);



// 13. GENERADOR DE INMEDIATOS

assign imm =

    // Tipo I
    is_i_instr ?
    {
        {20{IR[31]}},
        IR[31:20]
    } :

    // Tipo S
    is_s_instr ?
    {
        {20{IR[31]}},
        IR[31:25],
        IR[11:7]
    } :

    // Tipo B
    is_b_instr ?
    {
        {19{IR[31]}},
        IR[31],
        IR[7],
        IR[30:25],
        IR[11:8],
        1'b0
    } :

    // Tipo U
    is_u_instr ?
    {
        IR[31:12],
        12'b0
    } :

    // Tipo J
    is_j_instr ?
    {
        {11{IR[31]}},
        IR[31],
        IR[19:12],
        IR[20],
        IR[30:21],
        1'b0
    } :

    32'b0;


// 
// 14. VALIDEZ DEL INMEDIATO
// 

assign imm_valid =
    is_i_instr |
    is_s_instr |
    is_b_instr |
    is_u_instr |
    is_j_instr;


// 
// 15. WRITE ENABLE DEL REGISTER FILE
// REQUERIMIENTO E

// Solo escribe durante EXECUTE
assign wr_en =
    state_execute &
    (
        is_r_instr |
        is_i_instr |
        is_u_instr |
        is_j_instr
    );


// 16. DECODIFICACION TIPO R

assign dec_bits = {
    funct7[5],
    funct3,
    opcode
};

assign is_add =
    (dec_bits == 11'b0_000_0110011);

assign is_sub =
    (dec_bits == 11'b1_000_0110011);

assign is_sll =
    (dec_bits == 11'b0_001_0110011);

assign is_slt =
    (dec_bits == 11'b0_010_0110011);

assign is_sltu =
    (dec_bits == 11'b0_011_0110011);

assign is_xor =
    (dec_bits == 11'b0_100_0110011);

assign is_srl =
    (dec_bits == 11'b0_101_0110011);

assign is_sra =
    (dec_bits == 11'b1_101_0110011);

assign is_or =
    (dec_bits == 11'b0_110_0110011);

assign is_and =
    (dec_bits == 11'b0_111_0110011);


// 17. DECODIFICACION TIPO I ARITMETICA
// 

assign dec_bits2 = {
    funct3,
    opcode
};

assign is_addi =
    (dec_bits2 == 10'b000_0010011);

assign is_xori =
    (dec_bits2 == 10'b100_0010011);

assign is_ori =
    (dec_bits2 == 10'b110_0010011);

assign is_andi =
    (dec_bits2 == 10'b111_0010011);


// 
// 18. CONTROL DE LA ALU
// 

assign alu_op =

    is_addi ? 4'b0000 :

    is_xori ? 4'b0100 :

    is_ori  ? 4'b0110 :

    is_andi ? 4'b0111 :

    // Instrucciones tipo R
    {funct7[5], funct3};


// 
// 19. INTERFAZ CON DMEM
// Temporalmente deshabilitada
// 

assign daddr     = 32'b0;
assign ddata_out = 32'b0;
assign dwr_en    = 1'b0;
assign drd_en    = 1'b0;


// 20. REQUERIMIENTO F: LOGICA DEL PC

// Senales de control del contador de programa
wire taken_br;
wire [31:0] br_tgt_pc;
wire [31:0] pc4;
wire [31:0] next_pc;


// 20.1 COMPARADOR DE SALTOS CONDICIONALES

assign taken_br =

    // BEQ: iguales
    is_beq ? (src1_value == src2_value) :

    // BNE: diferentes
    is_bne ? (src1_value != src2_value) :

    // BLT: menor con signo
    is_blt ?
        ($signed(src1_value) < $signed(src2_value)) :

    // BGE: mayor o igual con signo
    is_bge ?
        ($signed(src1_value) >= $signed(src2_value)) :

    // BLTU: menor sin signo
    is_bltu ? (src1_value < src2_value) :

    // BGEU: mayor o igual sin signo
    is_bgeu ? (src1_value >= src2_value) :

    // No hay salto condicional
    1'b0;


// 20.2 SUMADORES DEL PC

// Direccion destino del salto
assign br_tgt_pc = PC + imm;

// Siguiente instruccion secuencial
assign pc4 = PC + 32'd4;


// 20.3 MULTIPLEXOR DEL PC

// Salto condicional verdadero o JAL:
// next_pc = PC + imm
//
// En otro caso:
// next_pc = PC + 4

assign next_pc =
    (taken_br || is_j_instr) ? br_tgt_pc : pc4;


// 20.4 ACTUALIZACION DEL REGISTRO PC

// Reset sincronico y actualizacion solo durante EXECUTE

always @(posedge clk) begin

    if (rst)
        PC <= 32'd0;

    else if (state_execute)
        PC <= next_pc;

end

endmodule
