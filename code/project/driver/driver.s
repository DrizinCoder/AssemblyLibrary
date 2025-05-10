// DEFINIÇÕES DE ENDEREÇOS E CONSTANTES
 
/* Endereços PIO (Parallel Input/Output) */
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
