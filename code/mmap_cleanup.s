.global mmap_cleanup
.type mmap_cleanup, %function

.section .data
    file_descriptor: .word 0   @ Armazena o fd de /dev/mem
    dev_mem:        .asciz "/dev/mem"

.section .text
mmap_cleanup:
    push {lr}
    
    @ r0 = endereço mapeado (passado como parâmetro)
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
    
    @ Limpa o file_descriptor (opcional)
    ldr r1, =file_descriptor
    mov r0, #0
    str r0, [r1]
    
cleanup_done:
    mov r0, #0                @ Retorna 0 (sucesso)
    pop {lr}
    bx lr

fail_munmap:
    @ (Opcional: log de erro)
    mov r0, #-1               @ Retorna -1 (erro)
    pop {lr}
    bx lr
    