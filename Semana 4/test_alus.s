# test_alu.s
# Prueba de instrucciones nuevas de la Guia 4

# --- Instrucciones inmediatas de desplazamiento ---
addi  x1, x0, 8          # x1 = 8
slli  x2, x1, 2          # x2 = 8 << 2 = 32
srli  x3, x2, 1          # x3 = 32 >> 1 = 16

addi  x4, x0, -16        # x4 = -16
srai  x5, x4, 2          # x5 = -16 >>> 2 = -4

# --- Comparaciones inmediatas ---
slti  x6, x4, 0          # -16 < 0  -> x6 = 1
sltiu x7, x1, 10         # 8 < 10   -> x7 = 1

# --- Instrucciones tipo U ---
lui   x8, 0x12345        # x8 = 0x12345000
auipc x9, 0x1            # x9 = PC + 0x1000

# --- Pruebas tipo R ---
addi  x10, x0, 1         # x10 = 1
sll   x11, x10, x1       # x11 = 1 << 8 = 256
srl   x12, x11, x1       # x12 = 256 >> 8 = 1
sra   x13, x4, x1        # x13 = -16 >>> 8 = -1
slt   x14, x4, x1        # -16 < 8 -> x14 = 1
sltu  x15, x4, x1        # unsigned(-16) < 8 -> x15 = 0
