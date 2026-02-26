# Trabajo Práctico N°2: Comunicación UART con FSM y ALU

---
## Introducción

El objetivo de este trabajo práctico es implementar una comunicación serie mediante el protocolo **UART**, controlada por **máquinas de estado finitas (FSM)**.  
La información recibida por UART se procesa en la **ALU** desarrollada en el TP01, y posteriormente el resultado se transmite nuevamente por UART.  
De esta manera, se integran conceptos de diseño digital, comunicación asíncrona y control mediante FSM en un sistema completo.

---

### ALU (Unidad Aritmético-Lógica)
La **ALU** desarrollada en el TP01 permite realizar operaciones aritméticas y lógicas sobre dos operandos.  
Cuenta con:
- Entradas: `opA`, `opB`, `sel` (selector de operación).
- Salida: `result`.

En este TP, la ALU se integra con la comunicación UART, recibiendo operandos y operación desde el puerto serie, y devolviendo el resultado por el mismo canal.

---

## Diseño del Sistema

### Diagrama de Bloques General

El sistema se compone de tres módulos principales: **UART RX**, **FSM de Control con ALU**, y **UART TX**.  
El flujo de datos es el siguiente:

+-----------+       +-------------------+       +-----------+
|  UART RX  | --->  |  FSM + ALU (TP01) | --->  |  UART TX  |
+-----------+       +-------------------+       +-----------+


- **UART RX**: recibe los bytes enviados desde la PC.
- **FSM + ALU**: interpreta los datos, ejecuta la operación en la ALU y genera el resultado.
- **UART TX**: transmite el resultado de vuelta a la PC.

---

### FSM de Control

La máquina de estados finita coordina la recepción de datos, ejecución en la ALU y transmisión del resultado.  
Se diseñó como una **FSM tipo Moore**, con los siguientes estados:

- **IDLE**  
  - Estado inicial.  
  - Espera la llegada de datos por UART RX.  

- **RECEIVE**  
  - Captura tres bytes:  
    - Byte 1: selector de operación (`sel`).  
    - Byte 2: operando A (`opA`).  
    - Byte 3: operando B (`opB`).  
  - Una vez recibidos, pasa a `EXECUTE`.  

- **EXECUTE**  
  - Envía los operandos y la operación a la ALU.  
  - Espera el resultado (`result`).  
  - Luego pasa a `SEND`.  

- **SEND**  
  - Transmite el resultado por UART TX.  
  - Si el resultado es de 8 bits, se envía un solo byte.  
  - Si es de 16 bits, se envían dos bytes en secuencia.  
  - Al finalizar, vuelve a `IDLE`.  

---

### Diagrama de Estados (FSM de Control)

+-------+       +----------+       +----------+       +------+
| IDLE  | --->  | RECEIVE  | --->  | EXECUTE  | --->  | SEND |
+-------+       +----------+       +----------+       +------+
^                                                  |
|--------------------------------------------------+

---


---
