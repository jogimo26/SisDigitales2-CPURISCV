//Definición del microcontrolador
// Definicion del microcontrolador
module mcu(
    input clk,          // Reloj del microcontrolador
    input rst,          // Reset del microcontrolador
    output [7:0] PORTA, // Puerto A - salida
    output [7:0] PORTB, // Puerto B - salida
    input  [7:0] PORTC  // Puerto C - entrada
);

//Buses con la memoria de programa (IMEM)
    wire [31:0] instr; //Instrucción de entrada
    wire [31:0] iaddr; //Dirección en la IMEM

//Buses con la memoria de datos (DMEM)
    wire [31:0] daddr;     //Dirección en la DMEM
    wire [31:0] ddata_in;  //Bus de datos DMEM (entrada)
    wire [31:0] ddata_out; //Bus de datos DMEM (salida)
    wire dwr_en;           //Señales del bus de control DMEM
    wire drd_en;
    // GUIA 6 - Decodificacion de memoria y puertos
    wire sel_dmem;
    wire sel_porta;
    wire sel_portb;
    wire sel_portc;

    // Habilitadores internos
    wire dmem_wr_en;
    wire dmem_rd_en;
    wire porta_wr_en;
    wire portb_wr_en;
    wire portc_rd_en;

    // Registros de salida
    reg [7:0] porta_reg;
    reg [7:0] portb_reg;
    // GUIA 6 - MAPA DE MEMORIA

// DMEM: 0x0000 a 0x3FFF
assign sel_dmem =
    (daddr <= 32'h00003FFF);

// PORTA: 0x4000
assign sel_porta =
    (daddr == 32'h00004000);

// PORTB: 0x4004
assign sel_portb =
    (daddr == 32'h00004004);

// PORTC: 0x4008
assign sel_portc =
    (daddr == 32'h00004008);


// Habilitadores internos

assign dmem_wr_en = dwr_en & sel_dmem;
assign dmem_rd_en = drd_en & sel_dmem;

assign porta_wr_en = dwr_en & sel_porta;
assign portb_wr_en = dwr_en & sel_portb;
assign portc_rd_en = drd_en & sel_portc;

// GUIA 6 - REGISTROS DE SALIDA PORTA Y PORTB
// AQUI LO AGREGAS

always @(posedge clk) begin
    if (rst)
        porta_reg <= 8'b0;
    else if (porta_wr_en)
        porta_reg <= ddata_out[7:0];
end

always @(posedge clk) begin
    if (rst)
        portb_reg <= 8'b0;
    else if (portb_wr_en)
        portb_reg <= ddata_out[7:0];
end

assign PORTA = porta_reg;
assign PORTB = portb_reg;
// GUIA 6 - PUERTO DE ENTRADA PORTC
// Se conecta al bus ddata_in mediante buffer triestado

assign ddata_in =
    portc_rd_en ? {24'b0, PORTC} : 32'bz;

// Instancia del microprocesador RISCV
riscv cpu (
    .rst(rst),
    .clk(clk),
    .instr(instr),
    .iaddr(iaddr),
    .daddr(daddr),
    .ddata_in(ddata_in),
    .ddata_out(ddata_out),
    .dwr_en(dwr_en),
    .drd_en(drd_en)
);


// Instancia de la memoria de programa
rom4096x32 IMEM(
    .clk(clk),
    .data(instr),
    .addr(iaddr[13:2])
);

// GUIA 5 - Memoria de datos DMEM
sram_32x DMEM (
    .clk(clk),
    .addr(daddr[13:2]),
    .wr_en(dmem_wr_en),
    .wr_data(ddata_out),
    .rd_en(dmem_rd_en),
    .rd_data(ddata_in)
);
endmodule

// GUIA 5 - MEMORIA DE INSTRUCCIONES SINCRONICA

module rom4096x32 (
    input wire clk,
    input wire [11:0] addr,
    output reg [31:0] data
);

    reg [31:0] mem [0:4095];

    integer i;

    initial begin

        // Inicializar la ROM con NOP
        for (i = 0; i < 4096; i = i + 1)
            mem[i] = 32'h00000013;

        // Cargar programa desde archivo externo
        $readmemh("test_program.hex", mem);

    end

    // Lectura sincronica
    always @(negedge clk) begin
        data <= mem[addr];
    end

endmodule
// GUIA 5 - MEMORIA DE DATOS DMEM
// 1024 palabras de 32 bits

module sram_32x (
    input wire clk,
    input wire [11:0] addr,

    input wire wr_en,
    input wire [31:0] wr_data,

    input wire rd_en,
    output reg [31:0] rd_data
);

    // Memoria de 1024 palabras x 32 bits
    reg [31:0] mem [0:4095];

    // Escritura sincronica
    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= wr_data;
     // Lectura
        if (rd_en)
            rd_data <= mem[addr];
        else
            rd_data <= 32'bz;
    end

   

endmodule