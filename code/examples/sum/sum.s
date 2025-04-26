    .section .text
    .global sum         # Torna a função 'sum' visível para o código C

sum:
    # Entrada: %edi = primeiro número, %esi = segundo número
    # Saída: %eax = soma
    movl %edi, %eax     # Copia primeiro número (%edi) para %eax
    addl %esi, %eax     # Soma segundo número (%esi) a %eax
    ret                 # Retorna (resultado em %eax)
