// DEFINIÇÕES DE ENDEREÇOS E CONSTANTES
/* Endereços PIO (Parallel Input/Output) */
.equ PIO_BASE,         0xFF200      @ Endereço base do PIO
.equ IN_MATRIX,        0xFF200      @ Envio de matriz (4 bytes)
.equ OUT_MATRIX,       0xFF204      @ Recebimento de matriz (4 bytes)
.equ CTRL_HPS_FPGA,    0xFF208      @ Controle HPS->FPGA (1 byte)
.equ CTRL_FPGA_HPS,    0xFF209      @ Status FPGA->HPS (1 byte)
.equ IN_INSTRUCTION,   0xFF20A      @ Envio de instruções (1 byte)

/* Máscaras de bits para CTRL_HPS_FPGA (HPS → FPGA) */
.equ START_MASK,       0x01    @ Bit 0: Start operation (1 << 0)
.equ OPCODE_BIT1,      0x02    @ Bit 1: Operation code bit 1 (1 << 1)
.equ OPCODE_BIT2,      0x04    @ Bit 2: Operation code bit 2 (1 << 2)
.equ READ_REQ_MASK,    0x08    @ Bit 3: Read Request (1 << 3)
.equ WRITE_VALID_MASK, 0x10    @ Bit 4: Write Valid (1 << 4)
.equ RESET_MASK,       0x20    @ Bit 5: Reset (1 << 5)  

/* Máscaras de bits para CTRL_FPGA_HPS (FPGA → HPS) */
.equ OVERFLOW_MASK,    0x01    @ Bit 0: Overflow (1 << 0)
.equ READ_VALID_MASK,  0x02    @ Bit 1: Read Valid (1 << 1)
.equ WRITE_OK_MASK,    0x04    @ Bit 2: Write OK (1 << 2)
.equ DONE_MASK,        0x08    @ Bit 3: Done (1 << 3)

/* Códigos de instrução */
.equ LOAD_A2,          0x10
.equ LOAD_B2,          0x50
.equ LOAD_A3,          0x18
.equ LOAD_B3,          0x58
.equ LOAD_A4,          0x20
.equ LOAD_B4,          0x60
.equ LOAD_A5,          0x28
.equ LOAD_B5,          0x68
.equ OP_ADD,           0x01            @ Soma
.equ OP_SUB,           0x02            @ Subtração
.equ OP_MUL,           0x03            @ Multiplicação
.equ OP_OPO,           0x04            @ Oposta
.equ OP_TRA,           0x05            @ Transposta
.equ OP_SCA,           0x06            @ Escalar
.equ OP_DE2,           0x17            @ Determinante 2x2
.equ OP_DE3,           0x1F            @ Determinante 3x3
.equ OP_DE4,           0x27            @ Determinante 4x4
.equ OP_DE5,           0x2F            @ Determinante 5x5

/* Tamanhos */
.equ MATRIX_SIZE_2x2,  4               @ 2x2 = 4 words (16 bytes)
.equ MATRIX_SIZE_3x3,  9               @ 3x3 = 9 words (36 bytes)
.equ MATRIX_SIZE_4x4,  16              @ 4x4 = 16 words (64 bytes)
.equ MATRIX_SIZE_5x5,  25              @ 5x5 = 25 words (100 bytes)

/* Syscalls */
.equ SYS_EXIT,         1
.equ SYS_READ,         3
.equ SYS_WRITE,        4
.equ SYS_OPEN,         5
.equ SYS_MMAP2,        192
.equ SYS_BRK,          45
.equ STDIN,            0
.equ STDOUT,           1

// SEÇÃO DE DADOS
.section .data
/* Variáveis para mapeamento de memória */
file_descriptor:    .word 0         @ Armazena o descritor de arquivo
mmapped_address:    .word 0         @ Armazena o endereço mapeado
dev_mem:            .asciz "/dev/mem"  @ Caminho do dispositivo de memória

/* Buffers para matrizes */
matrix_A_ptr:    .word 0               @ Ponteiro para matriz A
matrix_B_ptr:    .word 0               @ Ponteiro para matriz B
result_buffer:   .space 100            @ Buffer para resultado (suporta até 5x5)

/* Mensagens */
menu_msg:        .asciz "\nMenu:\n1. Operações\n0. Sair\nEscolha: "
menu_msg_len = . - menu_msg

size_prompt:     .asciz "\nTamanho da matriz (2-5): "
size_prompt_len = . - size_prompt

operation_menu:  .asciz "\nOperações disponíveis:\n1. Soma\n2. Subtração\n3. Multiplicação\n4. Escalar\n5. Oposta\n6. Transposta\n7. Determinante 2x2\n8. Determinante 3x3\n9. Determinante 4x4\n0. Determinante 5x5\nEscolha: "
operation_menu_len = . - operation_menu

invalid_input: .ascii "\nEntrada inválida. Por favor, tente novamente!\n"
invalid_input_len = . - invalid_input

mmap_error: .ascii "\nErro: Não foi possível abrir /dev/mem\n"
mmap_error_len = . - mmap_error

overflow_msg:    .asciz "\nAVISO: Overflow detectado!\n"
overflow_msg_len = . - overflow_msg

result_msg:      .asciz "\nResultado:\n"
result_msg_len = . - result_msg

newline:         .asciz "\n"
newline_len = . - newline

space:           .asciz " "
space_len = . - space

/* Variáveis de estado */
size_matrix:     .byte 0
current_op:      .byte 0

/* Buffer de entrada */
input_buffer:    .space 2

// CÓDIGO PRINCIPAL
.section .text
.global _start

_start:
    bl init_memory

main_loop:
    /* Mostra menu principal */
    bl show_menu
    bl read_input
    
    /* Processa escolha */
    ldr r1, =input_buffer
    ldrb r0, [r1]
    cmp r0, #'1'
    beq operation_flow
    cmp r0, #'0'
    beq exit_program
    b main_loop

operation_flow:
    /* Seleciona tamanho da matriz */
    bl select_matrix_size

    /* Seleciona operação */
    bl select_operation

    /* Preenche matrizes */
    bl fill_matrix_A
    bl fill_matrix_B
    
        
    /* Volta ao menu */
    b main_loop

exit_program:
    /* Sai do programa */
    mov r7, #SYS_EXIT
    mov r0, #0
    svc #0

// FUNÇÕES PRINCIPAIS
/* Inicialização */
init_memory:
    push {r4-r7, lr}

    /* --- Abre /dev/mem para acesso à memória física --- */
    ldr r0, =dev_mem         @ Carrega endereço da string "/dev/mem"
    mov r1, #2              
    mov r7, #SYS_OPEN        @ Syscall open()
    svc #0

    /* --- Verifica se o arquivo foi aberto corretamente --- */
    cmp r0, #0
    blt mmap_fail            @ Se retorno < 0, houve erro

    /* --- Armazena o file descriptor --- */
    ldr r1, =file_descriptor
    str r0, [r1]

    /* --- Configuração do mmap2 --- */
    mov r4, r0               @ Preserva file descriptor em r4
    mov r0, #0               @ Endereço sugerido (NULL = deixar kernel escolher)
    mov r1, #4096            @ Tamanho mapeado: 1 página (4KB)
    mov r2, #0x3             @ Proteção: PROT_READ | PROT_WRITE
    mov r3, #0x1             @ Flags: MAP_SHARED

    /* --- Argumentos adicionais para mmap2 --- */
    ldr r5, =PIO_BASE        @ Endereço físico base da FPGA (PIO)
    push {r5}                @ Offset físico (empilha)
    mov r5, #0               @ Offset adicional
    push {r5}

    /* --- Chama mmap2 --- */
    mov r7, #SYS_MMAP2       @ Syscall mmap2 (192)
    svc #0

    /* --- Limpa a pilha (remove 2 words) --- */
    add sp, sp, #8

    /* --- Verifica se o mapeamento foi bem-sucedido --- */
    cmp r0, #-1              @ Verifica erro (MAP_FAILED)
    beq mmap_fail

    /* --- Armazena o endereço virtual mapeado --- */
    ldr r1, =mmapped_address
    str r0, [r1]

    /* --- Aloca memória para as matrizes --- */
    /* Aloca matriz A */
    mov r7, #SYS_BRK
    mov r0, #0               @ Consulta break atual
    svc #0
    ldr r1, =matrix_A_ptr
    str r0, [r1]

    /* Aloca matriz B */
    svc #0                   @ Chama brk novamente
    ldr r1, =matrix_B_ptr
    str r0, [r1]

    pop {r4-r7, pc}          @ Retorna


/* Falha no mapeamento */
mmap_fail:
    /* --- Tratamento de erro --- */
    ldr r1, =mmap_error
    mov r2, #mmap_error_len
    mov r7, #SYS_WRITE
    svc #0

    /* --- Sai com código de erro --- */
    mov r7, #SYS_EXIT
    mov r0, #1
    svc #0

/* Mostra menu principal */
show_menu:
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =menu_msg
    ldr r2, =menu_msg_len
    svc #0
    pop {pc}

// FUNÇÕES AUXILIARES
/* Lê entrada do usuário */
read_input:
    push {lr}
    mov r7, #SYS_READ
    mov r0, #STDIN
    ldr r1, =input_buffer
    mov r2, #2              @ Lê 2 bytes (1 char + newline)
    svc #0
    pop {pc}

/* Seleciona tamanho da matriz */
select_matrix_size:
    push {lr}
    
    /* Mostra prompt */
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =size_prompt
    ldr r2, =size_prompt_len
    svc #0
    
    /* Lê entrada */
    bl read_input
    
    /* Converte para número e valida */
    ldr r1, =input_buffer
    ldrb r0, [r1]
    sub r0, r0, #'0'        @ Converte ASCII para número
    cmp r0, #2
    blt invalid_size
    cmp r0, #5
    bgt invalid_size
    
    /* Armazena tamanho */
    ldr r1, =size_matrix
    strb r0, [r1]
    
    pop {pc}
    
invalid_size:
    /* Tamanho inválido - pede novamente */
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =invalid_input
    ldr r2, =invalid_input_len
    svc #0
    pop {pc}

/* Seleciona operação */
select_operation:
    push {lr}
    
    /* Mostra menu de operações */
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =operation_menu
    ldr r2, =operation_menu_len
    svc #0
    
    /* Lê entrada */
    bl read_input
    
    /* Converte para número e valida */
    ldr r1, =input_buffer
    ldrb r0, [r1]
    sub r0, r0, #'0'        @ Converte ASCII para número
    cmp r0, #0
    blt invalid_op
    cmp r0, #9
    bgt invalid_op
    
    /* Armazena operação */
    ldr r1, =current_op
    add r0, r0, #2          @ Converte para código de operação (3=ADD, 4=SUB, 5=MUL)
    strb r0, [r1]
    
    pop {pc}
    
invalid_op:
    /* Operação inválida - pede novamente */
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =invalid_input
    ldr r2, =invalid_input_len
    svc #0
    pop {pc}

/* Preenche matriz A com valores */
fill_matrix_A:
    push {r4-r7, lr}
    ldr r4, =matrix_A_ptr
    ldr r4, [r4]
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mul r5, r5, r5          @ Calcula N²
    
    mov r6, #0              @ Contador
fill_A_loop:
    cmp r6, r5
    bge fill_A_done
    
    /* Preenche com valores incrementais (1, 2, 3, ...) */
    add r7, r6, #1          @ Valor = índice + 1
    str r7, [r4, r6, lsl #2]
    
    add r6, r6, #1
    b fill_A_loop

fill_A_done:
    pop {r4-r7, pc}

/* Preenche matriz B com valores */
fill_matrix_B:
    push {r4-r7, lr}
    ldr r4, =matrix_B_ptr
    ldr r4, [r4]
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mul r5, r5, r5          @ Calcula N²
    
    mov r6, #0              @ Contador
fill_B_loop:
    cmp r6, r5
    bge fill_B_done
    
    /* Preenche com valores decrementais partindo de N² */
    mov r7, r5
    sub r7, r7, r6          @ Valor = N² - índice
    str r7, [r4, r6, lsl #2]
    
    add r6, r6, #1
    b fill_B_loop

fill_B_done:
    pop {r4-r7, pc}