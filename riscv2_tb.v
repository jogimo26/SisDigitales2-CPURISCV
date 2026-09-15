`timescale 1ns/1ps

module riscv2_tb;

  // ============================================================
  // SEÑALES DEL TESTBENCH
  // ============================================================

  reg clk;
  reg rst;
  reg [31:0] instr;

  integer errores;


  // ============================================================
  // INSTANCIA DEL PROCESADOR
  // ============================================================

  riscv dut (
    .clk(clk),
    .rst(rst),
    .instr(instr)
  );


  // ============================================================
  // GENERACION DEL RELOJ
  // ============================================================

  initial begin
    clk = 0;
  end

  always #5 clk = ~clk;


  // ============================================================
  // INICIO DE LAS PRUEBAS
  // ============================================================

  initial begin

    errores = 0;

    // Valores iniciales
    rst   = 1;
    instr = 32'b0;

    // Esperamos un flanco de reloj con reset activo
    @(posedge clk);
    #1;

    // Quitamos el reset
    rst = 0;


    // ==========================================================
    // PRUEBA 1
    // ADDI x5, x0, 12
    //
    // x5 = 0 + 12
    //
    // Se espera:
    // imm      = 12
    // alu_a    = 0
    // alu_b    = 12
    // alu_op   = 0000
    // alu_out  = 12
    // is_addi  = 1
    // ==========================================================

    instr = 32'h00C00293;

    @(posedge clk);
    #1;

    $display("");
    $display("========================================");
    $display("PRUEBA ADDI x5,x0,12");
    $display("========================================");

    $display("IR        = %h", dut.IR);
    $display("imm       = %d", dut.imm);
    $display("imm_valid = %b", dut.imm_valid);
    $display("alu_a     = %d", dut.alu_a);
    $display("alu_b     = %d", dut.alu_b);
    $display("alu_op    = %b", dut.alu_op);
    $display("alu_out   = %d", dut.alu_out);
    $display("is_addi   = %b", dut.is_addi);

    if (
        dut.imm       == 32'd12 &&
        dut.imm_valid == 1'b1   &&
        dut.alu_a     == 32'd0  &&
        dut.alu_b     == 32'd12 &&
        dut.alu_op    == 4'b0000 &&
        dut.alu_out   == 32'd12 &&
        dut.is_addi   == 1'b1
       )
    begin
      $display("RESULTADO: ADDI OK");
    end
    else
    begin
      $display("RESULTADO: ADDI ERROR");
      errores = errores + 1;
    end


    // ==========================================================
    // PRUEBA 2
    // ANDI x6, x0, 15
    //
    // x6 = 0 AND 15
    //
    // Se espera:
    // imm      = 15
    // alu_a    = 0
    // alu_b    = 15
    // alu_op   = 0111
    // alu_out  = 0
    // is_andi  = 1
    // ==========================================================

    instr = 32'h00F07313;

    @(posedge clk);
    #1;

    $display("");
    $display("========================================");
    $display("PRUEBA ANDI x6,x0,15");
    $display("========================================");

    $display("IR        = %h", dut.IR);
    $display("imm       = %d", dut.imm);
    $display("imm_valid = %b", dut.imm_valid);
    $display("alu_a     = %d", dut.alu_a);
    $display("alu_b     = %d", dut.alu_b);
    $display("alu_op    = %b", dut.alu_op);
    $display("alu_out   = %d", dut.alu_out);
    $display("is_andi   = %b", dut.is_andi);

    if (
        dut.imm       == 32'd15 &&
        dut.imm_valid == 1'b1   &&
        dut.alu_a     == 32'd0  &&
        dut.alu_b     == 32'd15 &&
        dut.alu_op    == 4'b0111 &&
        dut.alu_out   == 32'd0 &&
        dut.is_andi   == 1'b1
       )
    begin
      $display("RESULTADO: ANDI OK");
    end
    else
    begin
      $display("RESULTADO: ANDI ERROR");
      errores = errores + 1;
    end


    // ==========================================================
    // PRUEBA 3
    // ORI x7, x0, 42
    //
    // x7 = 0 OR 42
    //
    // Se espera:
    // imm      = 42
    // alu_a    = 0
    // alu_b    = 42
    // alu_op   = 0110
    // alu_out  = 42
    // is_ori   = 1
    // ==========================================================

    instr = 32'h02A06393;

    @(posedge clk);
    #1;

    $display("");
    $display("========================================");
    $display("PRUEBA ORI x7,x0,42");
    $display("========================================");

    $display("IR        = %h", dut.IR);
    $display("imm       = %d", dut.imm);
    $display("imm_valid = %b", dut.imm_valid);
    $display("alu_a     = %d", dut.alu_a);
    $display("alu_b     = %d", dut.alu_b);
    $display("alu_op    = %b", dut.alu_op);
    $display("alu_out   = %d", dut.alu_out);
    $display("is_ori    = %b", dut.is_ori);

    if (
        dut.imm       == 32'd42 &&
        dut.imm_valid == 1'b1   &&
        dut.alu_a     == 32'd0  &&
        dut.alu_b     == 32'd42 &&
        dut.alu_op    == 4'b0110 &&
        dut.alu_out   == 32'd42 &&
        dut.is_ori    == 1'b1
       )
    begin
      $display("RESULTADO: ORI OK");
    end
    else
    begin
      $display("RESULTADO: ORI ERROR");
      errores = errores + 1;
    end


    // ==========================================================
    // PRUEBA 4
    // XORI x8, x0, 85
    //
    // x8 = 0 XOR 85
    //
    // Se espera:
    // imm      = 85
    // alu_a    = 0
    // alu_b    = 85
    // alu_op   = 0100
    // alu_out  = 85
    // is_xori  = 1
    // ==========================================================

    instr = 32'h05504413;

    @(posedge clk);
    #1;

    $display("");
    $display("========================================");
    $display("PRUEBA XORI x8,x0,85");
    $display("========================================");

    $display("IR        = %h", dut.IR);
    $display("imm       = %d", dut.imm);
    $display("imm_valid = %b", dut.imm_valid);
    $display("alu_a     = %d", dut.alu_a);
    $display("alu_b     = %d", dut.alu_b);
    $display("alu_op    = %b", dut.alu_op);
    $display("alu_out   = %d", dut.alu_out);
    $display("is_xori   = %b", dut.is_xori);

    if (
        dut.imm       == 32'd85 &&
        dut.imm_valid == 1'b1   &&
        dut.alu_a     == 32'd0  &&
        dut.alu_b     == 32'd85 &&
        dut.alu_op    == 4'b0100 &&
        dut.alu_out   == 32'd85 &&
        dut.is_xori   == 1'b1
       )
    begin
      $display("RESULTADO: XORI OK");
    end
    else
    begin
      $display("RESULTADO: XORI ERROR");
      errores = errores + 1;
    end


    // ==========================================================
    // RESULTADO FINAL
    // ==========================================================

    $display("");
    $display("========================================");
    $display("        RESULTADO FINAL");
    $display("========================================");

    if (errores == 0)
    begin
      $display("TODAS LAS PRUEBAS PASARON");
    end
    else
    begin
      $display("SE ENCONTRARON %0d ERRORES", errores);
    end

    $display("========================================");


    // ==========================================================
    // FINAL DE LA SIMULACION
    // ==========================================================

    #10;
    $finish;

  end


  // ============================================================
  // ARCHIVO VCD PARA GTKWave
  // ============================================================

  initial begin
    $dumpfile("tb_riscv.vcd");
    $dumpvars(0, riscv2_tb);
  end


endmodule
