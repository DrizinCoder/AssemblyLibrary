# 📝 Testes em Assembly x86-64 (Estudo Independente)

**Nota importante**: Este projeto é um _estudo isolado_ sobre arquitetura x86-64 e **não faz parte do projeto principal** que utiliza ARMv7 para comunicação com FPGA na DE1-SoC. Aqui exploramos especificamente o processador Intel Core i7-6600U para fins didáticos.

## 🚧 Objetivo do Projeto

Estudo autônomo para entender:

- Integração entre C e assembly x86-64
- Convenções da System V AMD64 ABI
- Diferenças entre arquiteturas CISC (x86) e RISC (ARM)

## ⚠️ Diferenças para o Projeto Principal (ARMv7/DE1-SoC)

| Característica   | Este Projeto (x86-64) | Projeto Principal (ARMv7)    |
| ---------------- | --------------------- | ---------------------------- |
| Arquitetura      | CISC (Intel i7-6600U) | RISC (ARM Cortex-A9)         |
| Uso              | Estudo acadêmico      | Comunicação com FPGA         |
| Sintaxe Assembly | AT&T (GNU as)         | ARM (arm-linux-gnueabihf-as) |
| Registradores    | %eax, %edi, %esi      | R0, R1, R2                   |
| ABI              | System V AMD64        | ARM EABI                     |

## 🛠️ Como Este Estudo Auxilia no Projeto ARMv7

1. **Conceitos transferíveis**:

   - Lógica de integração C/assembly
   - Manipulação de registradores
   - Controle de fluxo básico

2. **Diferenças críticas**:
   - ARMv7 usa instruções mais simples e fixas
   - Convenções de chamada distintas

## 🚀 Como Executar (x86-64)

1. **Pré-requisitos**:

   - Linux instalado (testado no Ubuntu 20.04+)
   - Processador Intel/AMD x86-64
   - Pacote `build-essential` instalado:

```bash
  sudo apt-get update && sudo apt-get install build-essential
```

2. **Compilação e Execução**:

```bash
 # Navegue até o diretório do projeto
 user@host: /home/user/.../AssemblyLibray/code/examples
```

```bash
 # Compile o programa
 make run
```
