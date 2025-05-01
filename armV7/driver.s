.global _start
.section .data
    string_1:   .asciz "\nDigite n1:"
    string_2:   .asciz "\nDigite n2:"
    string_3:   .asciz  "\nN1:"
    string_4:   .asciz  "\nN2:"
    string_5:   .asciz  "\nResult: "
    break_line: .asciz "\n"
    dev_mem:    .asciz "/dev/mem"
    input:      .space 4
    num1:       .byte 0
    num2:       .byte 0
    result:     .space 4    @ Buffer for ASCII result

.section .text
_start:
    @ --- Leitura do primeiro número ---
    @ --- Escreve prompt (syscall 4) ---
    mov r7, #4              @ syscall write
    mov r0, #1              @ stdout
    ldr r1, =string_1
    mov r2, #11             @ Tamanho da string (contando com \n)
    svc #0

    @ --- Lê entrada (syscall 3) ---
    mov r7, #3              @ syscall read
    mov r0, #0              @ stdin
    ldr r1, =input
    mov r2, #4              @ Buffer de 4 bytes
    svc #0

    @ --- Converte para inteiro ---
    ldr r1, =input
    bl ascii_to_byte
    ldr r10, =num1
    strb r0, [r10]

    @ --- Imprime num1 (para debug) ---
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
    @ --- Escreve prompt (syscall 4) ---
    mov r7, #4
    mov r0, #1
    ldr r1, =string_2
    mov r2, #11
    svc #0

    @ --- Lê entrada (syscall 3) --- 
    mov r7, #3
    mov r0, #0
    ldr r1, =input
    mov r2, #4
    svc #0

    @ --- Converte para inteiro ---
    ldr r1, =input
    bl ascii_to_byte
    ldr r8, =num2
    strb r0, [r8]

    @ --- Imprime num2 (para debug) ---
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

     @ --- Syscall open ---
    ldr r0, =dev_mem
    mov r1, #2
    mov r7, #5
    svc #0

    cmp r0, #0
    blt fail_open

    @ --- syscall mmpa ---
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

    @ --- envia numero para FPGA via LW_AXI_Bridge ---
    ldrb r1, [r10]
    strb r1, [r0]          @Primeiro número
    ldrb r1, [r8]
    strb r1, [r0, #1]       @Segundo número

    @ --- Espera por resultado ---
wait_result:
    ldrb r1, [r0, #3]
    cmp r1, #1
    beq wait_result

    @ --- Lê resultado ---
    ldrb r1, [r0, #2]

    @ --- converte para ASCII ---
    ldr r0, =result
    bl byte_to_ascii

    @ --- Print result prompt ---
    mov r7, #4
    mov r0, #1
    ldr r1, =string_5
    mov r2, #10             @ Length of "\nResult: "
    svc #0

    @ --- Print result ---
    mov r7, #4
    mov r0, #1
    ldr r1, =result
    mov r2, #4              @ Max 4 bytes for ASCII number
    svc #0

    @ --- Print newline ---
    mov r7, #4
    mov r0, #1
    ldr r1, =break_line
    mov r2, #1
    svc #0

    @ --- Exit ---
    mov r7, #1
    mov r0, #0
    svc #0

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

@ --- Convert byte to ASCII ---
@ Input: r1 = byte to convert
@        r0 = address of output buffer
@ Output: ASCII string stored in buffer
byte_to_ascii:
    push {r4-r6, lr}
    mov r4, r0              @ Save buffer address
    mov r5, r1              @ Save input number
    mov r6, #0              @ Digit count

    @ Handle zero case
    cmp r5, #0
    bne convert_loop_ascii
    mov r1, #'0'
    strb r1, [r4]
    mov r1, #0
    strb r1, [r4, #1]
    b end_ascii

convert_loop_ascii:
    cmp r5, #0
    beq reverse_digits
    mov r0, r5
    mov r1, #10
    bl divide               @ r0 = quotient, r1 = remainder
    mov r5, r0              @ Update number
    add r1, r1, #'0'        @ Convert remainder to ASCII
    strb r1, [r4, r6]       @ Store digit
    add r6, r6, #1          @ Increment digit count
    b convert_loop_ascii

reverse_digits:
    mov r0, r4              @ Buffer start
    mov r1, r6              @ Length
    bl reverse_string
    mov r1, #0
    strb r1, [r4, r6]       @ Null-terminate
end_ascii:
    pop {r4-r6, lr}
    bx lr

@ --- Divide r0 by r1 ---
@ Returns: r0 = quotient, r1 = remainder
divide:
    mov r2, r0              @ Dividend
    mov r0, #0              @ Quotient
divide_loop:
    cmp r2, r1
    blt divide_end
    sub r2, r2, r1
    add r0, r0, #1
    b divide_loop
divide_end:
    mov r1, r2              @ Remainder
    bx lr

@ --- Reverse string ---
@ Input: r0 = string address, r1 = length
reverse_string:
    push {r2-r5, lr}
    mov r2, r0              @ Start of string
    add r3, r0, r1
    sub r3, r3, #1          @ End of string
reverse_loop:
    cmp r2, r3
    bge reverse_end
    ldrb r4, [r2]
    ldrb r5, [r3]
    strb r5, [r2]
    strb r4, [r3]
    add r2, r2, #1
    sub r3, r3, #1
    b reverse_loop
reverse_end:
    pop {r2-r5, lr}
    bx lr

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
