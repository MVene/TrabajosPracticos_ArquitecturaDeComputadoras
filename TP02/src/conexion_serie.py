import serial
import time

PORT = "/dev/ttyUSB1"
BAUD = 9600

# =========================
# MAPEO DE OPERACIONES
# =========================

OPERACIONES = {
    "ADD": {
        "opcode": 0x20,
        "op_name": "+"
    },
    "SUB": {
        "opcode": 0x22,
        "op_name": "-"
    },
    "AND": {
        "opcode": 0x24,
        "op_name": "AND"
    },
    "OR": {
        "opcode": 0x25,
        "op_name": "OR"
    },
    "XOR": {
        "opcode": 0x26,
        "op_name": "XOR"
    },
    "NOR": {
        "opcode": 0x27,
        "op_name": "NOR"
    },
    "SRA": {
        "opcode": 0x03,
        "op_name": "<<"
    },
    "SRL": {
        "opcode": 0x02,
        "op_name": ">>"
    }
}


def complemento_a_2(valor):
    if valor & 0x80:
        return valor - 256
    return valor


# =========================
# INGRESO POR TERMINAL
# =========================

print("OPERACIONES DISPONIBLES:")
print("ADD  -> suma")
print("SUB  -> resta")
print("AND  -> AND")
print("OR   -> OR")
print("XOR  -> XOR")
print("NOR  -> NOR")
print("SRA  -> shift right aritmético")
print("SRL  -> shift right lógico")
print()

A = int(input("Ingrese A: "))
B = int(input("Ingrese B: "))

op_ingresada = input("Ingrese operación: ").strip().upper()

if op_ingresada not in OPERACIONES:
    print(f"ERROR: operación '{op_ingresada}' no válida")
    exit()

# Obtenemos automáticamente opcode y nombre
OP = OPERACIONES[op_ingresada]["opcode"]
OP_NAME = OPERACIONES[op_ingresada]["op_name"]


# =========================
# VALIDACION
# =========================

if not 0 <= A <= 255:
    print("ERROR: A debe estar entre 0 y 255")
    exit()

if not 0 <= B <= 255:
    print("ERROR: B debe estar entre 0 y 255")
    exit()


# =========================
# COMUNICACION SERIAL
# =========================

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

    # Interpretación signed usando complemento a 2
    resultado_signed = complemento_a_2(resultado_raw)

    # =========================
    # FLAGS
    # =========================

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

    print()
    print("=========================")
    print("       ENTRADAS")
    print("=========================")

    print(f"A DECIMAL:  {A}")
    print(f"A HEXA:     0x{A:02X}")
    print(f"A BINARIO:  {A:08b}")

    print()

    print(f"B DECIMAL:  {B}")
    print(f"B HEXA:     0x{B:02X}")
    print(f"B BINARIO:  {B:08b}")

    print()
    print("=========================")
    print("       RESULTADO")
    print("=========================")

    if op_ingresada == "NOT":
        print(f"{OP_NAME} {A} = {resultado_signed}")
    else:
        print(f"{A} {OP_NAME} {B} = {resultado_signed}")

    print(f"RESULTADO EN HEXA:    0x{resultado_raw:02X}")
    print(f"RESULTADO EN BINARIO: {resultado_raw:08b}")
    print(f"FLAG: {flag_text}")