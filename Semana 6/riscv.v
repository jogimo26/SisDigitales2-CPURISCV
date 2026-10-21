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
// GUIA 6 - Registro para conservar PC+4
reg [31:0] pc_plus_4;

// Direccion hacia la memoria de instrucciones
assign iaddr = PC;


// 2. CONTROL DE CICLOS

reg state_fetch;
reg state_decode;
reg state_execute;
reg state_execute2;

// Contador en anillo de tres estados
always @(negedge clk) begin
    if (rst) begin
        state_fetch   <= 1'b1;
        state_decode  <= 1'b0;
        state_execute <= 1'b0;
        state_execute2 <= 1'b0;
    end
    else begin
        state_fetch   <= state_execute;
        state_decode  <= state_fetch;
        state_execute <= state_decode;
        state_execute2 <= state_execute;
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
// GUIA 6 - Guardar PC+4 durante FETCH
always @(posedge clk) begin
    if (rst)
        pc_plus_4 <= 32'd0;
    else if (state_fetch)
        pc_plus_4 <= PC + 32'd4;
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
// GUIA 5  Dato que se escribe en el Register File
wire [31:0] rf_wr_data;
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
wire is_lui;
wire is_auipc;

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


// GUIA 5 - Instrucciones LOAD
wire is_load;
// GUIA 6 - Instrucciones JAL / JALR
wire is_jal;
wire is_jalr;

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
    .wr_data(rf_wr_data),
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

// MUX de entrada A de la ALU
assign alu_a =
    is_lui   ? 32'b0 :
    is_auipc ? PC :
               src1_value;

// MUX para seleccionar registro o inmediato

assign alu_b = imm_valid ? imm : src2_value;

// GUIA 5 - MUX DE ESCRITURA AL REGISTER FILE
// LOAD -> dato proveniente de DMEM
// Otras instrucciones -> resultado de la ALU
// GUIA 6 - MUX DE ESCRITURA AL REGISTER FILE
// LOAD      -> dato proveniente de DMEM
// JAL/JALR  -> direccion de retorno PC+4
// Otros     -> resultado de la ALU

assign rf_wr_data =
    is_load               ? ddata_in  :
    (is_jal || is_jalr)   ? pc_plus_4 :
                             alu_out;

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

// GUIA 5 - DETECCION DE LOAD
assign is_load =
    (opcode == 7'b0000011);
    // GUIA 6 - DETECCION DE JAL
assign is_jal =
    (opcode == 7'b1101111);

// GUIA 6 - DETECCION DE JALR
assign is_jalr =
    (opcode == 7'b1100111) &&
    (funct3 == 3'b000);

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

// Solo escribe durante EXECUTE guia 5
assign wr_en =
    state_execute2 &
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

// GUIA 4 - REQUERIMIENTO 1
// DECODIFICACION DE SHIFTS Y COMPARACIONES

// SLL / SLLI
assign is_sll =
    (dec_bits == 11'b0_001_0110011)
    ||
    (
        (dec_bits2 == 10'b001_0010011) &&
        (funct7[5] == 1'b0)
    );


// SLT / SLTI
assign is_slt =
    (dec_bits == 11'b0_010_0110011)
    ||
    (dec_bits2 == 10'b010_0010011);

// SLTU / SLTIU
assign is_sltu =
    (dec_bits == 11'b0_011_0110011)
    ||
    (dec_bits2 == 10'b011_0010011);

// SRA / SRAI
assign is_sra =
    (dec_bits == 11'b1_101_0110011)
    ||
    (
        (dec_bits2 == 10'b101_0010011) &&
        (funct7[5] == 1'b1)
    );

// SRL / SRLI
assign is_srl =
    (dec_bits == 11'b0_101_0110011)
    ||
    (
        (dec_bits2 == 10'b101_0010011) &&
        (funct7[5] == 1'b0)
    );

assign is_xor =
    (dec_bits == 11'b0_100_0110011);

assign is_or =
    (dec_bits == 11'b0_110_0110011);

assign is_and =
    (dec_bits == 11'b0_111_0110011);

assign is_lui =
    (opcode == 7'b0110111);

assign is_auipc =
    (opcode == 7'b0010111);




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
// GUIA 4 - REQUERIMIENTO 2  GENERACION DE LA OPERACION DE LA ALU



assign alu_op =
    // LOAD: rs1 + imm
    is_load    ? 4'b0000 :

    // STORE: rs1 + imm
    is_s_instr ? 4'b0000 :

 // GUIA 6 - JALR: rs1 + imm
    is_jalr    ? 4'b0000 :

    // LUI: 0 + imm
    is_lui   ? 4'b0000 :

    // AUIPC: PC + imm
    is_auipc ? 4'b0000 :

    // ADD / ADDI
    is_addi ? 4'b0000 :

    // SLL / SLLI
    is_sll  ? 4'b0001 :

    // SLT / SLTI
    is_slt  ? 4'b0010 :

    // SLTU / SLTIU
    is_sltu ? 4'b0011 :

    // XOR / XORI
    is_xori ? 4'b0100 :

    // SRL / SRLI
    is_srl  ? 4'b0101 :

    // SRA / SRAI
    is_sra  ? 4'b1101 :

    // OR / ORI
    is_ori  ? 4'b0110 :

    // AND / ANDI
    is_andi ? 4'b0111 :

    // Para las demás instrucciones tipo R
    {funct7[5], funct3};



// 
// 19. INTERFAZ CON DMEM
// 

assign daddr= alu_out;

assign ddata_out = src2_value;

// Habilitacion de escritura en DMEM
// STORE durante EXECUTE o EXECUTE2
assign dwr_en =
    is_s_instr &
    (state_execute | state_execute2);

// Habilitacion de lectura en DMEM
// LOAD durante EXECUTE o EXECUTE2
assign drd_en =
    is_load &
    (state_execute | state_execute2);

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

    // JALR: PC = rs1 + imm
    is_jalr ? alu_out :

    // JAL o Branch tomado: PC = PC + imm
    (is_jal || taken_br) ? br_tgt_pc :

    // Ejecucion normal: PC = PC + 4
    pc4;

// 20.4 ACTUALIZACION DEL REGISTRO PC

// Reset sincronico y actualizacion solo durante EXECUTE

always @(posedge clk) begin

    if (rst)
        PC <= 32'd0;

    else if (state_execute)
        PC <= next_pc;

end

endmodule
