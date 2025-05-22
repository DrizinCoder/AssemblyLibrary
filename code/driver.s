.global driver
.type driver, %function

.global mmap_setup
.type mmap_setup, %function

.section .data
    mapped_addr:    .word 0  @ Stores the mapped address

    matrixA:        .word 0
    matrixB:        .word 0
    matrixR:        .word 0
    matrix_size:    .word 0
    opcode:         .word 0
    
    file_descriptor: .word 0
    dev_mem:        .asciz "/dev/mem"


    welcome_msg: .ascii "\nWelcome to Driver\n"
    welcome_msg_len = . - welcome_msg

.section .text
driver:
    push {r4-r8, lr}  @ Save registers
    
    @ Store parameters
    ldr r4, =matrixA
    str r0, [r4]             @ matrixA pointer
    ldr r4, =matrixB
    str r1, [r4]             @ matrixB pointer
    ldr r4, =matrixR
    str r2, [r4]             @ matrixR pointer
    ldr r4, =matrix_size
    str r3, [r4]

    ldr r4, [sp, #24]        @ Opcode
    ldr r5, =opcode
    str r4, [r5]

    @ bl mmap_setup
    bl load
    bl operation
    bl store
    @ bl mmap_cleanup

    pop {r4-r8, lr} 
    bx lr

load:
    push {r1-r12, lr}

    ldr r0, =matrix_size
    ldr r0, [r0]

    cmp r0, #0
    beq load2x2

    cmp r0, #1
    beq load3x3

    cmp r0, #2
    beq load4x4

    cmp r0, #3
    beq load5x5

    pop {r1-r12, lr}
    bx lr

load2x2:

    ldr r7, =matrixA             @ Ponteiro para matrixA
    ldr r7, [r7]

    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#0}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #5                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#0}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    ldr r7, =matrixB             @ Ponteiro para matrixB
    ldr r7, [r7]

    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#0}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #5                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#0}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    pop {r1-r12, lr}
    bx lr

load3x3:
    ldr r7, =matrixA             @ Ponteiro para matrixA
    ldr r7, [r7]
    
    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #6                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #8]            @ num1 = matrixA[0] (com extensão de sinal)
    mov r1, #0                   @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    ldr r7, =matrixB             @ Ponteiro para matrixB
    ldr r7, [r7]

    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #6                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, 8]            @ num1 = matrixA[0] (com extensão de sinal)
    mov r1, #0                   @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#1}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    pop {r1-r12, lr}
    bx lr

load4x4:
    @ Enviando matriz A
    ldr r7, =matrixA             @ Ponteiro para matrixA
    ldr r7, [r7]

    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #5                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #7                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #8]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #9]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Sexta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #10]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #11]           @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    @ Sétima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #12]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #13]           @ num2 = matrixA[1]
    mov r2, #15                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Oitava Instrução
    push {r0-r3}

    ldrsb r0, [r7, #14]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #15]           @ num2 = matrixA[1]
    mov r2, #17                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3} 

    @ Enviando matriz B
    ldr r7, =matrixB             @ Ponteiro para matrixB
    ldr r7, [r7]

    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #5                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #7                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #8]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #9]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Sexta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #10]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #11]           @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    @ Sétima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #12]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #13]           @ num2 = matrixA[1]
    mov r2, #15                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Oitava Instrução
    push {r0-r3}

    ldrsb r0, [r7, #14]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #15]           @ num2 = matrixA[1]
    mov r2, #17                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#2}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    pop {r1-r12, lr}
    bx lr

load5x5:
    ldr r7, =matrixA             @ Ponteiro para matrixA
    ldr r7, [r7]

    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #4                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #6                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #8]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #9]           @ num2 = matrixA[1]
    mov r2, #8                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Sexta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #10]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #11]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    @ Sétima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #12]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #13]           @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Oitava Instrução
    push {r0-r3}

    ldrsb r0, [r7, #14]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #15]           @ num2 = matrixA[1]
    mov r2, #14                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Nona Instrução
    push {r0-r3}

    ldrsb r0, [r7, #16]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #17]           @ num2 = matrixA[1]
    mov r2, #16                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Decima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #18]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #19]           @ num2 = matrixA[1]
    mov r2, #18                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Onze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #20]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #21]           @ num2 = matrixA[1]
    mov r2, #20                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Doze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #22]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #23]           @ num2 = matrixA[1]
    mov r2, #22                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Treze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #24]           @ num1 = matrixA[0] (com extensão de sinal)
    mov r1, #0                    @ num2 = 0  
    mov r2, #24                   @ Position
    mov r3, #0                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}


    @ Enviando matriz B

    ldr r7, =matrixB             @ Ponteiro para matrixB
    ldr r7, [r7]

    @ Primeira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #1]           @ num2 = matrixA[1]
    mov r2, #0                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Segunda Instrução
    push {r0-r3}

    ldrsb r0, [r7, #2]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #3]           @ num2 = matrixA[1]
    mov r2, #2                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Terceira Instrução
    push {r0-r3}

    ldrsb r0, [r7, #4]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #5]           @ num2 = matrixA[1]
    mov r2, #4                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quarta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #6]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #7]           @ num2 = matrixA[1]
    mov r2, #6                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Quinta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #8]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #9]           @ num2 = matrixA[1]
    mov r2, #8                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Sexta Instrução
    push {r0-r3}

    ldrsb r0, [r7, #10]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #11]           @ num2 = matrixA[1]
    mov r2, #10                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    @ Sétima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #12]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #13]           @ num2 = matrixA[1]
    mov r2, #12                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Oitava Instrução
    push {r0-r3}

    ldrsb r0, [r7, #14]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #15]           @ num2 = matrixA[1]
    mov r2, #14                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Nona Instrução
    push {r0-r3}

    ldrsb r0, [r7, #16]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #17]           @ num2 = matrixA[1]
    mov r2, #16                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Decima Instrução
    push {r0-r3}

    ldrsb r0, [r7, #18]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #19]           @ num2 = matrixA[1]
    mov r2, #18                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Onze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #20]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #21]           @ num2 = matrixA[1]
    mov r2, #20                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Doze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #22]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r1, [r7, #23]           @ num2 = matrixA[1]
    mov r2, #22                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}

    @ Treze Instrução
    push {r0-r3}

    ldrsb r0, [r7, #24]           @ num1 = matrixA[0] (com extensão de sinal)
    mov r1, #0                    @ num2 = 0  
    mov r2, #24                   @ Position
    mov r3, #1                   @ Matriz Destino
    push {#0}                    @ Opcode
    push {#3}                    @ Tamanho da matriz
    bl send_instruction
    add sp, sp, #8               @ Remove os elementos da pilha

    pop {r0-r3}
    
    pop {r1-r12, lr}
    bx lr

operation:
    push {r0, lr}

    ldr r0, =opcode
    ldrsb r0, [r0]

    cmp r0, #0x1
    beq sum

    cmp r0, #0x2
    beq subtract
    
    cmp r0, #0x3
    beq multiplication

    cmp r0, #0x4
    beq ops

    cmp r0, #0x5
    beq tps

    cmp r0, #0x6
    beq mui

    cmp r0, #0x7
    beq det

    pop {r0, lr}
    bx lr

sum:
    mov r1, #0x1
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

subtract:

    mov r1, #0x2
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

multiplication:

    mov r1, #0x3
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

ops:

    mov r1, #0x4
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

tps:

    mov r1, #0x5
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

mui:
    
    mov r1, #0x6
    mov r3, #0x10000000
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr

det:

    mov r1, #0x7
    mov r3, #0x10000000
    
    ldr r2, =matrix_size
    ldrsb r2, [r2]

    orr r3, r3, r2, lsl #4
    orr r3, r3, r1

    ldr r11, =mapped_addr
    ldr r11, [r11]

    str r3, [r11]

    bl wait_for_done 

    pop {r0, lr}
    bx lr


store:
    push {lr}

    ldr r0, =matrix_size
    ldr r0, [r0]

    cmp r0, #0
    beq store2x2

    cmp r0, #1
    beq store3x3

    cmp r0, #2
    beq store4x4

    cmp r0, #3
    beq store5x5

    pop {lr}
    bx lr

store2x2:
    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11]
    ldr r0, =matrixR             @ Ponteiro para matrixR
    ldr r0, [r0]

    mov r2, #0x8
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r2            @ Opcode (1000)

    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    ldr r1, [r11, #0x10]         @ Carrega os 4 bytes do offset 0x10
    strb r1, [r0, #0]            @ Armazena byte 0 na posição 0

    lsr r1, r1, #8               @ Desloca para pegar o próximo byte
    strb r1, [r0, #1]            @ Armazena byte 1 na posição 1

    lsr r1, r1, #8               @ Desloca para pegar o próximo byte
    strb r1, [r0, #2]            @ Armazena byte 2 na posição 2

    lsr r1, r1, #8               @ Desloca para pegar o último byte
    strb r1, [r0, #3]            @ Armazena byte 3 na posição 3

    pop {lr}
    bx lr

store3x3:
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r4, #1                   @ Tamanho

    mov r5, #0                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #0]            

    lsr r1, r1, #8               
    strb r1, [r0, #1]            

    lsr r1, r1, #8               
    strb r1, [r0, #2]            

    lsr r1, r1, #8               
    strb r1, [r0, #3]            

    mov r5, #6                   @ Posição
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #4]            

    lsr r1, r1, #8               
    strb r1, [r0, #5]            

    lsr r1, r1, #8               
    strb r1, [r0, #6]            

    lsr r1, r1, #8               
    strb r1, [r0, #7]            

    mov r5, #12                  @ Posição              
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         

    lsr r1, r1, #8               
    lsr r1, r1, #8               
    lsr r1, r1, #8               @ Deslocamentos necessários para pegar o MSB

    strb r1, [r0, #8]            

    pop {lr}
    bx lr

store4x4:
    @ 0, 5, 10, 15
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r4, #2                   @ Tamanho

    mov r5, #0                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]        

    strb r1, [r0, #0]              
    lsr r1, r1, #8               
    strb r1, [r0, #1]            
    lsr r1, r1, #8               
    strb r1, [r0, #2]            
    lsr r1, r1, #8               
    strb r1, [r0, #3]       

    mov r5, #5                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #4]            

    lsr r1, r1, #8               
    strb r1, [r0, #5]            

    lsr r1, r1, #8               
    strb r1, [r0, #6]            

    lsr r1, r1, #8               
    strb r1, [r0, #7]   

    mov r5, #10                  @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #8]            

    lsr r1, r1, #8               
    strb r1, [r0, #9]            

    lsr r1, r1, #8               
    strb r1, [r0, #10]           

    lsr r1, r1, #8               
    strb r1, [r0, #11]   

    mov r5, #15                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #12]           

    lsr r1, r1, #8               
    strb r1, [r0, #13]            

    lsr r1, r1, #8               
    strb r1, [r0, #14]           

    lsr r1, r1, #8               
    strb r1, [r0, #15]  

    pop {lr}
    bx lr

.ltorg

store5x5:
    @ 0, 4, 8, 12, 16, 20, 24
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r4, #3                   @ Tamanho

    mov r5, #0                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]        

    strb r1, [r0, #0]              
    lsr r1, r1, #8               
    strb r1, [r0, #1]            
    lsr r1, r1, #8               
    strb r1, [r0, #2]            
    lsr r1, r1, #8               
    strb r1, [r0, #3]       

    mov r5, #4                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7
    orr r10, r10, r4, lsl #4  
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #4]            

    lsr r1, r1, #8               
    strb r1, [r0, #5]            

    lsr r1, r1, #8               
    strb r1, [r0, #6]            

    lsr r1, r1, #8               
    strb r1, [r0, #7]   

    mov r5, #8                  @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #8]            

    lsr r1, r1, #8               
    strb r1, [r0, #9]            

    lsr r1, r1, #8               
    strb r1, [r0, #10]           

    lsr r1, r1, #8               
    strb r1, [r0, #11]   

    mov r5, #12                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #12]           

    lsr r1, r1, #8               
    strb r1, [r0, #13]            

    lsr r1, r1, #8               
    strb r1, [r0, #14]           

    lsr r1, r1, #8               
    strb r1, [r0, #15]  

    mov r5, #16                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #16]           

    lsr r1, r1, #8               
    strb r1, [r0, #17]            

    lsr r1, r1, #8               
    strb r1, [r0, #18]           

    lsr r1, r1, #8               
    strb r1, [r0, #19] 

    mov r5, #20                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #20]           

    lsr r1, r1, #8               
    strb r1, [r0, #21]            

    lsr r1, r1, #8               
    strb r1, [r0, #22]           

    lsr r1, r1, #8               
    strb r1, [r0, #23] 

    mov r5, #24                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r4, lsl #4 
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         
    strb r1, [r0, #24]           

    pop {lr}
    bx lr

welcome:
    mov r7, #4                        @ syscall write
    mov r0, #1                        @ stdout
    ldr r1, =welcome_msg
    mov r2, #welcome_msg_len
    svc #0

    bx lr

wait_for_done:
    push {r0-r11, lr}                 @ Preserva o registrador de retorno

    ldr r0, =mapped_addr              @ Carrega o endereço base
    ldr r0, [r0]

wait_loop:
    ldr r1, [r0, #0x30]               @ Carrega o valor do registrador

    and r2, r1, #0x08                 @ Isola o bit 3 (4º bit)
    cmp r2, #0x08                     @ Compara com 0x08
    beq restart                       @ Se igual, sair do loop

    b wait_loop                       @ Volta para o início do loop

restart:
    mov r3, #0x00000000    

    ldr r11, =mapped_addr             @ Carregamos o endereço da FPGA
    ldr r11, [r11]
    str r3, [r11, #0x0]               @ Envia para FPGA

    pop {r0-r11, lr}

    bx lr

@ Procedimento utilizado para montar uma instrução e enviar ao coprocessador
@ ---------------------------------------------------------------------------------
@ Parâmetros:
@ r0 - num1
@ r1 - num2
@ r2 - position
@ r3 - mat_target
@ r4 - mat_size (Via Stack)
@ r5 - opcode (Via Stack)
@----------------------------------------------------------------------------------
send_instruction:
    push{r0-r7, lr}
    
    ldr r4, [sp, #36] @Carrega Mat_size
    ldr r5, [sp, #40] @Carrega opcode
    ldr r7, =mapped_addr
    ldr r7, [r7]

    @ Máscara de bits para garantir que os valores tem as informações corretas
    and r0, r0, #0xFF
    and r1, r1, #0xFF
    and r2, r2, #0x1F
    and r3, r3, #0x1
    and r4, r4, #0x3
    and r5, r5, #0xF

    @ Constrói a instrução
    mov r6, #0x10000000
    orr r6, r6, r0, lsl #20
    orr r6, r6, r1, lsl #12
    orr r6, r6, r2, lsl #7
    orr r6, r6, r3, lsl #6
    orr r6, r6, r4, lsl #4
    orr r6, r6, r5

    str r6, [r7]
    bl wait_for_done

    pop{r0-r7, lr}


@ -----------------------------------------------------------------------------------------------

mmap_setup:
    push {r0-r7, lr}
    
    @ Open /dev/mem
    ldr r0, =dev_mem
    mov r1, #2          @ O_RDWR
    mov r7, #5          @ syscall open
    svc #0
    
    cmp r0, #0
    blt fail_open
    
    ldr r1, =file_descriptor
    str r0, [r1]
    
    mov r0, #0          
    ldr r1, =0x1000     
    mov r2, #3          
    mov r3, #1          
    ldr r4, =file_descriptor
    ldr r4, [r4]        
    ldr r5, =0xFF200    
    mov r7, #192        
    svc #0
    
    cmn r0, #1          
    beq fail_mmap

    ldr r1, =mapped_addr
    str r0, [r1]
    
    pop {r0-r7, lr}
    bx lr

fail_open:
    mov r0, #-1

    bx lr

fail_mmap:
    @ Close file if mmap failed
    ldr r0, =file_descriptor
    ldr r0, [r0]
    mov r7, #6          @ syscall close
    svc #0
    
    mov r0, #-1

    bx lr
