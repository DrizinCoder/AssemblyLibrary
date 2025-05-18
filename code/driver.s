.global driver

.section .data
    file_descriptor: .word 0
    dev_mem:        .asciz "/dev/mem"
    mapped_addr:    .word 0  @ Adicionado para armazenar o endereço mapeado

    param_num1:     .word 0
    param_num2:     .word 0
    param_position: .word 0
    param_target:   .word 0
    param_size:     .word 0
    param_opcode:   .word 0

    welcome: .ascii "\Welcome to Driver\n"
    welcome_len = . - welcome

.section .text
driver:
    push {r4-r8, lr}  @ Preserva mais registradores
    
    @ Armazena parâmetros
    ldr r4, =param_num1
    str r0, [r4]
    ldr r4, =param_num2
    str r1, [r4]
    ldr r4, =param_position
    str r2, [r4]
    ldr r4, =param_target
    str r3, [r4]
    
    @ Parâmetros da pilha (assumindo que foram push {r0-r3, lr} na chamada)
    ldr r4, [sp, #24]   @ Ajuste o offset conforme sua chamada
    ldr r5, =param_size
    str r4, [r5]
    ldr r4, [sp, #28]
    ldr r5, =param_opcode
    str r4, [r5]

    bl mmap_setup

    mov r7, #4
    mov r0, #1
    ldr r1, =welcome
    mov r2, #welcome_len
    svc #0

    @ Continua a execução normalmente...
    
    pop {r4-r8, pc}

mmap_setup:
    push {lr}
    
    @ Abre /dev/mem
    ldr r0, =dev_mem
    mov r1, #2          @ O_RDWR
    mov r7, #5          @ syscall open
    svc #0
    
    cmp r0, #0
    blt fail_open
    
    ldr r1, =file_descriptor
    str r0, [r1]
    
    @ Configura mmap
    mov r0, #0              @ Endereço sugerido pelo kernel
    ldr r1, =0x1000         @ Tamanho
    mov r2, #3              @ PROT_READ|PROT_WRITE
    mov r3, #1              @ MAP_SHARED
    ldr r4, =file_descriptor
    ldr r4, [r4]            @ File descriptor
    ldr r5, =0xFF200     @ Endereço físico correto
    mov r7, #192            @ syscall mmap2
    svc #0
    
    cmn r0, #1
    beq fail_mmap
    
    @ Armazena o endereço mapeado
    ldr r1, =mapped_addr
    str r0, [r1]

    @ Verifica se mmap foi bem sucedido
    cmp r1, #0
    beq fail_mmap
    
    pop {pc}

fail_open:
    mov r0, #-1
    pop {pc}

fail_mmap:
    @ Fecha o arquivo se mmap falhou
    ldr r0, =file_descriptor
    ldr r0, [r0]
    mov r7, #6          @ syscall close
    svc #0
    
    mov r0, #-1
    pop {pc}