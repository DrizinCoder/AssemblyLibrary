# Relatório: Desenvolvimento de Biblioteca assembly para comunicação entre HPS e FPGA

## 📌 Introdução
---
O uso de coprocessadores especializados tem se tornado cada vez mais relevante em aplicações que exigem alto desempenho em cálculos matriciais, como visão computacional, aprendizado de máquina e simulações científicas. Nesse contexto, o presente trabalho dá continuidade ao desenvolvimento de um coprocessador aritmético voltado para operações de multiplicação de matrizes, utilizando a plataforma DE1-SoC.

A proposta atual consiste em expandir a usabilidade do sistema previamente desenvolvido através da criação de uma biblioteca em linguagem Assembly. Essa biblioteca visa permitir que aplicações em alto nível possam se comunicar com o hardware de forma eficiente, simplificando o uso das operações aceleradas por hardware e maximizando o desempenho das aplicações que dependem de operações matriciais intensivas.

Além da biblioteca, este trabalho contempla a integração entre o código Assembly e aplicações escritas em linguagem C, o que exige um entendimento detalhado da arquitetura ARM, do mapeamento de memória e dos protocolos de comunicação entre o HPS (Hard Processor System) e a FPGA.
