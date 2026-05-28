# Trabajo Práctico N°2: Comunicación UART con FSM y ALU

---

## Introducción

El objetivo de este trabajo práctico es implementar una comunicación serie mediante el protocolo **UART**, controlada por **máquinas de estado finitas (FSM)**.  
La información recibida por UART se procesa en la **ALU** desarrollada en el TP01, y posteriormente el resultado se transmite nuevamente por UART.  
De esta manera, se integran conceptos de diseño digital, comunicación asíncrona y control mediante FSM en un sistema completo.Implementación de un canal selectivo en frecuencia.

---

## ALU (Unidad Aritmético-Lógica)
La **ALU** desarrollada en el TP01 permite realizar operaciones aritméticas y lógicas sobre dos operandos.  
Cuenta con:
- Entradas: `opA`, `opB`, `sel` (selector de operación).
- Salida: `result`.

En este TP, la ALU se integra con la comunicación UART, recibiendo operandos y operación desde el puerto serie, y devolviendo el resultado por el mismo canal.

---

## Estructura del proyecto
**alu.v** → ALU parametrizable (reutilizada del TP01).

**uart_rx.v** → Receptor UART con FSM para muestreo de bits.

**uart_tx.v** → Transmisor UART con control de envío.

**baud_gen.v** → Generador de ticks para baud rate.

**interface.v** → FSM que coordina la recepción de operandos/opcode, ejecución en la ALU y envío del resultado.

**uart_alu_top.v** → Integración de todos los módulos.

--- 

## Funcionamiento

1. Recepción (UART RX):

  - Se reciben tres bytes: Operando A, Operando B y Opcode.

  - La FSM almacena los valores en registros internos.

2. Ejecución (FSM + ALU):

  - La FSM pasa al estado EXECUTE.

  - Se ejecuta la operación en la ALU con los operandos recibidos.

3. Transmisión (UART TX):

  - La FSM pasa al estado SEND.

  - Se envía el resultado junto con los flags (Carry y Zero) al PC.

---

### Diagrama de Estados (FSM de Control)

Diagrama de bloquesPC <--> UART RX --> FSM --> ALU --> UART TX <--> PC

---
### Ejecucion

Para validar el funcionamiento del sistema, se utilizó un script en **Python** que abre el puerto serie, envía datos a la FPGA y recibe el resultado de la operación realizada por la ALU.

```python
import serial
import time

# Configuración del puerto serie
ser = serial.Serial('/dev/ttyUSB1', 9600, timeout=2)

# Envío de datos: A = 2, B = 3, OP = ADD
ser.write(bytes([2, 3, 0x20]))

# Espera breve para que la FSM procese la operación
time.sleep(1)

# Lectura de la respuesta enviada por la FPGA
data = ser.read(10)
print(data)

# Cierre del puerto
ser.close()
```
---
### Simulacion

no esta hecha, agg

---
### Conclusión