module alu_tb;

reg [7:0] A;
reg [7:0] B;
reg [1:0] op;
wire [7:0] ALU_out;

// Instancia de la ALU
ALU uut (
    .A(A),
    .B(B),
    .op(op),
    .ALU_out(ALU_out)
);

initial begin

    $display("------------------------------------------------");
    $display(" Tiempo\tA\tB\top\tALU_out");
    $display("------------------------------------------------");

    $monitor("%4dns\t%d\t%d\t%b\t%d",
             $time, A, B, op, ALU_out);

    // Prueba 1: Suma
    A = 8'd10;
    B = 8'd50;
    op = 2'b00;
    #10;

    // Prueba 2: Resta
    A = 8'd110;
    B = 8'd19;
    op = 2'b01;
    #10;

    // Prueba 3: AND
    A = 8'b110110;
    B = 8'b10111011;
    op = 2'b10;
    #10;

    // Prueba 4: OR
    A = 8'b11001100;
    B = 8'b10101010;
    op = 2'b11;
    #10;

    // Prueba 5: Suma
    A = 8'd15;
    B = 8'd55;
    op = 2'b00;
    #10;

    // Prueba 6: Resta (resultado negativo)
    A = 8'd30;
    B = 8'd10;
    op = 2'b01;
    #10;

    // Prueba 7: AND con todos unos
    A = 8'hFF;
    B = 8'h0F;
    op = 2'b10;
    #10;

    // Prueba 8: OR con cero
    A = 8'h00;
    B = 8'hAA;
    op = 2'b11;
    #10;

    $finish;

end

endmodule