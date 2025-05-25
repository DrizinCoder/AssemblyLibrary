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

### 💻 Linguagens C e Assembly

A linguagem C foi empregada como camada de alto nível para interação com o usuário, gerenciamento de dados e chamada das rotinas implementadas em Assembly. Sua utilização permitiu desenvolver uma aplicação mais estruturada e acessível, mantendo a flexibilidade na manipulação de ponteiros e acesso a endereços de memória específicos.

Por outro lado, a linguagem Assembly foi utilizada para criar uma biblioteca especializada em acessar e acionar o coprocessador implementado na FPGA. Através do Assembly, foi possível implementar instruções personalizadas, manipular registradores e controlar com precisão o fluxo de dados entre o HPS e o hardware, respeitando os protocolos de comunicação definidos.

Essa combinação entre C e Assembly garantiu um equilíbrio entre desempenho e legibilidade, permitindo a construção de um sistema eficiente e de fácil manutenção.


## ⚙️ Desenvolvimento e Descrição em Alto Nível
---
### 🔧 Ajustes Realizados no Coprocessador

Inicialmente, foi realizada uma revisão na arquitetura do coprocessador previamente desenvolvido, com o objetivo de simplificar etapas do processamento e alinhar o projeto a práticas adotadas em arquiteturas mais modernas. Essa reformulação visou não apenas otimizar o desempenho geral do sistema, mas também facilitar a implementação da biblioteca em linguagem Assembly.

A principal modificação consistiu na reformulação do formato da instrução do coprocessador, que passou de 8 para 27 bits. Essa expansão permitiu a inclusão direta dos dados das matrizes dentro da própria instrução, eliminando a necessidade de etapas intermediárias de carregamento. Com isso, tornou-se possível estabelecer uma comunicação mais direta entre o processador e o coprocessador, viabilizando uma integração mais eficiente e simplificada no contexto da execução de operações matriciais.

// Imagem com novo formato das instruções

| Atributo | Descrição |
|----------|-----------|
| MT       | Matriz alvo do carregamento (A ou B) |
| M_Size   | Tamanho da matriz utilizado por operações de movimentação de dados e aritméticas |
| OPCODE   | Código de operação |
| Position |Posição do registrador utilizada por operações de movimentação de dados|
|Num 1 | Número a ser inserido na matriz alvo|
|Num 2 | Número a ser inserido na matriz alvo|

A nova implementação exigiu uma reformulação na forma como os dados eram inseridos nos registradores e enviados ao processador. Essa mudança foi uma consequência direta da modificação no formato da instrução, que passou a incorporar informações adicionais sobre os dados e suas posições.

A comunicação entre o processador e o coprocessador foi estruturada seguindo a metodologia mestre-escravo, onde o processador (mestre) envia instruções ao coprocessador (escravo), que as interpreta e executa. No caso das instruções do tipo `LOAD`, o processador transmite os valores das matrizes juntamente com suas posições codificadas dentro da própria instrução. O coprocessador então realiza o armazenamento desses valores nos registradores internos correspondentes.

De forma análoga, a instrução `STORE` é utilizada para retornar os resultados ao processador. Nessa operação, o coprocessador empacota quatro bytes de resultado e os envia ao HPS, respeitando a posição especificada na instrução recebida. Esse modelo de comunicação direta e estruturada permitiu maior controle sobre o fluxo de dados, além de garantir eficiência e sincronização entre os módulos envolvidos.

### 🔌 Comunicação Utilizada

A comunicação desenvolvida, como já mencionado, segue a arquitetura mestre-escravo, na qual o processador (mestre) envia instruções ao coprocessador (escravo), responsável por processá-las e retornar os dados. Esse envio é realizado por meio do barramento **Lightweight HPS-to-FPGA (LW-H2F)**, uma interface AXI disponível na plataforma DE1-SoC.

O barramento LW-H2F possui uma largura de 32 bits e foi projetado para transferências de controle e pequenos volumes de dados. Ele permite uma comunicação eficiente e simplificada entre o HPS (Hard Processor System) e a lógica programável da FPGA. Sua utilização neste projeto foi fundamental para garantir a troca rápida de comandos e dados entre as duas partes da placa, sem a necessidade de protocolos complexos.

#### 📥 PIOs – Parallel Input/Output

Outro componente essencial utilizado na comunicação foi o **PIO (Parallel Input/Output)**, disponível como periférico padrão no Platform Designer (Qsys) do Quartus. O PIO é um módulo simples que permite realizar leitura e escrita paralela de dados entre o HPS e a FPGA. Ele é amplamente utilizado para envio de sinais de controle, estados ou dados discretos em aplicações embarcadas.

No contexto deste projeto, os PIOs desempenharam múltiplas funções:

- Controle de sinais de sincronização entre o processador e o coprocessador (como “pronto” enviado pela FPGA), viabilizando um protocolo de handshaking confiável;
- Transmissão das instruções montadas no processador para o coprocessador, permitindo a ativação direta das operações matriciais;
- Envio de pacotes de bits do coprocessador para o HPS, contendo os resultados das operações, especialmente nos casos de instruções do tipo `STORE`.

Essa abordagem multifuncional com os PIOs proporcionou flexibilidade na comunicação e reduziu a complexidade de controle interno do sistema. O uso combinado do barramento AXI e dos PIOs resultou em um canal de comunicação robusto, eficiente e altamente adaptado às exigências do projeto.
#### 🤝 Protocolo de Handshaking

O protocolo de handshaking implementado entre o HPS e o coprocessador (FPGA) segue os seguintes passos:

1. **Envio da instrução**  
   - O HPS monta a instrução em Assembly e a escreve nos registradores via barramento e PIOs.  
   - Em seguida, o HPS aciona o sinal `Start` (coloca `Start = 1`) para indicar que há uma nova operação a ser executada.

2. **Modo de espera do HPS**  
   - Após ativar `Start`, o HPS entra em loop de espera, monitorando o sinal `Done_operation` vindo do coprocessador.

3. **Processamento pelo coprocessador**  
   - O coprocessador, ao detectar `Start = 1`, lê a instrução e executa a operação correspondente.  
   - Durante a execução, o coprocessador mantém `Done_operation = 0`.

4. **Conclusão da operação**  
   - Quando o coprocessador finaliza o processamento (por exemplo, multiplicação matricial ou empacotamento de bytes), ele coloca `Done_operation = 1`.  
   - Esse pulso indica ao HPS que a operação foi finalizada.

5. **Reset do ciclo**  
   - O HPS detecta `Done_operation = 1` e zera o sinal `Start` (`Start = 0`).  
   - Após limpar `Start`, o HPS  fica pronto para enviar a próxima instrução.

Esse fluxo garante sincronização precisa entre ambos os módulos, evitando condições de corrida e garantindo que cada instrução seja processada individualmente antes do envio da próxima.  

