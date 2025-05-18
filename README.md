<h1 align="center">📚 Library Communication Assembly with FPGA</h1>

</br>

<h2>📄 Introdução</h2>

Este projeto oferece uma estrutura para comunicação eficiente entre o Hard Processor System (HPS) e um coprocessador em Field-Programmable Gate Array (FPGA) na placa Terasic DE1-SoC, utilizando linguagem assembly ARMv7.

```bash
gcc -c main.c -o main.o
as -o driver.o driver.s
gcc main.o driver.o -o matrix_calculator
```
