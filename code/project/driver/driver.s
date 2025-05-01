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
    
    sub r0, r0, #'0' @ Converte ASCII para numero

    cmp r0, #2
    blt invalid_size
    cmp r0, #5
    bgt invalid_size

    ldr r1, =size_matrix @ Carrega o endereço em r1
    strb r0, [r1] @ Armazena no endereço carregado em r1

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

    sub r0, r0, #'0'

    cmp r0, #1
    blt invalid_operation
    cmp r0, #7
    bgt invalid_operation
    
    ldr r1, =operation_current @ Carrega o endereço em r1
    strb r0, [r1] @ Armazena no endereço carregado em r1

    b   fill_matrix

fill_matrix:
    ldr r1, =size_matrix
    ldrb r5, [r1]
    ldr r1, =operation_current
    ldrb r6, [r1]

    mul r0, r5, r5 @ NxN = quantidade de valores para as matrizes

    ldr r1, =square_size_matrix 
    strb r0, [r1]       
 
    b fill_matrix_A

fill_matrix_A:

    b fill_matrix_B

fill_matrix_B:

    b execute_operation

execute_operation:

    b free_matrix

free_matrix:
    b _start
    

invalid_operation: @ Mensagem de erro da opcao de operacao
    bl  print_invalid_operation
    b   choice_operation   

invalid_size: @ Mensagem de erro da opcao de tamanho
    bl  print_invalid_size 
    b   choice_size        

exit_program: @ Syscall de saida (1)
    mov r7, #1
    mov r0, #0
    swi 0

@ ====== Funcoes Auxiliares ======
print_menu: @ Exibi menu principal
    mov r7, #4
    mov r0, #1
    ldr r1, =menu_msg
    mov r2, #menu_msg_len
    swi 0
    bx  lr

print_prompt_size: @ Exibi selecao do tamanho da matriz
    mov r7, #4
    mov r0, #1
    ldr r1, =prompt_size_msg
    mov r2, #prompt_size_msg_len
    swi 0
    bx  lr

print_operation_menu: @ Exibi menu com as operacoes suportadas
    mov r7, #4
    mov r0, #1
    ldr r1, =operation_menu_msg
    mov r2, #operation_menu_msg_len
    swi 0
    bx  lr

print_valid_size: @ Mensagem de confirmacao de tamanho selecionado
    mov r7, #4
    mov r0, #1
    ldr r1, =valid_size_msg
    mov r2, #valid_size_msg_len
    swi 0
    
    ldr r1, =input_buffer
    mov r7, #4
    mov r0, #1
    mov r2, #1
    swi 0
    
    mov r7, #4
    mov r0, #1
    ldr r1, =newline
    mov r2, #1
    swi 0
    bx  lr

print_invalid_size: @ Mensagem de tamanho da matriz invalido
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_size_msg
    mov r2, #invalid_size_msg_len
    swi 0
    bx  lr

print_invalid_operation: @ Mensagem de valor de operacao invalido
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_operation_msg
    mov r2, #invalid_operation_msg_len
    swi 0
    bx  lr

read_input: @ Espaco para do texto atual em tela para user digitar
    mov r7, #3
    mov r0, #0
    ldr r1, =input_buffer
    mov r2, #2
    swi 0
    bx  lr


.data
    menu_msg:
        .ascii "\nMenu:\n1. Operações\n0. Sair\nEscolha: "
    menu_msg_len = . - menu_msg

    prompt_size_msg:
        .ascii "\nDigite o tamanho da matriz (2-5): "
    prompt_size_msg_len = . - prompt_size_msg

    operation_menu_msg:
        .ascii "\nOperações disponíveis:\n1. Soma\n2. Subtração\n3. Multiplicação\n4. Escalar\n5. Oposta\n6. Transposta\n7. Determinante\nEscolha: "
    operation_menu_msg_len = . - operation_menu_msg

    valid_size_msg:
        .ascii "\nTamanho definido: "
    valid_size_msg_len = . - valid_size_msg

    invalid_size_msg:
        .ascii "\nTamanho invalido! Digite um valor entre 2 e 5.\n"
    invalid_size_msg_len = . - invalid_size_msg

    invalid_operation_msg:
        .ascii "\nOperação inválida! Digite um valor entre 1 e 7.\n"
    invalid_operation_msg_len = . - invalid_operation_msg

    newline:
        .ascii "\n"

    input_buffer:
        .space 2                

    size_matrix:
        .byte 0

    square_size_matrix:
        .byte 0

    operation_current:
        .byte 0