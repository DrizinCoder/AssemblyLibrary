.global _start

_start:
    @ Mostra o menu inicial
    bl  print_menu

    @ Lê a opção do usuário
    bl  read_input

    @ Compara a opção
    ldr r1, =input_buffer
    ldrb r0, [r1]           @ Carrega o primeiro byte do input
    cmp r0, #'1'            @ Opção '1'?
    beq op1                 @ Se sim, vai para op1
    cmp r0, #'2'            @ Opção '2'?
    beq exit_program        @ Se sim, sai
    b _start                @ Se não, reinicia

op1:
    @ --- Operação: Soma de dois números ---
    bl  print_msg_op1       @ Mostra mensagem da opção 1
    bl  exit_program        @ (Substitua por sua lógica customizada)

exit_program:
    @ Syscall exit (1)
    mov r7, #1
    mov r0, #0
    swi 0

@ ====== Funções Auxiliares ======
print_menu:
    @ Imprime o menu (syscall write = 4)
    mov r7, #4
    mov r0, #1
    ldr r1, =menu_msg
    mov r2, #menu_msg_len
    swi 0
    bx  lr                  @ Retorna para _start

print_msg_op1:
    @ Imprime mensagem da opção 1
    mov r7, #4
    mov r0, #1
    ldr r1, =op1_msg
    mov r2, #op1_msg_len
    swi 0
    bx  lr

read_input:
    @ Lê input do usuário (syscall read = 3)
    mov r7, #3
    mov r0, #0              @ stdin
    ldr r1, =input_buffer
    mov r2, #2              @ Lê 2 bytes (opção + Enter)
    swi 0
    bx  lr

@ ====== Dados ======
.data
menu_msg:
    .ascii "\nMenu:\n1. Fazer operação\n2. Sair\nEscolha: "
menu_msg_len = . - menu_msg

op1_msg:
    .ascii "\nVocê escolheu a opção 1!\n"
op1_msg_len = . - op1_msg

input_buffer:
    .space 2                @ Armazena a opção + \n