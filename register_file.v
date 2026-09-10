module register_file (
    input clk,
    input wr_en,
    input [4:0] wr_index,
    input [31:0] wr_data,
    input [4:0] rd_index1,
    output [31:0] rd_data1,
    input [4:0] rd_index2,
    output [31:0] rd_data2
);

  // Arreglo de 32 registros de 32 bits (debe llamarse 'mem')
  reg [31:0] mem [0:31];

  // Lectura combinacional: si se pide el registro x0, devuelve 0
  assign rd_data1 = (rd_index1 == 5'b0) ? 32'b0 : mem[rd_index1];
  assign rd_data2 = (rd_index2 == 5'b0) ? 32'b0 : mem[rd_index2];

  // Escritura síncrona en el flanco de subida de reloj
  always @(posedge clk) begin
    if (wr_en && (wr_index != 5'b0)) begin
      mem[wr_index] <= wr_data;
    end
  end

endmodule