@ DEFINIÇÕES DE ENDEREÇOS E CONSTANTES
@ Endereços PIO (Parallel Input/Output) 
.equ PIO_BASE,         0xFF200      @ Endereço base do PIO
.equ IN_MATRIX,        0xFF200      @ Envio de matriz (4 bytes)
.equ OUT_MATRIX,       0xFF204      @ Recebimento de matriz (4 bytes)
.equ CTRL_HPS_FPGA,    0xFF208      @ Controle HPS->FPGA (1 byte)
.equ CTRL_FPGA_HPS,    0xFF209      @ Status FPGA->HPS (1 byte)
.equ IN_INSTRUCTION,   0xFF20A      @ Envio de instruções (1 byte)

@ Máscaras de bits para CTRL_HPS_FPGA (HPS → FPGA) 
.equ START_MASK,       0x01    @ Bit 0: Start operation (1 << 0)
.equ OPCODE_BIT1,      0x02    @ Bit 1: Operation code bit 1 (1 << 1)
.equ OPCODE_BIT2,      0x04    @ Bit 2: Operation code bit 2 (1 << 2)
.equ READ_REQ_MASK,    0x08    @ Bit 3: Read Request (1 << 3)
.equ WRITE_VALID_MASK, 0x10    @ Bit 4: Write Valid (1 << 4)
.equ RESET_MASK,       0x20    @ Bit 5: Reset (1 << 5)  

@ Máscaras de bits para CTRL_FPGA_HPS (FPGA → HPS) 
.equ OVERFLOW_MASK,    0x01    @ Bit 0: Overflow (1 << 0)
.equ READ_VALID_MASK,  0x02    @ Bit 1: Read Valid (1 << 1)
.equ WRITE_OK_MASK,    0x04    @ Bit 2: Write OK (1 << 2)
.equ DONE_MASK,        0x08    @ Bit 3: Done (1 << 3)

@ Códigos de instrução 
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

@ Tamanhos 
.equ MATRIX_SIZE_2x2,  4               @ 2x2 = 4 words (16 bytes)
.equ MATRIX_SIZE_3x3,  9               @ 3x3 = 9 words (36 bytes)
.equ MATRIX_SIZE_4x4,  16              @ 4x4 = 16 words (64 bytes)
.equ MATRIX_SIZE_5x5,  25              @ 5x5 = 25 words (100 bytes)

@ Syscalls 
.equ SYS_EXIT,         1
.equ SYS_READ,         3
.equ SYS_WRITE,        4
.equ SYS_OPEN,         5
.equ SYS_MMAP,         192
.equ SYS_BRK,          45
.equ STDIN,            0
.equ STDOUT,           1

@ SEÇÃO DE DADOS
.section .data
@ Variáveis para mapeamento de memória 
file_descriptor:    .word 0         @ Armazena o descritor de arquivo
mmapped_address:    .word 0         @ Armazena o endereço mapeado
dev_mem:            .asciz "/dev/mem"  @ Caminho do dispositivo de memória

@ Buffers para matrizes 
matrix_A_ptr:    .word 0               @ Ponteiro para matriz A
matrix_B_ptr:    .word 0               @ Ponteiro para matriz B
result_buffer:   .space 100            @ Buffer para resultado (suporta até 5x5)

@ Mensagens 
menu_msg:        .asciz "\nMenu:\n1. Operações\n0. Sair\nEscolha: "
menu_msg_len = . - menu_msg

size_prompt:     .asciz "\nTamanho da matriz (2-5): "
size_prompt_len = . - size_prompt

operation_menu:  .asciz "\nOperações disponíveis:\n1. Soma\n2. Subtração\n3. Multiplicação\n4. Escalar\n5. Oposta\n6. Transposta\n7. Determinante 2x2\n8. Determinante 3x3\n9. Determinante 4x4\n0. Determinante 5x5\nEscolha: "
operation_menu_len = . - operation_menu

invalid_input: .ascii "\nEntrada inválida. Por favor, tente novamente!\n"
invalid_input_len = . - invalid_input

open_file_error: .ascii "\nErro: Não foi possível abrir /dev/mem\n"
open_file_error_len = . - open_file_error

mmap_error: .ascii "\nErro: Não foi possível realizar mapeamento\n"
mmap_error_len = . - mmap_error

overflow_msg:    .asciz "\nAVISO: Overflow detectado!\n"
overflow_msg_len = . - overflow_msg

result_msg:      .asciz "\nResultado:\n"
result_msg_len = . - result_msg

newline:         .asciz "\n"
newline_len = . - newline

space:           .asciz " "
space_len = . - space

@ Variáveis de estado 
size_matrix:     .byte 0
current_op:      .byte 0

@ Buffer de entrada 
input_buffer:    .space 2

@ CÓDIGO PRINCIPAL
.section .text
.global _start

_start:
    bl init_memory
    bl alloc_memory

main_loop:
    @ Mostra menu principal 
    bl show_menu
    bl read_input
    
    @ Processa escolha 
    ldr r1, =input_buffer
    ldrb r0, [r1]
    cmp r0, #'1'
    beq operation_flow
    cmp r0, #'0'
    beq exit_program
    b main_loop

operation_flow:
    @ Seleciona tamanho da matriz 
    bl select_matrix_size

    @ Seleciona operação 
    bl select_operation

    @ Preenche matrizes 
    bl fill_matrix_A
    bl fill_matrix_B

    @ Envia matrizes para FPGA 
    bl send_matrix_A
    bl send_matrix_B

    @ Executa operação 
    bl execute_operation

    @ Recebe resultado 
    bl receive_result
    
    @ Mostra resultado 
    bl print_result
        
    @ Volta ao menu 
    b main_loop

exit_program:
    @ Sai do programa 
    mov r7, #SYS_EXIT
    mov r0, #0
    svc #0

@ FUNÇÕES PRINCIPAIS
@ Inicialização 
init_memory:
    push {r1-r7, lr}

    @  Abre /dev/mem 
    ldr r0, =dev_mem
    mov r1, #2     
    mov r2, #0              
    mov r7, #5              
    svc #0

    @ verifica se houve erro 
    cmp r0, #0
    blt open_fail

    @  Salva file descriptor 
    ldr r1, =file_descriptor
    str r0, [r1]

    @ Mapeia memória
    mov r0, #0              @ Endereço NULL (deixa kernel escolher)
    ldr r1, =0x1000         
    mov r2, #3              
    mov r3, #1              
    ldr r4, =file_descriptor
    ldr r4, [r4]            
    ldr r5, =0xFF200        @ Offset físico (ajuste conforme seu hardware)
    mov r7, #SYS_MMAP       @ mmap
    svc #0

    cmn r0, #1
    beq mmap_fail

    @ Verificação de funcionalidade  
    mov r1, #0x01            @ Valor para escrever nos leds
    str r1, [r0, #0x20]      @ Escreve no endereço mapeado

    pop {r1-r7, pc}          

@ Falha em abrir arquivo
open_fail:
    @  Tratamento de erro  
    ldr r1, =open_file_error
    mov r2, #open_file_error_len
    mov r7, #SYS_WRITE
    svc #0

    @  Sai com código de erro  
    mov r7, #SYS_EXIT
    mov r0, #1
    svc #0

@ Falha no mapeamento 
mmap_fail:
    @  Tratamento de erro  
    ldr r1, =mmap_error
    mov r2, #mmap_error_len
    mov r7, #SYS_WRITE
    svc #0

    @  Sai com código de erro  
    mov r7, #SYS_EXIT
    mov r0, #1
    svc #0

alloc_memory:
    @  Aloca memória para as matrizes  

    @ Aloca matriz A 
    mov r7, #SYS_BRK
    mov r0, #0               @ Consulta break atual
    svc #0
    ldr r1, =matrix_A_ptr
    str r0, [r1]

    @ Aloca matriz B 
    svc #0                   @ Chama brk novamente
    ldr r1, =matrix_B_ptr
    str r0, [r1]


@ Mostra menu principal 
show_menu:
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =menu_msg
    ldr r2, =menu_msg_len
    svc #0
    pop {pc}

@ FUNÇÕES AUXILIARES
@ Seleciona tamanho da matriz 
select_matrix_size:
    push {lr}
    
    @ Mostra prompt 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =size_prompt
    ldr r2, =size_prompt_len
    svc #0
    
    @ Lê entrada 
    bl read_input
    
    @ Converte para número e valida 
    ldr r1, =input_buffer
    ldrb r0, [r1]
    sub r0, r0, #'0'        @ Converte ASCII para número
    cmp r0, #2
    blt invalid_size
    cmp r0, #5
    bgt invalid_size
    
    @ Armazena tamanho 
    ldr r1, =size_matrix
    strb r0, [r1]
    
    pop {pc}
    
invalid_size:
    @ Tamanho inválido - pede novamente 
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =invalid_input
    ldr r2, =invalid_input_len
    svc #0
    pop {pc}

@ Seleciona operação 
select_operation:
    push {lr}
    
    @ Mostra menu de operações 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =operation_menu
    ldr r2, =operation_menu_len
    svc #0
    
    @ Lê entrada 
    bl read_input
    
    @ Converte para número e valida 
    ldr r1, =input_buffer
    ldrb r0, [r1]
    sub r0, r0, #'0'        @ Converte ASCII para número
    cmp r0, #0
    blt invalid_op
    cmp r0, #9
    bgt invalid_op
    
    @ Armazena operação 
    ldr r1, =current_op
    add r0, r0, #2          @ Converte para código de operação (3=ADD, 4=SUB, 5=MUL)
    strb r0, [r1]
    
    pop {pc}
    
invalid_op:
    @ Operação inválida - pede novamente 
    push {lr}
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =invalid_input
    ldr r2, =invalid_input_len
    svc #0
    pop {pc}

@ Preenche matriz A com valores 
fill_matrix_A:
    push {r1-r7, lr}
    ldr r4, =matrix_A_ptr
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mov r9, r5
    mul r5, r9, r9          @ Calcula N²
    
    mov r6, #0              @ Contador
fill_A_loop:
    cmp r6, r5
    bge fill_A_done
    
    @ Preenche com valores incrementais (1, 2, 3, ...) 
    add r7, r6, #1          @ Valor = índice + 1
    str r7, [r4, r6, lsl #2]
    
    add r6, r6, #1
    b fill_A_loop

fill_A_done:
    pop {r1-r7, pc}

@ Preenche matriz B com valores 
fill_matrix_B:
    push {r1-r7, lr}
    ldr r4, =matrix_B_ptr
    ldr r5, =size_matrix
    mov r9, r5
    mul r5, r9, r9          @ Calcula N²
    
    mov r6, #0              @ Contador
fill_B_loop:
    cmp r6, r5
    bge fill_B_done
    
    @ Preenche com valores decrementais partindo de N² 
    mov r7, r5
    sub r7, r7, r6          @ Valor = N² - índice
    str r7, [r4, r6, lsl #2]
    
    add r6, r6, #1
    b fill_B_loop

fill_B_done:
    pop {r1-r7, pc}

@ FUNÇÕES DE COMUNICAÇÃO COM FPGA

@ Envia matriz A para FPGA 
send_matrix_A:
    push {r1-r7, lr}
    ldr r4, =matrix_A_ptr
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mov r9, r5
    mul r5, r9, r9          @ Calcula N²
    
    mov r6, #0              @ Contador
send_A_loop:
    cmp r6, r5
    bge send_A_done
    
    @ Carrega 4 bytes 
    ldr r7, [r4, r6, lsl #2]
    
    @ Escreve no PIO 
    ldr r0, =IN_MATRIX
    str r7, [r0]
    
    @ Sinaliza Write Valid 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    orr r1, r1, #WRITE_VALID_MASK
    strb r1, [r0]
    
    @ Aguarda Write OK 
wait_A_write_ok:
    ldr r0, =CTRL_FPGA_HPS
    ldrb r1, [r0]
    tst r1, #WRITE_OK_MASK
    beq wait_A_write_ok
    
    @ Limpa Write Valid 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    bic r1, r1, #WRITE_VALID_MASK
    strb r1, [r0]
    
    add r6, r6, #1          @ Próxima word
    b send_A_loop

send_A_done:
    @ Envia instrução LOAD_A 
    ldr r1, =size_matrix
    ldrb r1, [r1]

    cmp r1, #2
    moveq r0, #LOAD_A2
    cmp r1, #3
    moveq r0, #LOAD_A3
    cmp r1, #4
    moveq r0, #LOAD_A4
    cmp r1, #5
    moveq r0, #LOAD_A5

    bl send_instruction
    pop {r1-r7, pc}

@ Envia matriz B para FPGA 
send_matrix_B:
    push {r1-r7, lr}
    ldr r4, =matrix_B_ptr
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mov r9, r5
    mul r5, r9, r9          @ Calcula N²
    
    mov r6, #0              @ Contador
send_B_loop:
    cmp r6, r5
    bge send_B_done
    
    @ Carrega 4 bytes 
    ldr r7, [r4, r6, lsl #2]
    
    @ Escreve no PIO 
    ldr r0, =IN_MATRIX
    str r7, [r0]
    
    @ Sinaliza Write Valid 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    orr r1, r1, #WRITE_VALID_MASK
    strb r1, [r0]
    
    @ Aguarda Write OK 
wait_B_write_ok:
    ldr r0, =CTRL_FPGA_HPS
    ldrb r1, [r0]
    tst r1, #WRITE_OK_MASK
    beq wait_B_write_ok
    
    @ Limpa Write Valid 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    bic r1, r1, #WRITE_VALID_MASK
    strb r1, [r0]
    
    add r6, r6, #1          @ Próxima word
    b send_B_loop

send_B_done:
    @ Envia instrução LOAD_B 
    ldr r1, =size_matrix
    ldrb r1, [r1]

    cmp r1, #2
    moveq r0, #LOAD_B2
    cmp r1, #3
    moveq r0, #LOAD_B3
    cmp r1, #4
    moveq r0, #LOAD_B4
    cmp r1, #5
    moveq r0, #LOAD_B5
    
    bl send_instruction
    pop {r1-r7, pc}

@ Envia instrução com handshake 
send_instruction:
    push {lr}
    @ Escreve instrução 
    ldr r1, =IN_INSTRUCTION
    strb r0, [r1]
    
    @ Sinaliza Write Valid 
    ldr r1, =CTRL_HPS_FPGA
    ldrb r2, [r1]
    orr r2, r2, #WRITE_VALID_MASK
    strb r2, [r1]
    
    @ Aguarda Write OK 
wait_instr_ok:
    ldr r1, =CTRL_FPGA_HPS
    ldrb r2, [r1]
    tst r2, #WRITE_OK_MASK
    beq wait_instr_ok
    
    @ Limpa Write Valid 
    ldr r1, =CTRL_HPS_FPGA
    ldrb r2, [r1]
    bic r2, r2, #WRITE_VALID_MASK
    strb r2, [r1]
    
    pop {pc}

@ Executa operação na FPGA 
execute_operation:
    push {lr}
    @ Envia código da operação 
    ldr r0, =current_op
    ldrb r0, [r0]
    bl send_instruction
    
    @ Sinaliza START 
    ldr r0, =CTRL_HPS_FPGA
    mov r1, #START_MASK
    strb r1, [r0]
    
    @ Aguarda DONE 
wait_operation_done:
    ldr r0, =CTRL_FPGA_HPS
    ldrb r1, [r0]
    tst r1, #DONE_MASK
    beq wait_operation_done
    
    @ Limpa START 
    ldr r0, =CTRL_HPS_FPGA
    mov r1, #0
    strb r1, [r0]
    
    pop {pc}

@ Recebe resultado da FPGA 
receive_result:
    push {r4-r7, lr}
    ldr r4, =OUT_MATRIX
    ldr r5, =size_matrix
    ldrb r5, [r5]
    mov r9, r5
    mul r5, r9, r9          @ Calcula N²
    ldr r6, =result_buffer
    
    mov r7, #0              @ Contador
receive_loop:
    cmp r7, r5
    bge receive_done
    
    @ Sinaliza Read Request 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    orr r1, r1, #READ_REQ_MASK
    strb r1, [r0]
    
    @ Aguarda Read Valid 
wait_read_valid:
    ldr r0, =CTRL_FPGA_HPS
    ldrb r1, [r0]
    tst r1, #READ_VALID_MASK
    beq wait_read_valid
    
    @ Lê 4 bytes 
    ldr r0, [r4]
    str r0, [r6, r7, lsl #2]
    
    @ Limpa Read Request 
    ldr r0, =CTRL_HPS_FPGA
    ldrb r1, [r0]
    bic r1, r1, #READ_REQ_MASK
    strb r1, [r0]
    
    add r7, r7, #1
    b receive_loop

receive_done:
    @ Verifica overflow 
    ldr r0, =CTRL_FPGA_HPS
    ldrb r1, [r0]
    tst r1, #OVERFLOW_MASK
    beq no_overflow
    
    @ Mostra mensagem de overflow 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =overflow_msg
    ldr r2, =overflow_msg_len
    svc #0

no_overflow:
    pop {r4-r7, pc}


@ FUNÇÕES AUXILIARES
@ Lê entrada do usuário 
read_input:
    push {lr}
    mov r7, #SYS_READ
    mov r0, #STDIN
    ldr r1, =input_buffer
    mov r2, #2              @ Lê 2 bytes (1 char + newline)
    svc #0
    pop {pc}

@ Imprime resultado 
print_result:
    push {r4-r8, lr}
    ldr r4, =result_buffer
    ldr r5, =size_matrix
    ldrb r5, [r5]           @ Tamanho da matriz (N)
    
    @ Imprime cabeçalho 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =result_msg
    ldr r2, =result_msg_len
    svc #0
    
    mov r6, #0              @ Contador de linhas
    mov r7, #0              @ Contador de elementos
print_row_loop:
    cmp r6, r5
    bge print_done
    
    mov r8, #0              @ Contador de colunas
print_col_loop:
    cmp r8, r5
    bge print_row_end
    
    @ Calcula índice: (linha * N) + coluna 
    mul r0, r6, r5
    add r0, r0, r8
    ldr r1, [r4, r0, lsl #2] @ Carrega valor
    
    @ Converte número para string 
    sub sp, sp, #12         @ Reserva espaço na pilha
    mov r2, sp
    bl int_to_string
    
    @ Imprime número 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    mov r1, sp
    mov r2, #11             @ Tamanho máximo de um inteiro
    svc #0
    
    @ Imprime espaço 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =space
    ldr r2, =space_len
    svc #0
    
    add sp, sp, #12         @ Libera espaço da pilha
    add r8, r8, #1          @ Próxima coluna
    b print_col_loop

print_row_end:
    @ Imprime newline 
    mov r7, #SYS_WRITE
    mov r0, #STDOUT
    ldr r1, =newline
    ldr r2, =newline_len
    svc #0
    
    add r6, r6, #1          @ Próxima linha
    b print_row_loop

print_done:
    pop {r4-r8, pc}

@ Converte inteiro para string (simplificado) 
int_to_string:
    push {r4-r5, lr}
    mov r4, r1              @ Buffer de saída
    mov r5, #10             @ Divisor
    
    @ Verifica se é zero 
    cmp r0, #0
    bne not_zero
    mov r1, #'0'
    strb r1, [r4]
    mov r1, #0
    strb r1, [r4, #1]
    b conversion_done
    
not_zero:
    @ Converte dígitos 
    mov r1, #0              @ Contador de dígitos
convert_loop:
    cmp r0, #0
    beq reverse_digits
    
    udiv r2, r0, r5         @ Divide por 10
    mul r3, r2, r5
    sub r3, r0, r3          @ Resto
    add r3, r3, #'0'        @ Converte para ASCII
    
    @ Armazena dígito na pilha 
    push {r3}
    add r1, r1, #1
    mov r0, r2
    b convert_loop
    
reverse_digits:
    mov r2, #0              @ Contador

reverse_loop:
    cmp r2, r1
    bge conversion_done
    
    pop {r3}
    strb r3, [r4, r2]
    add r2, r2, #1
    b reverse_loop
    
conversion_done:
    @ Adiciona terminador nulo 
    mov r3, #0
    strb r3, [r4, r2]
    pop {r4-r5, pc}