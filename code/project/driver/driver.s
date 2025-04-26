    .section .text
    .global driver

driver:
    // Parâmetros (conforme AAPCS):
    // R0: ponteiro para matrix1
    // R1: ponteiro para matrix2
    // R2: ponteiro para matrixr (resultado)
    // R3: opcode (0x01 a 0x06, 0x17, 0x1F, 0x27, 0x2F)
    // R4: size (via stack, acessado em [SP])

    // Salvar registradores
    PUSH {R4-R11, LR}

    // Carregar size do stack
    LDR R4, [SP, #36]         // SP + 9*4 (R4-R11, LR = 9 registradores)

    // Definir endereços base da FPGA (ajustar conforme o sistema)
    LDR R5, =MATRIX_BASE      // Endereço para dados das matrizes (0xC0000000)
    LDR R6, =CONTROL_REG      // Registrador de controle (0xC00000C0)
    LDR R7, =STATUS_REG       // Registrador de status (0xC00000C4)
    LDR R8, =RESULT_BASE      // Endereço para resultado (0xC0000080)

    // Salvar ponteiros
    MOV R9, R0                // Ponteiro matrix1
    MOV R10, R1               // Ponteiro matrix2
    MOV R11, R2               // Ponteiro matrixr

    // Calcular número de transferências: (size * size + 1) / 2
    MUL R0, R4, R4            // size * size
    ADD R0, R0, #1            // size * size + 1
    LSR R0, R0, #1            // (size * size + 1) / 2
    MOV R12, R0               // Contador de transferências

    // Mapear size para comando de carregamento de matrix1
    MOV R0, #0x10             // Base para matrix1 (2x2)
    SUB R1, R4, #2            // size - 2
    MOV R2, #8                // Incremento por tamanho (0x10 -> 0x18 -> 0x20 -> 0x28)
    MUL R1, R1, R2            // (size - 2) * 8
    ADD R0, R0, R1            // Comando: 0x10 (2x2), 0x18 (3x3), 0x20 (4x4), 0x28 (5x5)
    STR R0, [R6]              // Enviar comando de carregamento de matrix1

    // Enviar matrix1
send_matrix1:
    CMP R12, #0
    BEQ wait_matrix1
    LDRB R0, [R9], #1         // Elemento A[i]
    LDRB R1, [R9], #1         // Elemento A[i+1]
    LSL R0, R0, #24           // A[i] para bits [31:24]
    LSL R1, R1, #16           // A[i+1] para bits [23:16]
    ORR R0, R0, R1            // Combina A[i] e A[i+1]
    STR R0, [R5], #4          // Escreve no endereço da FPGA e incrementa
    SUBS R12, R12, #1
    BNE send_matrix1

wait_matrix1:
    DSB                       // Garantir que escritas foram concluídas
poll_matrix1:
    LDR R0, [R7]              // Lê registrador de status
    CMP R0, #0x01             // Verifica se terminou (0x01)
    BNE poll_matrix1          // Continua polling

    // Verificar se é opcode que usa apenas matrix1 (4, 5, 7)
    CMP R3, #0x04             // Oposta
    BEQ send_operation
    CMP R3, #0x05             // Transposição
    BEQ send_operation
    CMP R3, #0x17             // Determinante 2x2
    BEQ send_operation
    CMP R3, #0x1F             // Determinante 3x3
    BEQ send_operation
    CMP R3, #0x27             // Determinante 4x4
    BEQ send_operation
    CMP R3, #0x2F             // Determinante 5x5
    BEQ send_operation

    // Mapear size para comando de carregamento de matrix2
    MOV R0, #0x50             // Base para matrix2 (2x2)
    SUB R1, R4, #2            // size - 2
    MOV R2, #8                // Incremento por tamanho (0x50 -> 0x58 -> 0x60 -> 0x68)
    MUL R1, R1, R2            // (size - 2) * 8
    ADD R0, R0, R1            // Comando: 0x50 (2x2), 0x58 (3x3), 0x60 (4x4), 0x68 (5x5)
    STR R0, [R6]              // Enviar comando de carregamento de matrix2

    // Recalcular número de transferências
    MUL R0, R4, R4            // size * size
    ADD R0, R0, #1            // size * size + 1
    LSR R0, R0, #1            // (size * size + 1) / 2
    MOV R12, R0               // Contador de transferências

    // Enviar matrix2
send_matrix2:
    CMP R12, #0
    BEQ wait_matrix2
    LDRB R0, [R10], #1        // Elemento B[i]
    LDRB R1, [R10], #1        // Elemento B[i+1]
    LSL R0, R0, #24           // B[i] para bits [31:24]
    LSL R1, R1, #16           // B[i+1] para bits [23:16]
    ORR R0, R0, R1            // Combina B[i] e B[i+1]
    STR R0, [R5], #4          // Escreve no endereço da FPGA e incrementa
    SUBS R12, R12, #1
    BNE send_matrix2

wait_matrix2:
    DSB                       // Garantir que escritas foram concluídas
poll_matrix2:
    LDR R0, [R7]              // Lê registrador de status
    CMP R0, #0x01             // Verifica se terminou (0x01)
    BNE poll_matrix2          // Continua polling

send_operation:
    // Enviar opcode da operação
    STR R3, [R6]              // Escreve opcode no registrador de controle

    // Polling para esperar conclusão da operação
poll_operation:
    LDR R0, [R7]              // Lê registrador de status
    CMP R0, #0x01             // Verifica se terminou (0x01)
    BNE poll_operation        // Continua polling

    // Verificar se é determinante (opcodes 0x17, 0x1F, 0x27, 0x2F)
    CMP R3, #0x17             // Determinante 2x2
    BEQ read_determinant
    CMP R3, #0x1F             // Determinante 3x3
    BEQ read_determinant
    CMP R3, #0x27             // Determinante 4x4
    BEQ read_determinant
    CMP R3, #0x2F             // Determinante 5x5
    BEQ read_determinant

    // Ler resultado (size * size elementos)
    MUL R0, R4, R4            // size * size
    ADD R0, R0, #1            // size * size + 1
    LSR R0, R0, #1            // (size * size + 1) / 2
    MOV R12, R0               // Contador de transferências
    B read_matrix

read_determinant:
    // Ler apenas 1 elemento (escalar)
    MOV R12, #1               // 1 transferência

read_matrix:
    CMP R12, #0
    BEQ end
    // Ler palavra de 32 bits da FPGA
    LDR R0, [R8], #4          // Lê do endereço de resultado e incrementa
    // Extrair 2 elementos (ignorar bits [31:16])
    LSR R1, R0, #8            // Elemento 1 (bits [15:8])
    AND R2, R0, #0xFF         // Elemento 2 (bits [7:0])
    // Armazenar no array de resultado
    STRB R1, [R11], #1        // Armazena elemento 1
    STRB R2, [R11], #1        // Armazena elemento 2
    // Decrementar contador e loop
    SUBS R12, R12, #1
    BNE read_matrix

end:
    // Restaurar registradores e retornar
    POP {R4-R11, PC}

    // Endereços da FPGA (ajustar conforme o sistema)
    .section .data
MATRIX_BASE:   .word 0xC0000000
CONTROL_REG:   .word 0xC00000C0
STATUS_REG:    .word 0xC00000C4
RESULT_BASE:   .word 0xC0000080