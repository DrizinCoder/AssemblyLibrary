.global _start
.section .data
    string_1:   .asciz "\nDigite n1:"
    string_2:   .asciz "\nDigite n2:"
    string_3:   .asciz  "\nN1:"
    string_4:   .asciz  "\nN2:"
    break_line: .asciz "\n"
    dev_mem: .asciz "/dev/mem"
    input:      .space 4
    num1:       .byte 0
    num2:       .byte 0

.section .text
_start:
    @ --- Leitura do primeiro número ---
    @ Escreve prompt (syscall 4)
    mov r7, #4              @ syscall write
    mov r0, #1              @ stdout
    ldr r1, =string_1
    mov r2, #11             @ Tamanho da string (contando com \n)
    svc #0

    @ Lê entrada (syscall 3)
    mov r7, #3              @ syscall read
    mov r0, #0              @ stdin
    ldr r1, =input
    mov r2, #4              @ Buffer de 4 bytes
    svc #0

    @ Converte para inteiro
    ldr r1, =input
    bl ascii_to_byte
    ldr r10, =num1
    strb r0, [r10]

    @ Imprime num1 (para debug)
    mov r7, #4
    mov r0, #1
    ldr r1, =string_3
    mov r2, #4
    svc #0

    mov r7, #4
    mov r0, #1
    ldr r1, =num1
    mov r2, #1
    svc #0

    @ --- Leitura do segundo número ---
    @ Escreve prompt (syscall 4)
    mov r7, #4
    mov r0, #1
    ldr r1, =string_2
    mov r2, #11
    svc #0

    @ Lê entrada (syscall 3)
    mov r7, #3
    mov r0, #0
    ldr r1, =input
    mov r2, #4
    svc #0

    @ Converte para inteiro
    ldr r1, =input
    bl ascii_to_byte
    ldr r8, =num2
    strb r0, [r8]

    @ Imprime num2 (para debug)
    mov r7, #4
    mov r0, #1
    ldr r1, =string_4
    mov r2, #4
    svc #0

    mov r7, #4
    mov r0, #1
    ldr r1, =num2
    mov r2, #1
    svc #0

     @ Syscall open
    ldr r0, =dev_mem
    mov r1, #2
    mov r7, #5
    svc #0

    cmp r0, #0
    blt fail_open

    @ syscall mmpa
    mov r0, #0
    mov r1, #1000
    mov r2, #3
    mov r3, #1
    mov r4, r0
    ldr r5, =0xFF200000
    mov r7, #192
    svc #0
    cmp r0, #-1
    beq fail_mmap

    @ envia numero para FPGA via LW_AXI_Bridge
    ldrb r1, [r10]
    strb r1, [r0]          @Primeiro número
    ldrb r1, [r8]
    strb r1, [r0, #1]       @Segundo número

    @ --- Quebra de linha final ---
    mov r7, #4
    mov r0, #1
    ldr r1, =break_line
    mov r2, #1              @ Apenas 1 byte (\n)
    svc #0

    @ --- Exit ---
    mov r7, #1              @ syscall exit
    mov r0, #0
    svc #0

@ --- Rotina de conversão ---
ascii_to_byte:
    mov r0, #0              @ Inicializa resultado
    mov r3, #10             @ Base decimal
convert_loop:
    ldrb r2, [r1], #1       @ Carrega caractere
    cmp r2, #10             @ Verifica se é \n
    beq end_convert
    cmp r2, #0              @ Verifica NULL terminator
    beq end_convert
    sub r2, r2, #'0'        @ Converte ASCII para inteiro
    mla r0, r0, r3, r2      @ r0 = (r0 * 10) + r2
    b convert_loop
end_convert:
    bx lr                   @ Retorna

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
