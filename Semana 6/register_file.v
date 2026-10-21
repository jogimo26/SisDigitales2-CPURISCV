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

    reg [31:0] mem [0:31];

    assign rd_data1 =
        (rd_index1 == 5'd0) ? 32'd0 : mem[rd_index1];

    assign rd_data2 =
        (rd_index2 == 5'd0) ? 32'd0 : mem[rd_index2];

    always @(posedge clk) begin
        if (wr_en && (wr_index != 5'd0))
            mem[wr_index] <= wr_data;
    end

endmodule