#  Arquitectura de Computadoras – Trabajos Prácticos

Este repositorio contiene los desarrollos realizados para los trabajos prácticos de la materia **Arquitectura de Computadoras**, cursada en la Facultad de Ciencias Exactas, Físicas y Naturales – UNC.

---

##  Entorno de desarrollo

- **Vivado WebPACK** (Xilinx)
- **Ubuntu Linux**
- **Placa objetivo:** Basys 3 (FPGA Spartan-3E)
- **Lenguaje:** Verilog HDL

---

##  TP1 – ALU Parametrizable

### Descripción
Implementación de una ALU parametrizable que soporta operaciones aritméticas y lógicas. El diseño está pensado para ser reutilizado en el trabajo final.

### Operaciones soportadas

| Operación | Código binario |
|-----------|----------------|
| ADD       | 100000         |
| SUB       | 100010         |
| AND       | 100100         |
| OR        | 100101         |
| XOR       | 100110         |
| SRA       | 000011         |
| SRL       | 000010         |
| NOR       | 100111         |

### Validación
- Testbench con entradas aleatorias
- Chequeo automático de resultados
- Simulación en Vivado con análisis de tiempos

---
