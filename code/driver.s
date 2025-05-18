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

    welcome: .ascii "\nWelcome to Driver\n"
    welcome_len = . - welcome

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


    @ code [pega os 4 valores de 2 em 2 e fazer LOAD] ...
    
    pop {lr}
    bx lr

load3x3:
    push {lr}

    @ code ...

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
    ldr r1, =welcome
    mov r2, #welcome_len
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
