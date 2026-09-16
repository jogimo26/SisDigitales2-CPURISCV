module riscv (
    input clk,          // Reloj del procesador
    input rst,          // Reset del procesador
    input [31:0] instr  // Instrucción de entrada
);
  
  reg [31:0] IR;        // Registro de instrucción
  always @(posedge clk) begin
    IR <= instr;
  end
  
  // Señales del registro de instrucción (IR)
  wire [6:0] funct7;
  wire [4:0] rs2;
  wire [4:0] rs1;
  wire [2:0] funct3;
  wire [4:0] rd;
  wire [6:0] opcode;
  
  // Extracción de los campos del registro de instrucción
  assign funct7 = IR[31:25];
  assign rs2 = IR[24:20];
  assign rs1 = IR[19:15];
  assign funct3 = IR[14:12];
  assign rd = IR[11:7];
  assign opcode = IR[6:0];
  
  // Salidas del register file
  wire [31:0] src1_value;
  wire [31:0] src2_value;  
  
  // Operandos de entrada a la alu
  wire [31:0] alu_a;
  wire [31:0] alu_b;
  
  // Salida de la ALU
  wire [31:0] alu_out;
  
  // Señales de control de la CU
  wire wr_en;
  wire [10:0] dec_bits;
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
  wire [3:0] alu_op;    // Cable adicional para la operación de la ALU
  
  // Instanciación del RF (nombrado rv_rf para coincidir con el Testbench)
  register_file rv_rf (
    .clk(clk),
    .wr_en(wr_en), 
    .wr_index(rd),           // El destino es rd
    .wr_data(alu_out),       // Se escribe el resultado de la ALU
    .rd_index1(rs1),         // Registro fuente 1
    .rd_data1(src1_value),    
    .rd_index2(rs2),         // Registro fuente 2
    .rd_data2(src2_value)    
  );

  // Instanciación de la ALU 
  alu rv_alu (
    .a( alu_a ),
    .b( alu_b ), 
    .ALU_out( alu_out ), 
    .op( alu_op )            // Señal que define la operación
  );
  
  // Cableado entre el RF y la ALU
  assign alu_a = src1_value;
  assign alu_b = src2_value;

  // Cableado de la Control Unit (UC)
  //--------------------------------
  
  // Señales de control
  assign wr_en = (opcode == 7'b0110011);  // Escribe solo si es instrucción tipo R
  
  assign dec_bits = {funct7[5], funct3, opcode};
  
  assign is_add  = (dec_bits == 11'b0_000_0110011);
  assign is_sub  = (dec_bits == 11'b1_000_0110011); // funct7[5] es 1 para la resta
  assign is_sll  = (dec_bits == 11'b0_001_0110011);
  assign is_slt  = (dec_bits == 11'b0_010_0110011);
  assign is_sltu = (dec_bits == 11'b0_011_0110011);
  assign is_xor  = (dec_bits == 11'b0_100_0110011);
  assign is_srl  = (dec_bits == 11'b0_101_0110011);
  assign is_sra  = (dec_bits == 11'b1_101_0110011);
  assign is_or   = (dec_bits == 11'b0_110_0110011);
  assign is_and  = (dec_bits == 11'b0_111_0110011);  

  // Creación del opcode para la ALU concatenando el bit de funct7[5] y funct3
  assign alu_op = {dec_bits[10], dec_bits[9:7]}; 

endmodule
