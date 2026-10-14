
# MAKEFILE - GUIA 4 RISC-V

# Archivos Verilog
VERILOG = mcu.v mcu_tb.v riscv.v alu.v register_file.v

# Programa ensamblador
ASM = test_alu.s

# Archivos generados
ELF = test_program.elf
BIN = test_program.bin
HEX = test_program.hex
SIM = tb_mcu.vvp
VCD = tb_mcu.vcd


# TARGET PRINCIPAL


all: $(HEX) $(SIM)
	vvp $(SIM)



# ENSAMBLAR PROGRAMA RISC-V


$(ELF): $(ASM)
	riscv64-unknown-elf-as -o $(ELF) $(ASM) -march=rv32i



# CONVERTIR A BINARIO


$(BIN): $(ELF)
	riscv64-unknown-elf-objcopy -O binary $(ELF) $(BIN)



# GENERAR ARCHIVO HEX


$(HEX): $(BIN)
	hexdump -v -e '1/4 "%08x\n"' $(BIN) > $(HEX)



# COMPILAR VERILOG


$(SIM): $(VERILOG)
	iverilog -o $(SIM) $(VERILOG)



# MOSTRAR CODIGO MAQUINA


objdump: $(ELF)
	riscv64-unknown-elf-objdump $(ELF) -S



# ABRIR GTKWave


wave: $(VCD)
	gtkwave $(VCD)



# LIMPIAR ARCHIVOS GENERADOS


clean:
	rm -f $(ELF) $(BIN) $(HEX) $(SIM) $(VCD)
