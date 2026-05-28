import serial
import time

PORT = "/dev/ttyUSB1"
BAUD = 9600

# =========================
# CONFIGURACION
# =========================

A = 2
B = 3

#SUB:
OP = 0x22
OP_NAME = "-"

# =========================

def complemento_a_2(valor):
    if valor & 0x80:
        return valor - 256
    return valor

with serial.Serial(PORT, BAUD, timeout=2) as ser:

    ser.reset_input_buffer()

    ser.write(bytes([A, B, OP]))

    time.sleep(1)

    data = ser.read(2)

    if len(data) != 2:
        print("ERROR: no llegaron los 2 bytes esperados")
        exit()

    resultado_raw = data[0]
    flags = data[1]

    # Interpretacion signed (complemento a 2)
    resultado_signed = complemento_a_2(resultado_raw)

    # Interpretacion flags
    active_flags = []

    if flags & 0b001:
        active_flags.append("NEGATIVE")

    if flags & 0b010:
        active_flags.append("ZERO")

    if flags & 0b100:
        active_flags.append("CARRY")

    flag_text = "NINGUNO" if not active_flags else " + ".join(active_flags)

    # =========================
    # OUTPUT
    # =========================

    print(f"{A} {OP_NAME} {B} = {resultado_signed}")

    print(f"RESULTADO EN HEXA: 0x{resultado_raw:02X}")

    print(f"RESULTADO EN BINARIO: {resultado_raw:08b}")

    print(f"FLAG: {flag_text}")

