.global _start

.section .text

_start:

    @ --- abre arquivo /dev/mem ---
    ldr r0, =dev_mem
    mov r1, #2
    mov r7, #5
    svc #0

    @ --- Verifica abertura do arquivo ---
    cmp r0, #0
    blt fail_open

    @ --- Salva o file descriptor ---
    ldr r1, =file_descriptor
    str r0, [r1]

    @ --- syscall mmpa ---
    mov r4, r0
    mov r0, #0
    mov r1, #1000
    mov r2, #3
    mov r3, #1
    ldr r5, =0xFF200000
    mov r7, #192
    svc #0

    @ --- Verifica mapeamento da memória ---
    cmp r0, #-1
    beq fail_mmap

    @ --- Salve o Endereço base mapeado ---
    ldr r1, =mmapped_address
    str r0, [r1]

    @ --- Menu ---
    bl  print_menu
    bl  read_input

    ldr r1, =input_buffer_2
    ldr r1, =input_buffer_6
    ldrb r0, [r1]           
    cmp r0, #'1'            
    beq choice_size                 
    cmp r0, #'0'   
    beq exit_program 
    b _start

fail_open:
    mov r0, #-1
    mov r7, #1
    mov r0, #68
    svc #0

fail_mmap:
    mov r0, #-1
    mov r7, #1
    mov r0, #4
    svc #0

choice_size:
    bl  print_prompt_size
    bl  read_input

    ldr r1, =input_buffer_2
    ldr r1, =input_buffer_6
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

    ldr r1, =input_buffer_2
    ldr r1, =input_buffer_6
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

    ldr r1, =square_size_matrix
    ldr r4, [r1]           @ Quantidade de valores
    mov r3, #0             @ Contador inicializado em zero


fill_loop_A:
    push {r4}                  @ Preserva r4 para evitar corrupção
    ldr r1, =square_size_matrix
    ldr r4, [r1]               @ Recarrega r4 para garantir integridade
    cmp r3, r4                 @ Compara contador (r3) com tamanho total (r4)
    bge fill_loop_A_end        @ Se r3 >= r4, vai para fill_loop_B

    mov r7, #4                 @ syscall write
    mov r0, #1                 @ stdout
    ldr r1, =prompt_input_value_A
    mov r2, #prompt_input_value_A_len
    svc #0

    ldr r1, =input_buffer_6
    mov r2, #6
    mov r0, #0
clear_buffer_A:
    strb r0, [r1], #1
    subs r2, r2, #1
    bne clear_buffer_A

    mov r7, #3                 @ syscall read
    mov r0, #0                 @ stdin
    ldr r1, =input_buffer_6
    mov r2, #6
    svc #0

    @ --- Converte a entrada para inteiro ---
    push {r3}                  @ Preserva r3 antes de chamar a função
    ldr r0, =input_buffer_6
    bl string_to_int_8bit      @ Retorna em r5
    pop {r3}                   @ Restaura r3

    @ --- Armazena o valor na matriz A ---
    ldr r0, =matrix_A_ptr
    ldr r0, [r0]               @ Carrega endereço base da matriz A
    strb r5, [r0, r3]          @ Armazena o byte na posição r3

    @ --- Incrementa o contador e repete ---
    add r3, r3, #1
    pop {r4}                   @ Restaura r4
    b fill_loop_A

fill_loop_A_end:
    pop {r4}                   @ Restaura r4 antes de sair
    b fill_loop_B

fill_loop_B:
    mov r3, #0                 @ RESETA O CONTADOR PARA 0
fill_loop_B_start:
    push {r4}                  @ Preserva r4
    ldr r1, =square_size_matrix
    ldr r4, [r1]               @ Recarrega r4
    cmp r3, r4                 @ Compara contador (r3) com tamanho total (r4)
    bge fill_loop_B_end        @ Se r3 >= r4, vai para execute_operation

    @ --- Imprime o prompt para o valor da matriz B ---
    mov r7, #4                 @ syscall write
    mov r0, #1                 @ stdout
    ldr r1, =prompt_input_value_B
    mov r2, #prompt_input_value_B_len
    svc #0

    @ --- Limpa o buffer de entrada ---
    ldr r1, =input_buffer_6
    mov r2, #6
    mov r0, #0
clear_buffer_B:
    strb r0, [r1], #1
    subs r2, r2, #1
    bne clear_buffer_B

    @ --- Lê a entrada do usuário ---
    mov r7, #3                 @ syscall read
    mov r0, #0                 @ stdin
    ldr r1, =input_buffer_6
    mov r2, #6
    svc #0

    @ --- Converte a entrada para inteiro ---
    push {r3}                  @ Preserva r3
    ldr r0, =input_buffer_6
    bl string_to_int_8bit      @ Retorna em r5
    pop {r3}                   @ Restaura r3

    @ --- Armazena o valor na matriz B ---
    ldr r0, =matrix_B_ptr
    ldr r0, [r0]               @ Carrega endereço base da matriz B
    strb r5, [r0, r3]          @ Armazena o byte na posição r3

    @ --- Incrementa o contador e repete ---
    add r3, r3, #1
    pop {r4}                   @ Restaura r4
    b fill_loop_B_start

fill_loop_B_end:
    pop {r4}                   @ Restaura r4
    b execute_operation

string_to_int_8bit:
    push {r3, r4, r8, lr}      @ Preserva r3, r4, r8 e lr
    mov r1, #0                 @ Inicializa resultado (r1)
    mov r2, #0                 @ Sinal: 0=positivo, 1=negativo
    mov r3, #10                @ Base decimal

    ldrb r4, [r0], #1          @ Lê o primeiro caractere
    cmp r4, #'-'               @ Verifica se é negativo
    bne check_digits
    mov r2, #1                 @ Marca como negativo
    ldrb r4, [r0], #1          @ Lê o próximo caractere

check_digits:
    cmp r4, #'0'               @ Verifica se é dígito (ASCII '0'-'9')
    blt invalid_input
    cmp r4, #'9'
    bgt invalid_input
    sub r4, r4, #'0'           @ Converte ASCII para inteiro
    mul r8, r1, r3             @ Multiplica por 10
    mov r1, r8
    add r1, r1, r4             @ Adiciona o dígito
    ldrb r4, [r0], #1          @ Lê próximo caractere
    cmp r4, #10                @ Verifica se é '\n' (fim da entrada)
    bne check_digits

    @ --- Aplica o sinal (se negativo) ---
    cmp r2, #1
    bne check_range
    rsb r1, r1                 @ Inverte o sinal

check_range:
    @ --- Verifica se está dentro de -128 a 127 ---
    cmp r1, #127
    bgt invalid_input
    cmp r1, #-128
    blt invalid_input

    mov r5, r1                 @ Retorna o valor em r5
    pop {r3, r4, r8, pc}

invalid_input:
    mov r7, #4
    mov r0, #1
    ldr r1, =prompt_input_value_invalid
    mov r2, #prompt_input_value_invalid_len
    svc #0
    mov r5, #0                 @ Retorna 0 em caso de erro
    pop {r3, r4, r8, pc}

execute_operation:
    mov r7, #4              @ Chamada de sistema para write (4)
    mov r0, #1              @ File descriptor (1 = stdout)
    ldr r1, =valid_fill_matrix_msg
    mov r2, #valid_fill_matrix_msg_len
    svc #0                  @ Faz a chamada de sistema para imprimir a mensagem

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
    
    ldr r1, =input_buffer_2
    ldr r1, =input_buffer_6
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
    ldr r1, =input_buffer_2
    ldr r1, =input_buffer_6
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

    prompt_input_value_A: .ascii "\nDigite o valor no vetor A: "
    prompt_input_value_A_len = . - prompt_input_value_A

    prompt_input_value_B: .ascii "\nDigite o valor do vetor B: "
    prompt_input_value_B_len = . - prompt_input_value_B

    prompt_input_value_invalid: .ascii "\nValor incorreto!\n"
    prompt_input_value_invalid_len = . - prompt_input_value_invalid

    newline: .ascii "\n"

    input_buffer_2: .space 2
    input_buffer_6: .space 6

    size_matrix: .byte 0
    square_size_matrix: .word 0
    operation_current: .byte 0

    matrix_A_ptr: .word 0
    matrix_B_ptr: .word 0

    file_descriptor: .word 0
    mmapped_address: .word 0
    dev_mem: .ascii "/dev/mem"
