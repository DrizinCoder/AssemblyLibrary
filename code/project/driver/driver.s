.global _start

_start:
    @ Mostra o menu inicial
    bl  print_menu

    @ Le a opcao do usuario
    bl  read_input

    @ Compara a opcao
    ldr r1, =input_buffer
    ldrb r0, [r1]           @ Carrega o primeiro byte
    cmp r0, #'1'            @ Opcao '1'?
    beq op1                 @ Se sim, vai para op1
    cmp r0, #'0'            @ Opcao '0'?
    beq exit_program        @ Se sim, sai
    b _start                @ Se nao, reinicia

op1:
    @ Operacao: Escolher tamanho da matriz
    b   choice_size        

choice_size:
    @ Pede o tamanho da matriz
    bl  print_prompt_size
    bl  read_input

    @ Verifica se a entrada e valida
    ldr r1, =input_buffer
    ldrb r0, [r1]           @ Carrega o digito
    ldrb r2, [r1, #1]       @ Carrega o segundo byte
    cmp r2, #'\n'           @ Verifica se e enter
    bne invalid_size       @ Se nao for, invalido

    @ Converte ASCII para numero
    sub r0, r0, #'0'

    @ Verifica se esta entre 2 e 5
    cmp r0, #2
    blt invalid_size
    cmp r0, #5
    bgt invalid_size

    @ Armazena o tamanho em r5
    mov r5, r0

    @ Mostra confirmacao
    bl  print_valid_size
    b   choice_operation    @ Vai para escolha de operacao

choice_operation:
    @ Mostra menu de operacoes
    bl  print_operation_menu
    bl  read_input

    @ Verifica a opcao
    ldr r1, =input_buffer
    ldrb r0, [r1]           @ Carrega o digito
    ldrb r2, [r1, #1]       @ Carrega o segundo byte
    cmp r2, #'\n'           @ Verifica se e enter
    bne invalid_operation   @ Se nao for, invalido

    @ Converte ASCII para numero
    sub r0, r0, #'0'

    @ Verifica se esta entre 1 e 7
    cmp r0, #1
    blt invalid_operation
    cmp r0, #7
    bgt invalid_operation

    @ Armazena o tamanho em r5
    mov r6, r0

    @ Operacao valida, seguir para preenchimento
    b   fill_matrix

fill_matrix:
    @ multiplicacao de NxN | N = row num = col num
    mul r0, r5, r5
    mov r5, r0

    add r0, r5, #'0'
    ldr r1, =char_buffer 
    strb r0, [r1]       
    
    @ Syscall para imprimir r5
    mov r0, #1          
    ldr r1, =char_buffer 
    mov r2, #1         
    mov r7, #4         
    swi #0
 
    b _start


invalid_operation:
    @ Mostra mensagem de erro
    bl  print_invalid_operation
    b   choice_operation    @ Tenta novamente

invalid_size:
    @ Mostra mensagem de erro
    bl  print_invalid_size
    b   choice_size        @ Tenta novamente

exit_program:
    @ Syscall exit (1)
    mov r7, #1
    mov r0, #0
    swi 0

@ ====== Funcoes Auxiliares ======
print_menu:
    mov r7, #4
    mov r0, #1
    ldr r1, =menu_msg
    mov r2, #menu_msg_len
    swi 0
    bx  lr

print_prompt_size:
    mov r7, #4
    mov r0, #1
    ldr r1, =prompt_size_msg
    mov r2, #prompt_size_msg_len
    swi 0
    bx  lr

print_operation_menu:
    mov r7, #4
    mov r0, #1
    ldr r1, =operation_menu_msg
    mov r2, #operation_menu_msg_len
    swi 0
    bx  lr

print_valid_size:
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

print_invalid_size:
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_size_msg
    mov r2, #invalid_size_msg_len
    swi 0
    bx  lr

print_invalid_operation:
    mov r7, #4
    mov r0, #1
    ldr r1, =invalid_operation_msg
    mov r2, #invalid_operation_msg_len
    swi 0
    bx  lr

read_input:
    mov r7, #3
    mov r0, #0
    ldr r1, =input_buffer
    mov r2, #2
    swi 0
    bx  lr

@ ====== Dados ======
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

char_buffer: 
    .byte 0   
