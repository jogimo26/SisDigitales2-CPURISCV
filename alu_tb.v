module alu_tb;

reg [31:0] a;
reg [31:0] b;
reg [3:0] op;
wire [31:0] alu_out;

// Instancia de la alu
alu uut (
    .a(a),
    .b(b),
    .op(op),
    .alu_out(alu_out)
);

initial begin

    $display("------------------------------------------------");
    $display(" Tiempo\ta\tb\top\talu_out");
    $display("------------------------------------------------");

    $monitor("%4dns\t%d\t%d\t%b\t%d",
             $time, a, b, op, alu_out);

    // Prueba 1: Suma
    a = 32'd10;
    b = 32'd50;
    op = 4'b0000;
    #10;

    // Prueba 2: Resta
    a = 32'd110;
    b = 32'd19;
    op = 4'b1000;
    #10;

    // Prueba 3: aND
    a = 32'b110110;
    b = 32'b10111011;
    op = 4'b0111;
    #10;

    // Prueba 4: OR
    a = 32'b11001100;
    b = 32'b10101010;
    op = 4'b0110;
    #10;

    // Prueba 5: Suma
    a = 32'd15;
    b = 32'd55;
    op = 4'b0000;
    #10;

    // Prueba 6: Resta (resultado negativo)
    a = 32'd30;
    b = 32'd10;
    op = 4'b1000;
    #10;

    // Prueba 7: aND con todos unos
    a = 32'hFF;
    b = 32'h0F;
    op = 4'b0111;
    #10;

    // Prueba 8: OR con cero
    a = 32'h00;
    b = 32'haa;
    op = 4'b0110;
    #10;

    $finish;

end

endmodule
