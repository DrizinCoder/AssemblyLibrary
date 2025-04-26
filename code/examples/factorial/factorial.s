    .section .text
    .global factorial

factorial:
    # Entrada: %edi = n
    # Saída: %eax = n!
    cmpl $1, %edi       # Caso base: n <= 1?
    jle .base_case
    pushq %rdi          # Salva n na pilha
    decl %edi           # n - 1
    call factorial      # Chama factorial(n-1)
    popq %rdi           # Recupera n
    imull %edi, %eax    # %eax = n * factorial(n-1)
    ret

.base_case:
    movl $1, %eax       # Retorna 1 para n <= 1
    ret