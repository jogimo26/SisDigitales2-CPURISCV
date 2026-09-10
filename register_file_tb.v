`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg wr_en;
reg [4:0] wr_index;
reg [31:0] wr_data;
reg [4:0] rd_index1;
reg [4:0] rd_index2;

wire [31:0] rd_data1;
wire [31:0] rd_data2;

// Instancia del Register File
register_file uut(
    .clk(clk),
    .wr_en(wr_en),
    .wr_index(wr_index),
    .wr_data(wr_data),
    .rd_index1(rd_index1),
    .rd_index2(rd_index2),
    .rd_data1(rd_data1),
    .rd_data2(rd_data2)
);

// Generación del reloj (periodo = 10 ns)
always #5 clk = ~clk;

initial begin

    clk = 0;
    wr_en = 0;
    wr_index = 0;
    wr_data = 0;
    rd_index1 = 0;
    rd_index2 = 0;

    $display("-----------------------------------------------");
    $display("Tiempo\twr_en\twr_idx\twr_data\t\tRD1\tRD2");
    $display("-----------------------------------------------");

    $monitor("%0dns\t%b\t%d\t%h\t%h\t%h",
             $time, wr_en, wr_index, wr_data,
             rd_data1, rd_data2);

    // Escribir 100 en x5
    #10;
    wr_en = 1;
    wr_index = 5;
    wr_data = 32'd100;

    #10;
    wr_en = 0;

    // Leer x5
    rd_index1 = 5;

    #10;

    // Escribir 200 en x8
    wr_en = 1;
    wr_index = 8;
    wr_data = 32'd200;

    #10;
    wr_en = 0;

    // Leer x5 y x8
    rd_index1 = 5;
    rd_index2 = 8;

    #10;

    // Intentar escribir en x0 (no debe cambiar)
    wr_en = 1;
    wr_index = 0;
    wr_data = 32'hFFFFFFFF;

    #10;
    wr_en = 0;

    rd_index1 = 0;

    #20;

    $finish;

end

endmodule