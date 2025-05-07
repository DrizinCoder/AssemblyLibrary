@ Matrix Operations Lib
.syntax unified
.arch armv7-a

@ Constantes
.equ SYS_OPEN, 5
.equ SYS_MMAP, 192
.equ SUS_MUNMAP, 91
.equ OPEN_MODE, 1
.equ MAP_SHARED, 1

@ Dados
.section .data
dev_mem: .asciz "/dev/mem"
file_descriptor: .word 0


@ Código
.section .text

@ Função 1: Envia matriz A para o coprocessador
@ R0 = Ponteiro para Struct Matrix
@ R1 = Endereço mapeado da FPGA

.global loadMatrixA
.type loadMatrixA, %function
loadMatrixA:
    push {r4-r8, lr}

    ldr r2, [r0]        @ Ponteiro para dados
    ldr r3, [r0, #4]    @ Size

    mul r4, r3, r3      @ N²

    @ Enviando matriz A para FPGA
    mov r5, #0
copy_loop_A:
    cmp r5, r4
    bge copy_A_done

    ldrb r6, [r2, r5]
    strb r6, [r1, r5]
    add r5, r5, #1
    b copy_loop_A

copy_A_done:
    mov r6, #0x51
    cmp r3, #4                  @ N = 2? 
    moveq r9, #0x10              @ opcode 0x10
    
    cmp r3, #9                  @ N = 3?
    moveq r9, #0x18             @ opcode 0x18
    
    cmp r3, #16                 @ N = 4?
    moveq r9, #0x20             @ opcode 0x20
    
    cmp r3, #25                 @ N = 5?
    moveq r9, #0x28             @ opcode 0x28

    strb r9, [r4, r6]           @ Escreve opconde em oxFF20000 + 0x51
    pop {r4-r8, pc}


@ Função 2: Envia matriz B para o coprocessador
@ R0 = Ponteiro para Struct Matrix
@ R1 = Endereço mapeado da FPGA

.global loadMatrixB
.type loadMatrixB, %function
loadMatrixB:
    push {r4-r8, lr}

    ldr r2, [r0]        @ Ponteiro para dados
    ldr r3, [r0, #4]    @ Size

    mul r4, r3, r3      @ N²

    @ Enviando matriz B para FPGA
    mov r5, #0
    mov, r6, #25
copy_loop_B:
    cmp r5, r4
    bge copy_B_done

    ldrb r7, [rw, r5]
    add r8, r5, r6
    strb r7, [r1, r8]
    
    add r5, r5, #1
    b copy_loop_B

copy_B_done:

    mov r6, #0x51
    cmp r3, #4                  @ N = 2? 
    moveq r9, #0x50              @ opcode 0x50
    
    cmp r3, #9                  @ N = 3?
    moveq r9, #0x58             @ opcode 0x58
    
    cmp r3, #16                 @ N = 4?
    moveq r9, #0x60             @ opcode 0x60
    
    cmp r3, #25                 @ N = 5?
    moveq r9, #0x68             @ opcode 0x68

    strb r9, [r4, r6]           @ Escreve opconde em oxFF20000 + 0x52
    pop {r4-r8, pc}

@ Função 3: Envia instrução de soma
.global sum
.type sum, %function
sum:
    mov r1, #1
    strb r1, [r0, #0x50]
    bx lr

@ Função 4: Envia instrução de subtração
.global sub
.type sub, %function
sub:
    mov r1, #2
    strb r1, [r0, #0x50]
    bx lr

@ Função 5: Envia instrução de multiplicação
.global mul
.type mul, %function
mul:
    mov r1, #3
    strb r1, [r0, #0x50]
    bx lr

@ Função 6: Envia instrução de oposta
.global oposite
.type oposite, %function
oposite:
    mov r1, #4
    strb r1, [r0, #0x50]
    bx lr

@ Função 7: Envia instrução de Transposta
.global Transpose
.type Transpose, %function
Transpose:
    mov r1, #5
    strb r1, [r0, #0x50]
    bx lr

@ Função 8: Envia instrução de multiplicação por fator
.global mul_factor
.type mul_factor, %function
mul_factor:
    mov r1, #6
    strb r1, [r0, #0x50]
    bx lr

@ Função 9: Envia instrução de det2
.global det2
.type det2, %function
det2:
    mov r1, #0x17
    strb r1, [r0, #0x50]
    bx lr

@ Função 10: Envia instrução de det3
.global det3
.type det3, %function
det3:
    mov r1, #0x1F
    strb r1, [r0, #0x50]
    bx lr

@ Função 11: Envia instrução de det4
.global det4
.type det4, %function
det4:
    mov r1, #0x27
    strb r1, [r0, #0x50]
    bx lr

@ Função 12: Envia instrução de det5
.global det5
.type det5, %function
det5:
    mov r1, #0x2F
    strb r1, [r0, #0x50]
    bx lr

@ Função 13: Abrir memória da FPGA

@ Função 14: Mapear memória da FPGA

@ Função 15: Desmapear a memória da FPGA