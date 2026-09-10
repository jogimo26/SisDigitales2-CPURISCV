`timescale 1ns/1ps

module tb_riscv;

  // Señales de prueba
  reg [31:0] instr;
  reg clk;
  reg rst;

  // Instancia del DUT
  riscv uut (
    .clk(clk),
    .rst(rst),
    .instr(instr)
  );

  // Bloque inicial
  integer i;

  initial begin

    // Configurar generación de archivos de volcado (graba automáticamente todo)
    $dumpfile("tb_riscv.vcd");
    $dumpvars(0, tb_riscv);

    // Inicializa el register file
    for(i=0; i<32; i=i+1)
      uut.rv_rf.mem[i] = i;

    // Mostrar valores de interés
    $monitor($time,
      " clk=%d | ins=%h | x4=%h | x5=%h | x6=%h",
      clk, instr,
      uut.rv_rf.mem[4],
      uut.rv_rf.mem[5],
      uut.rv_rf.mem[6]
    );

    #0;
    clk = 0;
    rst = 1;

    #3;
    rst = 0;

    // ADD x4, x3, x2
    instr = 32'b0000000_00010_00011_000_00100_0110011;
    $display("add x4, x3, x2");

    #12;

    // SUB x5, x3, x2
    instr = 32'b0100000_00010_00011_000_00101_0110011;
    $display("sub x5, x3, x2");

    #12;

    // AND x6, x10, x12
    instr = 32'b0000000_01100_01010_111_00110_0110011;
    $display("and x6, x10, x12");

    #12;

    // OR x6, x10, x12
    instr = 32'b0000000_01100_01010_110_00110_0110011;
    $display("or x6, x10, x12");

    #12;

    // XOR x6, x10, x12
    instr = 32'b0000000_01100_01010_100_00110_0110011;
    $display("xor x6, x10, x12");

    #16;

    // Fin de la simulación
    $finish;
  end

  // Generación del reloj
  always begin
    #2 clk = !clk;
  end

endmodule