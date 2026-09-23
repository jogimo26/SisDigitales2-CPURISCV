module riscv (
    input clk,
    input rst,
    input [31:0] instr,
        // NUEVO: conexión con IMEM
    output wire [31:0] iaddr,


    // NUEVO: conexión con DMEM
    output wire [31:0] daddr,
    input  wire [31:0] ddata_in,
    output wire [31:0] ddata_out,
    output wire        dwr_en,
    output wire        drd_en
);
//contador de programa 
reg [31:0] PC;

// Dirección hacia la memoria de instrucciones
assign iaddr = PC;

//CONTROL DE CICLOS 
  reg state_fetch;
  reg state_decode;
  reg state_execute;

//Contador en anillo que controla el ciclo de instruccion

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

// Registro de instruccion
reg [31:0] IR;

always @(posedge clk) begin
    if (rst)
        IR <= 32'd0;
    else if (state_fetch)
        IR <= instr;
end

  // CAMPOS DE LA INSTRUCCION
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


  // REGISTER FILE

  wire [31:0] src1_value;
  wire [31:0] src2_value;

  // ALU
  wire [31:0] alu_a;
  wire [31:0] alu_b;
  wire [31:0] alu_out;

  wire [3:0] alu_op;


  // SEÑALES DE CONTROL

  wire wr_en;

  wire [10:0] dec_bits;

  // NUEVO:
  // funct3 + opcode
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


  // NUEVO: INSTRUCCIONES TIPO I ARITMETICAS

  wire is_addi;
  wire is_xori;
  wire is_ori;
  wire is_andi;

// INSTRUCCIONES TIPO B - BRANCH

wire is_beq;
wire is_bne;
wire is_blt;
wire is_bge;
wire is_bltu;
wire is_bgeu;

  // TIPO DE INSTRUCCION
  wire is_valid;

  wire is_u_instr;
  wire is_j_instr;
  wire is_b_instr;
  wire is_s_instr;
  wire is_r_instr;
  wire is_i_instr;


  // INMEDIATO

  wire [31:0] imm;
  wire imm_valid;

  // REGISTER FILE

  register_file rv_rf (
    .clk(clk),

    .wr_en(wr_en),

    .wr_index(rd),
    .wr_data(alu_out),

    .rd_index1(rs1),
    .rd_data1(src1_value),

    .rd_index2(rs2),
    .rd_data2(src2_value)
  );


  // ALU

  alu rv_alu (
    .a(alu_a),
    .b(alu_b),
    .ALU_out(alu_out),
    .op(alu_op)
  );


  // CONEXION REGISTER FILE -> ALU

  // Entrada A siempre viene de rs1
  assign alu_a = src1_value;


  // NUEVO: MUX DE ENTRADA B DE LA ALU

  // Tipo R:
  //      alu_b = src2_value
  //
  // Tipo I:
  //      alu_b = imm
  //
  // imm_valid funciona como señal de seleccion del MUX

  assign alu_b = imm_valid ? imm : src2_value;


  // CONTROL UNIT

  assign is_valid = (opcode[1:0] == 2'b11);


  // DETECCION DEL FORMATO

  assign is_u_instr =
      (opcode[6:2] == 5'b00101) ||
      (opcode[6:2] == 5'b01101);


  assign is_j_instr =
      (opcode[6:2] == 5'b11011);


  assign is_b_instr =
      (opcode[6:2] == 5'b11000);
    // DECODIFICACION DE INSTRUCCIONES BRANCH
// BEQ
// funct3 = 000
assign is_beq =
    is_b_instr &&
    (funct3 == 3'b000);


// BNE
// funct3 = 001
assign is_bne =
    is_b_instr &&
    (funct3 == 3'b001);


// BLT
// funct3 = 100
assign is_blt =
    is_b_instr &&
    (funct3 == 3'b100);


// BGE
// funct3 = 101
assign is_bge =
    is_b_instr &&
    (funct3 == 3'b101);


// BLTU
// funct3 = 110
assign is_bltu =
    is_b_instr &&
    (funct3 == 3'b110);


// BGEU
// funct3 = 111
assign is_bgeu =
    is_b_instr &&
    (funct3 == 3'b111);

  assign is_s_instr =
      (opcode[6:2] == 5'b01000) ||
      (opcode[6:2] == 5'b01001);


  assign is_r_instr =
      (opcode[6:2] == 5'b01011) ||
      (opcode[6:2] == 5'b01100) ||
      (opcode[6:2] == 5'b01110) ||
      (opcode[6:2] == 5'b10100);


  assign is_i_instr =
      (opcode[6:2] == 5'b00000) ||
      (opcode[6:2] == 5'b00001) ||
      (opcode[6:2] == 5'b00100) ||
      (opcode[6:2] == 5'b00110) ||
      (opcode[6:2] == 5'b11001) ||
      (opcode[6:2] == 5'b11100);


  
  // GENERADOR DE INMEDIATOS

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


  // VALIDEZ DEL INMEDIATO

  assign imm_valid =
      is_i_instr |
      is_s_instr |
      is_b_instr |
      is_u_instr |
      is_j_instr;


  // WRITE ENABLE

 assign wr_en =
    state_execute &
    (
        is_r_instr |
        is_i_instr |
        is_u_instr |
        is_j_instr
    );

  // DECODIFICACION TIPO R

  // Tipo R utiliza:
  //
  // funct7[5] + funct3 + opcode

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


  // NUEVO: DECODIFICACION TIPO I
  // Para instrucciones inmediatas NO usamos funct7.
  // Utilizamos:
  // funct3 + opcode


  assign dec_bits2 = {
      funct3,
      opcode
  };


  // addi
  assign is_addi =
      (dec_bits2 == 10'b000_0010011);


  // xori
  assign is_xori =
      (dec_bits2 == 10'b100_0010011);


  // ori
  assign is_ori =
      (dec_bits2 == 10'b110_0010011);


  // andi
  assign is_andi =
      (dec_bits2 == 10'b111_0010011);


  // OPERACION PARA LA ALU

  // Para las instrucciones I:
  //
  // ADDI -> 0000
  // XORI -> 0100
  // ORI  -> 0110
  // ANDI -> 0111

  // Son las mismas operaciones de la ALU que:
  // ADD
  // XOR
  // OR
  // AND
 
  assign alu_op =

      is_addi ? 4'b0000 :

      is_xori ? 4'b0100 :

      is_ori  ? 4'b0110 :

      is_andi ? 4'b0111 :

      // Para las instrucciones tipo R
      {funct7[5], funct3};

        //interfaz con DMEM
    assign daddr     = 32'b0;
    assign ddata_out = 32'b0;
    assign dwr_en    = 1'b0;
    assign drd_en    = 1'b0;

endmodule
