.global driver
.type driver, %function

.global mmap_setup
.type mmap_setup, %function

.global mmap_cleanup
.type mmap_cleanup, %function

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

    hex_chars: .ascii "0123456789ABCDEF"  @ Tabela de caracteres hexadecimais
    newline:   .ascii "\n"                @ Caractere de nova linha

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
    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11, #0x0]

    ldr r0, =matrixA             @ Ponteiro para matrixA
    ldr r0, [r0]
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] (com extensão de sinal)
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]

    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #5                   @ Position = 5
    mov r12, #0                  @ Mat. Siz = 00 (2x2), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    @ Primeira instrução (num1 e num2)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
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
    ldr r0, [r0]
    ldrsb r6, [r0, #0]           @ num1 = matrixB[0]
    ldrsb r7, [r0, #1]           @ num2 = matrixB[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixB[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixB[3]

    mov r3, #1                   @ Mat Targ = 1 (matriz B)
    mov r4, #0                   @ Position = 0
    mov r5, #5                   @ Position = 5
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

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

    pop {r1-r12, lr}
    bx lr

load3x3:
    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11]

    ldr r0, =matrixA             @ Ponteiro para matrixA
    ldr r0, [r0]
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]
    
    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 5
    mov r12, #0x10               @ Mat. Siz = 01 (3x3), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)
  
    @ Primeira instrução (num1 e num2)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
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

    ldrsb r6, [r0, #4]           @ num5 = matrixA[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixA[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixA[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixA[7]

    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #6                   @ Position = 6
    mov r5, #10                  @ Position = 10

    @ Terceira instrução (num5 e num6)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Quarta instrução (num7 e num8)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #12                  @ Position = 12
    ldrsb r6, [r0, #8]           @ num9 = matrixA[8] 
    mov r7, #0                   @ zero - valor para ir junto com num9
    
    @ Quinta instrução (num9 e zero)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    ldr r0, =matrixB             @ Ponteiro para matrixA
    ldr r0, [r0]
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]
    
    mov r3, #1                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 5
    mov r12, #0x10               @ Mat. Siz = 01 (3x3), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)
  
    @ Primeira instrução (num1 e num2)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
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

    ldrsb r6, [r0, #4]           @ num5 = matrixA[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixA[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixA[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixA[7]

    mov r3, #1                   @ Mat Targ = 0 (matriz A)
    mov r4, #6                   @ Position = 6
    mov r5, #10                  @ Position = 10

    @ Terceira instrução (num5 e num6)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Quarta instrução (num7 e num8)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r3, #1                   @ Mat Targ = 0 (matriz A)
    mov r4, #12                  @ Position = 12
    ldrsb r6, [r0, #8]           @ num9 = matrixA[8] 
    mov r7, #0                   @ zero - valor para ir junto com num9
    
    @ Quinta instrução (num9 e zero)
    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    pop {r1-r12, lr}
    bx lr

load4x4:
    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11]

    ldr r0, =matrixA             @ Ponteiro para matrixA
    ldr r0, [r0]

    @ Enviando (num1, num2, num3 e num4)
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]
    
    mov r3, #0                   @ Mat Targ = 0 (matriz A)


    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Enviando (num5, num6, num7 e num8)
    ldrsb r6, [r0, #4]           @ num5 = matrixA[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixA[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixA[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixA[7]
    
    mov r4, #5                  @ Position = 0
    mov r5, #7                   @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done    

    @ Enviando (num9, num10, num11 e num12)
    ldrsb r6, [r0, #8]           @ num9 = matrixA[8] 
    ldrsb r7, [r0, #9]           @ num10 = matrixA[9]
    ldrsb r8, [r0, #10]          @ num11 = matrixA[10]
    ldrsb r9, [r0, #11]          @ num12 = matrixA[11]
    
    mov r4, #10                   @ Position = 0
    mov r5, #12                  @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done                    

    @ Enviando (num13, num14, num15 e num16)
    ldrsb r6, [r0, #12]          @ num13 = matrixA[12] 
    ldrsb r7, [r0, #13]          @ num14 = matrixA[13]
    ldrsb r8, [r0, #14]          @ num15 = matrixA[14]
    ldrsb r9, [r0, #15]          @ num16 = matrixA[15]
    
    mov r4, #15                  @ Position = 0
    mov r5, #17                  @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done


    ldr r0, =matrixB             @ Ponteiro para matrixB
    ldr r0, [r0]

    @ Enviando (num1, num2, num3 e num4)
    ldrsb r6, [r0, #0]           @ num1 = matrixB[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixB[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixB[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixB[3]
    
    mov r3, #1                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Enviando (num5, num6, num7 e num8)
    ldrsb r6, [r0, #4]           @ num5 = matrixB[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixB[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixB[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixB[7]
    
    mov r4, #5                   @ Position = 0
    mov r5, #7                   @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done    

    @ Enviando (num9, num10, num11 e num12)
    ldrsb r6, [r0, #8]           @ num9 = matrixB[8] 
    ldrsb r7, [r0, #9]           @ num10 = matrixB[9]
    ldrsb r8, [r0, #10]          @ num11 = matrixB[10]
    ldrsb r9, [r0, #11]          @ num12 = matrixB[11]
    
    mov r4, #10                   @ Position = 0
    mov r5, #12                  @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done                    

    @ Enviando (num13, num14, num15 e num16)
    ldrsb r6, [r0, #12]          @ num13 = matrixB[12] 
    ldrsb r7, [r0, #13]          @ num14 = matrixB[13]
    ldrsb r8, [r0, #14]          @ num15 = matrixB[14]
    ldrsb r9, [r0, #15]          @ num16 = matrixB[15]
    
    mov r4, #15                  @ Position = 0
    mov r5, #17                  @ Position = 2
    mov r12, #0x20               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    pop {r1-r12, lr}
    bx lr

load5x5:
    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11]

    ldr r0, =matrixA             @ Ponteiro para matrixA
    ldr r0, [r0]

    @ Enviando (num1, num2, num3 e num4)
    ldrsb r6, [r0, #0]           @ num1 = matrixA[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixA[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixA[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixA[3]
    
    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Enviando (num5, num6, num7 e num8)
    ldrsb r6, [r0, #4]           @ num5 = matrixA[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixA[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixA[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixA[7]
    
    mov r4, #4                   @ Position = 0
    mov r5, #6                   @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done    

    @ Enviando (num9, num10, num11 e num12)
    ldrsb r6, [r0, #8]           @ num9 = matrixA[8] 
    ldrsb r7, [r0, #9]           @ num10 = matrixA[9]
    ldrsb r8, [r0, #10]          @ num11 = matrixA[10]
    ldrsb r9, [r0, #11]          @ num12 = matrixA[11]
    
    mov r4, #8                   @ Position = 0
    mov r5, #10                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done                    

    @ Enviando (num13, num14, num15 e num16)
    ldrsb r6, [r0, #12]          @ num13 = matrixA[12] 
    ldrsb r7, [r0, #13]          @ num14 = matrixA[13]
    ldrsb r8, [r0, #14]          @ num15 = matrixA[14]
    ldrsb r9, [r0, #15]          @ num16 = matrixA[15]
    
    mov r4, #12                  @ Position = 0
    mov r5, #14                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num17, num18, num19 e num20)
    ldrsb r6, [r0, #16]          @ num17 = matrixA[16] 
    ldrsb r7, [r0, #17]          @ num18 = matrixA[17]
    ldrsb r8, [r0, #18]          @ num19 = matrixA[18]
    ldrsb r9, [r0, #19]          @ num20 = matrixA[19]
    
    mov r4, #16                  @ Position = 0
    mov r5, #18                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num21, num22, num23 e num24)
    ldrsb r6, [r0, #20]          @ num21 = matrixA[20] 
    ldrsb r7, [r0, #21]          @ num22 = matrixA[21]
    ldrsb r8, [r0, #22]          @ num23 = matrixA[22]
    ldrsb r9, [r0, #23]          @ num24 = matrixA[23]
    
    mov r4, #20                  @ Position = 0
    mov r5, #22                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num25 e zero)
    ldrsb r6, [r0, #24]          @ num21 = matrixA[20] 
    mov r7, #0                   @ num22 = matrixA[21]

    mov r4, #24                  @ Position = 0
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done


    @ Enviando matriz B


    ldr r0, =matrixB             @ Ponteiro para matrixA
    ldr r0, [r0]

    @ Enviando (num1, num2, num3 e num4)
    ldrsb r6, [r0, #0]           @ num1 = matrixB[0] 
    ldrsb r7, [r0, #1]           @ num2 = matrixB[1]
    ldrsb r8, [r0, #2]           @ num3 = matrixB[2]
    ldrsb r9, [r0, #3]           @ num4 = matrixB[3]
    
    mov r3, #1                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position = 0
    mov r5, #2                   @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    @ Enviando (num5, num6, num7 e num8)
    ldrsb r6, [r0, #4]           @ num5 = matrixB[4] 
    ldrsb r7, [r0, #5]           @ num6 = matrixB[5]
    ldrsb r8, [r0, #6]           @ num7 = matrixB[6]
    ldrsb r9, [r0, #7]           @ num8 = matrixB[7]
    
    mov r4, #4                   @ Position = 0
    mov r5, #6                   @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done    

    @ Enviando (num9, num10, num11 e num12)
    ldrsb r6, [r0, #8]           @ num9 = matrixB[8] 
    ldrsb r7, [r0, #9]           @ num10 = matrixB[9]
    ldrsb r8, [r0, #10]          @ num11 = matrixB[10]
    ldrsb r9, [r0, #11]          @ num12 = matrixB[11]
    
    mov r4, #8                   @ Position = 0
    mov r5, #10                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done                    

    @ Enviando (num13, num14, num15 e num16)
    ldrsb r6, [r0, #12]          @ num13 = matrixB[12] 
    ldrsb r7, [r0, #13]          @ num14 = matrixB[13]
    ldrsb r8, [r0, #14]          @ num15 = matrixB[14]
    ldrsb r9, [r0, #15]          @ num16 = matrixB[15]
    
    mov r4, #12                  @ Position = 0
    mov r5, #14                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num17, num18, num19 e num20)
    ldrsb r6, [r0, #16]          @ num17 = matrixB[16] 
    ldrsb r7, [r0, #17]          @ num18 = matrixB[17]
    ldrsb r8, [r0, #18]          @ num19 = matrixB[18]
    ldrsb r9, [r0, #19]          @ num20 = matrixB[19]
    
    mov r4, #16                  @ Position = 0
    mov r5, #18                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num21, num22, num23 e num24)
    ldrsb r6, [r0, #20]          @ num21 = matrixB[20] 
    ldrsb r7, [r0, #21]          @ num22 = matrixB[21]
    ldrsb r8, [r0, #22]          @ num23 = matrixB[22]
    ldrsb r9, [r0, #23]          @ num24 = matrixB[23]
    
    mov r4, #20                  @ Position = 0
    mov r5, #22                  @ Position = 2
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r8, lsl #20    @ num3 (bits 20-27)
    orr r10, r10, r9, lsl #12    @ num4 (bits 12-19)
    orr r10, r10, r5, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Mat. Siz + Opcode
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done  

    @ Enviando (num25 e zero)
    ldrsb r6, [r0, #24]          @ num21 = matrixB[20] 
    mov r7, #0                   @ num22 = matrixB[21]

    mov r4, #24                 @ Position = 0
    mov r12, #0x30               @ Mat. Siz = 03 (5x5), Opcode = 0000
    and r12, r12, #0x3F          @ Máscara 0b00111111 (bits 0-5)

    mov r10, #0x10000000         @ Bit 28 = 1
    orr r10, r10, r6, lsl #20    @ num1 (bits 20-27)
    orr r10, r10, r7, lsl #12    @ num2 (bits 12-19)
    orr r10, r10, r4, lsl #7     @ Position (bits 7-11)
    orr r10, r10, r3, lsl #6     @ Mat Targ (bit 6)
    orr r10, r10, r12            @ Agora só os bits 0-5 de r12 são adicionados
    str r10, [r11]               @ Envia para FPGA
    bl wait_for_done
  
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
    @ 0, 6, 12  
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r5, #0                   
    mov r2, #0x8
    mov r3, #1                   @ tamanho da matriz

    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r3, lsl #4
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

    mov r5, #6                   
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r3, lsl #4
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

    mov r5, #12                   
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r3, lsl #4
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]         

    lsr r1, r1, #8               
    lsr r1, r1, #8               
    lsr r1, r1, #8               

    strb r1, [r0, #8]            

    pop {lr}
    bx lr

store4x4:
    @ 0, 5, 10, 15
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r3, #2                   @ tamanho da matriz

    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2  
    orr r10, r10, r3, lsl #4

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

    mov r5, #5                
    mov r10, #0x10000000            
    orr r10, r10, r2  
    orr r10, r10, r5, lsl #7     
    orr r10, r10, r3, lsl #4
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

    mov r5, #10                       
    mov r10, #0x10000000            
    orr r10, r10, r2  
    orr r10, r10, r5, lsl #7    
    orr r10, r10, r3, lsl #4 
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

    mov r5, #15  
    mov r10, #0x10000000            
    orr r10, r10, r2                  
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r3, lsl #4   
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
    @ 0, 4, 8, 12, 16, 20, 24,
    mov r3, #3                   @ tamanho da matriz
 
    ldr r11, =mapped_addr        
    ldr r11, [r11]
    ldr r0, =matrixR             
    ldr r0, [r0]

    mov r5, #0                   @ Posição 
    mov r2, #0x8
    mov r10, #0x10000000         
    orr r10, r10, r2            
    orr r10, r10, r5, lsl #7 
    orr r10, r10, r3, lsl #4
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
    orr r10, r10, r3, lsl #4 
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
    orr r10, r10, r3, lsl #4
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
    orr r10, r10, r3, lsl #4
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
    orr r10, r10, r3, lsl #4
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
    orr r10, r10, r3, lsl #4
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
    orr r10, r10, r3, lsl #4
    str r10, [r11]              
    bl wait_for_done

    ldr r1, [r11, #0x10]                 

    strb r1, [r0, #24]     

    pop {lr}
    bx lr

welcome:
    mov r7, #4        @ syscall write
    mov r0, #1        @ stdout
    ldr r1, =welcome_msg
    mov r2, #welcome_msg_len
    svc #0

    bx lr

@ Aqui pode está errado!!!
wait_for_done:
    push {r0-r11, lr}             @ Preserva o registrador de retorno

    ldr r0, =mapped_addr         @ Carrega o endereço base
    ldr r0, [r0]

wait_loop:
    ldr r1, [r0, #0x30]                 @ Carrega o valor do registrador

    and r2, r1, #0x08            @ Isola o bit 3 (4º bit)
    cmp r2, #0x08                @ Compara com 0x08
    beq restart               @ Se igual, sair do loop

    b wait_loop                  @ Volta para o início do loop

restart:
    @  enviar restart
    mov r3, #0x00000000    

    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    ldr r11, [r11]
    str r3, [r11, #0x0]               @ Envia para FPGA

    pop {r0-r11, lr}

    bx lr

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

@ -----------------------------------------------------------------------------------------------------

mmap_cleanup:

    push {r0-r7, lr}
    @ r0 = endereço mapeado (passado como parâmetro)
    ldr r0, =mapped_addr
    ldr r0, [r0]
    cmp r0, #0                @ Se NULL, ignora
    beq cleanup_done

    @ Faz munmap(addr, size)
    mov r1, #0x1000           @ Tamanho = 4KB (ajuste conforme necessário)
    mov r7, #91               @ SYS_munmap = 91
    svc #0

    cmp r0, #0                @ Verifica se munmap falhou

    blt fail_munmap

    @ Fecha o file descriptor (se ainda estiver aberto)
    ldr r0, =file_descriptor
    ldr r0, [r0]
    cmp r0, #0

    ble cleanup_done           @ Se fd <= 0, ignora

    mov r7, #6                @ SYS_close = 6
    svc #0

    cmp r0, #0

    beq  cleanup_done

cleanup_done:

    mov r0, #0                @ Retorna 0 (sucesso)
    pop {r0-r7, lr}
    bx lr

fail_munmap:
    @ (Opcional: log de erro)

    mov r0, #-1               @ Retorna -1 (erro)
    pop {r0-r7, lr}
    bx lr
