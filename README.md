# Relatório: Desenvolvimento de Biblioteca assembly para comunicação entre HPS e FPGA

## 📌 Introdução
---
O uso de coprocessadores especializados tem se tornado cada vez mais relevante em aplicações que exigem alto desempenho em cálculos matriciais, como visão computacional, aprendizado de máquina e simulações científicas. Nesse contexto, o presente trabalho dá continuidade ao desenvolvimento de um coprocessador aritmético voltado para operações de multiplicação de matrizes, utilizando a plataforma DE1-SoC.

A proposta atual consiste em expandir a usabilidade do sistema previamente desenvolvido através da criação de uma biblioteca em linguagem Assembly. Essa biblioteca visa permitir que aplicações em alto nível possam se comunicar com o hardware de forma eficiente, simplificando o uso das operações aceleradas por hardware e maximizando o desempenho das aplicações que dependem de operações matriciais intensivas.

Além da biblioteca, este trabalho contempla a integração entre o código Assembly e aplicações escritas em linguagem C, o que exige um entendimento detalhado da arquitetura ARM, do mapeamento de memória e dos protocolos de comunicação entre o HPS (Hard Processor System) e a FPGA.

## 🎯 Objetivos e Requisitos
---
### Objetivos

Este projeto tem como principal objetivo permitir a reutilização das funcionalidades do coprocessador matricial por meio de uma biblioteca desenvolvida em Assembly. Com isso, espera-se alcançar:

- A facilitação do desenvolvimento de novas aplicações que demandem aceleração de cálculos matriciais;
- O fortalecimento da compreensão sobre a interação hardware-software na plataforma DE1-SoC;
- A prática na programação em linguagem Assembly para a arquitetura ARM;
- A aplicação dos conceitos de comunicação entre o HPS e a FPGA usando barramentos, PIOs e protocolos de handshake.

### Requisitos

Para atender às especificações do problema, o projeto deve cumprir os seguintes requisitos:

- A biblioteca deve ser escrita em linguagem Assembly;
- Devem ser implementadas funções que permitam o uso direto das operações oferecidas pelo coprocessador;
- O estilo de codificação deve seguir o guia disponível em [MaJerle/c-code-style](https://github.com/MaJerle/c-code-style);
- A biblioteca deve ser compatível com aplicações desenvolvidas em linguagem C;
- O sistema deve ser validado através de testes funcionais, com documentação adequada sobre o processo de compilação, configuração e uso.
