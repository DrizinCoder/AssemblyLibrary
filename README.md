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

## 🛠️ Recursos Utilizados
---

### 🔧 Quartus Prime
Síntese e Compilação:
O Quartus Prime é utilizado para compilar o projeto em Verilog, convertendo a descrição HDL em uma implementação física adequada para a FPGA. Durante esse processo, o compilador realiza a síntese lógica, o mapeamento e o ajuste de layout (place and route), otimizando as rotas lógicas e a alocação dos recursos internos da FPGA, conforme as recomendações descritas no User Guide: Compiler.

Análise de Timing:
Emprega-se o TimeQuest Timing Analyzer para validar as restrições temporais, como os tempos de setup e hold, além de identificar os caminhos críticos no design. Essa análise é essencial para garantir que o projeto opere de forma estável em frequência alvo, conforme metodologias detalhadas na documentação oficial.

Gravação na FPGA:
A programação da FPGA é realizada via Programmer, utilizando o cabo USB-Blaster. Esse procedimento suporta a gravação de múltiplos arquivos .sof, permitindo a configuração e reconfiguração do hardware conforme especificado nos guias técnicos da Intel.

Design Constraints:
São definidas as restrições de pinos e de clock por meio do Pin Planner e das ferramentas de timing. Essas constraints garantem que as conexões físicas e os requisitos temporais sejam atendidos, alinhando-se às práticas recomendadas no User Guide da ferramenta.

### 💻 FPGA
Especificações Técnicas:
A placa DE1-SoC, baseada no FPGA Cyclone V SoC (modelo 5CSEMA5F31C6N), conta com aproximadamente 85K elementos lógicos (LEs), 4.450 Kbits de memória embarcada e 6 blocos DSP de 18x18 bits. Essas características permitem a implementação de designs complexos e o processamento paralelo de dados.

Periféricos Utilizados:

Switches e LEDs: Utilizados para depuração e controle manual, permitindo, por exemplo, a seleção e visualização de operações matriciais.

Compatibilidade:
O projeto foi compilado com Quartus Prime 20.1.1 e testado com a versão 6.0.0 do CD-ROM da DE1-SoC (rev.H), conforme as especificações técnicas fornecidas pela Terasic.

Referência oficial: 

### ⚙ GCC

O GCC (GNU Compiler Collection) é um compilador robusto e amplamente utilizado em projetos que envolvem linguagens como C e Assembly. Neste projeto, o GCC foi utilizado para compilar tanto os arquivos escritos em linguagem C quanto os arquivos em Assembly, garantindo a geração de executáveis compatíveis com a arquitetura ARM presente na plataforma DE1-SoC.

No caso do código em C, o GCC foi responsável por compilar a lógica de interface com o usuário e o controle de chamadas para funções Assembly. Já para o Assembly, o compilador foi utilizado para traduzir as instruções de baixo nível que acessam diretamente os recursos do coprocessador, permitindo uma comunicação eficiente com o hardware.

A compilação foi automatizada por meio de um script `Makefile`, o que facilitou a integração dos diferentes módulos e agilizou o processo de testes.

Referência oficial: 
