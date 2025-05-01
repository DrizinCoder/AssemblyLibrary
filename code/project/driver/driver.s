.global _start

.section .text

_start:
    bl  print_menu
    bl  read_input

    ldr r1, =input_buffer
    ldrb r0, [r1]           
    cmp r0, #'1'            
    beq choice_size                 
    cmp r0, #'0'           
    beq exit_program       
    b _start

choice_size:
    bl  print_prompt_size
    bl  read_input

    ldr r1, =input_buffer
    ldrb r0, [r1]          
    ldrb r2, [r1, #1]      
    cmp r2, #'\n'          
    bne invalid_size       
    
    cmp r0, #'2'
    blt invalid_size
    cmp r0, #'5'
    bgt invalid_size
    
    sub r0, r0, #'0'
    ldr r1, =size_matrix
    strb r0, [r1]

    bl  print_valid_size
    b   choice_operation

choice_operation:
    bl  print_operation_menu
    bl  read_input

    ldr r1, =input_buffer
    ldrb r0, [r1]          
    ldrb r2, [r1, #1]      
    cmp r2, #'\n'          
    bne invalid_operation  
    
    cmp r0, #'1'
    blt invalid_operation
    cmp r0, #'7'
    bgt invalid_operation
    
    sub r0, r0, #'0'
    ldr r1, =operation_current
    strb r0, [r1]

    b   fill_matrix

fill_matrix:
    @ Calcula tamanho total (N²)
    ldr r1, =size_matrix
    ldrb r5, [r1]
    mul r0, r5, r5 
    ldr r1, =square_size_matrix 
    str r0, [r1]           @ Armazena como word (4 bytes)

    @ Aloca matriz A
    mov r7, #0x2D          @ syscall brk
    mov r0, #0             @ Consulta break atual
    svc #0
    ldr r1, =matrix_A_ptr
    str r0, [r1]           @ Salva endereço base
    ldr r2, =square_size_matrix
    ldr r2, [r2]           @ Carrega tamanho
    add r0, r0, r2         @ Novo break
    svc #0

    @ Aloca matriz B
    mov r7, #0x2D
    mov r0, #0
    svc #0
    ldr r1, =matrix_B_ptr
    str r0, [r1]
    ldr r2, =square_size_matrix
    ldr r2, [r2]
    add r0, r0, r2
    svc #0

    @ Preenche matriz A
    ldr r0, =matrix_A_ptr
    ldr r0, [r0]           @ Endereço base
    ldr r1, =square_size_matrix
    ldr r1, [r1]           @ Tamanho total
    mov r2, #0             @ Contador
fill_loop_A:
    cmp r2, r1
    bge fill_matrix_B
    add r3, r2, #1         @ Valor = índice + 1
    strb r3, [r0, r2]      @ Armazena byte
    add r2, r2, #1         @ Incrementa contador
    b fill_loop_A

fill_matrix_B:
    ldr r0, =matrix_B_ptr
    ldr r0, [r0]           @ Endereço base
    ldr r1, =square_size_matrix
    ldr r1, [r1]           @ Tamanho total
    mov r2, #0             @ Contador
fill_loop_B:
    cmp r2, r1
    bge execute_operation
    add r3, r2, #10        @ Valor = índice + 10
    strb r3, [r0, r2]      @ Armazena byte
    add r2, r2, #1         @ Incrementa contador
    b fill_loop_B

execute_operation:
    mov r7, #4
    mov r0, #1
    ldr r1, =valid_fill_matrix_msg
    mov r2, #valid_fill_matrix_msg_len
    svc #0

    b free_matrices

free_matrices:
    @ Libera matriz A
    ldr r0, =matrix_A_ptr
    ldr r0, [r0]
    mov r7, #0x2D
    svc #0

    @ Libera matriz B
    ldr r0, =matrix_B_ptr
    ldr r0, [r0]
    mov r7, #0x2D
    svc #0

    b _start

invalid_operation:
    bl  print_invalid_operation
    b   choice_operation

invalid_size:
    bl  print_invalid_size
    b   choice_size

exit_program:
    mov r7, #1
    mov r0, #0
    svc #0

@ Funções auxiliares
print_menu:
    mov r7, #4
    mov r0, #1
    ldr r1, =menu_msg
    mov r2, #menu_msg_len
    svc #0
    bx lr

print_prompt_size:
    mov r7, #4
    mov r0, #1
    ldr r1, =prompt_size_msg
    mov r2, #prompt_size_msg_len
    svc #0
    bx lr

print_operation_menu:
    mov r7, #4
    mov r0, #1
    ldr r1, =operation_menu_msg
    mov r2, #operation_menu_msg_len
    svc #0
    bx lr

print_valid_size:
    mov r7, #4
    mov r0, #1
    ldr r1, =valid_size_msg
    mov r2, #valid_size_msg_len
    svc #0
    
    ldr r1, =input_buffer
    mov r7, #4
    mov r0, #1
    mov r2, #1
    svc #0
    
    mov r7, #4
    mov r0, #1
    ldr r1, =newline
    mov r2, #1
    svc #0
    bx lr

print_invalid_size:
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_size_msg
    mov r2, #invalid_size_msg_len
    svc #0
    bx lr

print_invalid_operation:
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_operation_msg
    mov r2, #invalid_operation_msg_len
    svc #0
    bx lr

read_input:
    mov r7, #3
    mov r0, #0
    ldr r1, =input_buffer
    mov r2, #2
    svc #0
    bx lr

.section .data
menu_msg: .ascii "\nMenu:\n1. Operações\n0. Sair\nEscolha: "
menu_msg_len = . - menu_msg

prompt_size_msg: .ascii "\nDigite o tamanho da matriz (2-5): "
prompt_size_msg_len = . - prompt_size_msg

operation_menu_msg: .ascii "\nOperações disponíveis:\n1. Soma\n2. Subtração\n3. Multiplicação\n4. Escalar\n5. Oposta\n6. Transposta\n7. Determinante\nEscolha: "
operation_menu_msg_len = . - operation_menu_msg

valid_size_msg: .ascii "\nTamanho definido: "
valid_size_msg_len = . - valid_size_msg

invalid_size_msg: .ascii "\nTamanho inválido! Digite um valor entre 2 e 5.\n"
invalid_size_msg_len = . - invalid_size_msg

invalid_operation_msg: .ascii "\nOperação inválida! Digite um valor entre 1 e 7.\n"
invalid_operation_msg_len = . - invalid_operation_msg

valid_fill_matrix_msg: .ascii "\nPreenchimento realizado com sucesso!\n"
valid_fill_matrix_msg_len = . - valid_fill_matrix_msg

newline: 
    .ascii "\n"

input_buffer: .space 2
element_buffer: .space 2

size_matrix: .byte 0
square_size_matrix: .word 0
operation_current: .byte 0

matrix_A_ptr: .word 0
matrix_B_ptr: .word 0