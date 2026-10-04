`timescale 1ns/1ps

// Test bench para el microcontrolador
module tb_mcu;

  reg clk;
  reg rst;

  // Instancia del microcontrolador
  mcu mcuuq (
    .rst(rst),
    .clk(clk)
  );

  integer i;

  initial begin

    $dumpfile("tb_mcu.vcd");
    $dumpvars(0, tb_mcu);
 

    // Icarus no acepta mem[i] en una referencia jerarquica
    // dentro de $dumpvars.
   // Registros necesarios para la evidencia
    $dumpvars(0, mcuuq.cpu.rf.mem[3]);
    $dumpvars(0, mcuuq.cpu.rf.mem[5]);
    $dumpvars(0, mcuuq.cpu.rf.mem[6]);
    $dumpvars(0, mcuuq.cpu.rf.mem[12]);

    #0;
    clk = 0;
    rst = 1;

    #9;
    rst = 0;

    #240;  // Termina después de 60 ciclos de reloj
    #16;

    $finish;

  end

  always begin
    #2 clk = !clk;
  end

endmodule
