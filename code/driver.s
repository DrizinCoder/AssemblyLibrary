.global driver
.type driver, %function

.section .data
    mapped_addr:    .word 0  @ Stores the mapped address

    matrixA:        .word 0
    matrixB:        .word 0
    matrixR:        .word 0
    matrix_size:    .word 0
    opcode:         .word 0
    

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

    ldr r4, [sp, #28]
    ldr r6, =mapped_addr     @ Endereço
    str r4, [r6]

    @ bl mmap_setup
    bl welcome
    bl load
    bl operation
    bl store
    @ bl mmap_cleanup

    pop {r4-r8, lr} 
    bx lr

load:
    push {lr}

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

    pop {lr}
    bx lr

load2x2:
    push {lr}

    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA

    ldr r0, =matrixA             @ Ponteiro para matrixA
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]

    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #5                   @ Position = 5
    mov r12, #0                  @ Mat. Siz = 00 (2x2), Opcode = 0000

    @ Primeira instrução (num1 e num2)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)

    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados

    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Segunda instrução (num3 e num4)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    ldr r0, =matrixB             @ Ponteiro para matrixB
    ldrsb r6, [r0, #0]           @ num1 = matrixB[0]
    ldrsb r7, [r0, #1]           @ num2 = matrixB[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixB[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixB[3]

    mov r3, #1                   @ Mat Targ = 1 (matriz B)
    mov r4, #0                   @ Position = 0
    mov r5, #5                   @ Position = 5

    @ Primeira instrução (num1 e num2)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Segunda instrução (num3 e num4)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    pop {lr}
    bx lr

load3x3:
    push {lr}

    pop {lr}
    bx lr

load4x4:
    push {lr}

    @ code ...

    pop {lr}
    bx lr

load5x5:
    push {lr}

    @ code ...

    pop {lr}
    bx lr

wait_for_done:
    push {r0-r3, lr}             @ Preserva o registrador de retorno

    ldr r0, =mapped_addr         @ Carrega o endereço base
    add r0, r0, #0x30            @ Adiciona offset 0x30

wait_loop:
    ldr r1, [r0]                 @ Carrega o valor do registrador

    and r2, r1, #0x08            @ Isola o bit 3 (4º bit)
    cmp r2, #0x08                @ Compara com 0x08
    beq done_ready               @ Se igual, sair do loop

    b wait_loop                  @ Volta para o início do loop

done_ready:
    bl restart

    pop {r0-r3, lr}              @ Restaura o registrador de retorno
    bx lr                        @ Retorna da função

restart:
    @  enviar restart
    mov r3, #0x00000000    

    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    str r10, [r11]               @ Envia para FPGA

    bx lr

operation:
    push {lr}

    @ code ...

    pop {lr}
    bx lr

store:
    push {lr}

    @ code ...

    pop {lr}
    bx lr

welcome:
    mov r7, #4        @ syscall write
    mov r0, #1        @ stdout
    ldr r1, =welcome_msg
    mov r2, #welcome_msg_len
    svc #0

    bx lr
