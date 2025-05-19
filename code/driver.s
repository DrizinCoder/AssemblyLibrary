.global driver

.section .data
    file_descriptor: .word 0
    dev_mem:        .asciz "/dev/mem"
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
    str r0, [r4]      @ matrixA pointer
    ldr r4, =matrixB
    str r1, [r4]      @ matrixB pointer
    ldr r4, =matrixR
    str r2, [r4]      @ matrixR pointer
    ldr r4, =matrix_size
    str r3, [r4]
    ldr r4, [sp, #24]
    ldr r5, =opcode
    str r4, [r5]

    bl mmap_setup
    bl welcome
    bl load
    bl operation
    bl store
    
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

    ldr r0, =matrixA             @ Carregamos o endereço da matriz A
    ldr r1, [r0, #0]             @ Primeiro inteiro (contém num1 e num2)
    ldr r2, [r0, #4]             @ Segundo inteiro (contém num3 e num4)

    and r6, r1, #0x000000FF      @ num1 = bits 0-7 do primeiro inteiro
    lsr r7, r1, #8               @ num2 = bits 8-15 do primeiro inteiro
    and r7, r7, #0x000000FF      @ Garantimos que só temos 8 bits
    and r8, r2, #0x000000FF      @ num3 = bits 0-7 do segundo inteiro
    lsr r9, r2, #8               @ num4 = bits 8-15 do segundo inteiro
    and r9, r9, #0x000000FF      @ Garantimos que só temos 8 bits

    mov r3, #0                   @ Mat Targ = 0 (matriz A)
    mov r4, #0                   @ Position inicial = 0
    mov r5, #5                   @ Position seguinte = 5
    mov r12, #0                  @ Mat. Siz = 00 (2x2) e Opcode = 0000

    mov r10, #0                  @ Limpamos o registrador r10
    orr r10, r10, #0x10000000    @ Setamos o bit 28 para 1

    @ Configuramos num1 (bits 20-27)
    lsl r6, r6, #20              @ Deslocamos num1 para a posição correta
    orr r10, r10, r6             @ Adicionamos ao registrador de instrução

    @ Configuramos num2 (bits 12-19)
    lsl r7, r7, #12              @ Deslocamos num2 para a posição correta
    orr r10, r10, r7             @ Adicionamos ao registrador de instrução

    @ Configuramos position (bits 7-11)
    lsl r4, r4, #7               @ Deslocamos position para a posição correta
    orr r10, r10, r4             @ Adicionamos ao registrador de instrução

    @ Configuramos Mat Targ (bit 6)
    lsl r3, r3, #6               @ Deslocamos Mat Targ para a posição correta
    orr r10, r10, r3             @ Adicionamos ao registrador de instrução

    @ Configuramos Mat. Siz (bits 4-5) e Opcode (bits 0-3)
    orr r10, r10, r12            @ Adicionamos ao registrador de instrução

    ldr r11, =mapped_addr        @ Carregamos o endereço da FPGA
    str r10, [r11]               @ Escrevemos a instrução na FPGA

    bl wait_for_done

    mov r10, #0                  @ Limpamos o registrador r10
    orr r10, r10, #0x10000000    @ Setamos o bit 28 para 1

    @ Configuramos num3 (bits 20-27)
    lsl r8, r8, #20              @ Deslocamos num3 para a posição correta
    orr r10, r10, r8             @ Adicionamos ao registrador de instrução

    @ Configuramos num4 (bits 12-19)
    lsl r9, r9, #12              @ Deslocamos num4 para a posição correta
    orr r10, r10, r9             @ Adicionamos ao registrador de instrução

    @ Configuramos position (bits 7-11)
    lsl r5, r5, #7               @ Deslocamos position para a posição correta
    orr r10, r10, r5             @ Adicionamos ao registrador de instrução

    mov r3, #1                   @ Target da matriz B

    @ Configuramos Mat Targ (bit 6)
    lsl r3, r3, #6               @ Deslocamos Mat Targ para a posição correta
    orr r10, r10, r3             @ Adicionamos ao registrador de instrução

    @ Configuramos Mat. Siz (bits 4-5) e Opcode (bits 0-3)
    orr r10, r10, r12            @ Adicionamos ao registrador de instrução

    str r10, [r11]               @ Escrevemos a instrução na FPGA

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
    push {r0-r2, lr}             @ Preserva o registrador de retorno

    ldr r0, =mapped_addr         @ Carrega o endereço base
    add r0, r0, #0x30            @ Adiciona offset 0x30

wait_loop:
    ldr r1, [r0]                 @ Carrega o valor do registrador

    and r2, r1, #0x08            @ Isola o bit 3 (4º bit)
    cmp r2, #0x08                @ Compara com 0x08
    beq done_ready               @ Se igual, sair do loop

    b wait_loop                  @ Volta para o início do loop

done_ready:
    pop {r0-r2, lr}                     @ Restaura o registrador de retorno
    bx lr                        @ Retorna da função

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

mmap_setup:
    push {lr}
    
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
    
    @ Store mapped address
    ldr r1, =mapped_addr
    str r0, [r1]
    
    pop {lr}
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
