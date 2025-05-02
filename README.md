# 📚 Anotações sobre syscall e desenvolvimento da meta

## ⚙ Syscalls

A chamada de sistema é um pedido que um programa de computador faz ao núcleo (kernel) do sistema operacional para executar uma ação que requer privilégios especiais, como acessar hardware ou manipular processos. Em essência, é a interface entre um programa em espaço de usuário e o núcleo do sistema operacional. 
No projeto em desenvolvimento, devemos acessar endereços físicos a partir de chamadas ao sistema linux embarcado na FPGA DE1-SoC.

As principais syscalls para realização desse problema estarão nos próximos tópicos.

## Open
A syscall open tem o objetivo de abrir um arquivo específico no sistema. O /dev/mem é um arquivo da DE1-SoC que representa a memória!

### Parâmetros

1. **Parâmetro 1** – Ponteiro para o *pathname*  
   Exemplo: `ldr r0, =dev_mem`

2. **Parâmetro 2** – Flags de abertura  
   Exemplo: `mov r1, #2` (equivale a `O_RDWR`)

3. **Parâmetro 3** – Modo de criação (usado com O_CREAT)  
   Exemplo: `mov r2, #0644` (apenas se `O_CREAT` for usado)


### Linguagem C 

```c
int open(const char *pathname, int flags, mode_t mode);
```  

### Linguagem Assembly ARMV7

```c
.global _start
.section .data
dev_mem:    .asciz "/dev/mem"

_start:
    @ --- Syscall open ---
    ldr r0, =dev_mem
    mov r1, #2
    mov r7, #5
    svc #0 
```

## mmap

A syscall mmap tem o objetivo de mapear um endereço de memória física a partir do sistema operacional, permitindo o acesso a periféricos específicos, desde que haja permissão. O uso dessa syscall é determinada para acessar a ponte de comunicação da AXI bridge, localizada no endereço 0xFF200000

### Parâmetros da syscall `mmap`

1. **Parâmetro 1 – Endereço sugerido para início do mapeamento**
   - Valor: ponteiro (`void *addr`)
   - Exemplo: `NULL` permite ao kernel escolher o endereço.

2. **Parâmetro 2 – Tamanho da página**
   - Valor: número de bytes (`size_t length`)
   - Exemplo: `4096` (1 página padrão).

3. **Parâmetro 3 – Permissão de acesso à região mapeada**
   - Valor: `int prot`
   - Exemplos:
     - `PROT_READ` (1)
     - `PROT_WRITE` (2)
     - `PROT_EXEC` (4)
     - Combinação: `PROT_READ | PROT_WRITE` → `3`

4. **Parâmetro 4 – Tipo do mapeamento**
   - Valor: `int flags`
   - Exemplos:
     - `MAP_PRIVATE` (2)
     - `MAP_SHARED` (1)
     - `MAP_ANONYMOUS` (32)
     - Combinação: `MAP_PRIVATE | MAP_ANONYMOUS` → `34`

5. **Parâmetro 5 – Arquivo a ser mapeado**
   - Valor: `int fd` (file descriptor)
   - Exemplo: `-1` quando se usa `MAP_ANONYMOUS`

6. **Parâmetro 6 – Offset de início no arquivo**
   - Valor: `off_t offset`
   - Exemplo: `0` (início do arquivo ou da região)


### Linguaguem C

```c
void *ptr = mmap(NULL, 4096, PROT_READ | PROT_WRITE,MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
```

##Linguagem Assembly ARMV7

```c
.global _start

_start:
    @ --- Parâmetros da syscall mmap ---
    mov r0, #0              @ addr = NULL (deixa o kernel escolher)
    mov r1, #4096           @ length = 4096 bytes (1 página)
    mov r2, #3              @ prot = PROT_READ | PROT_WRITE (1 | 2 = 3)
    mov r3, #34             @ flags = MAP_PRIVATE | MAP_ANONYMOUS (2 | 32 = 34)
    mov r4, #0xFF2000000             @ endereço da ponte FPGA
    mov r5, #0              @ offset = 0

    mov r7, #192            @ syscall número 192 (mmap no ARM EABI)
    svc #0                  @ chamada de sistema

    @ Resultado em r0: endereço base da região mapeada
```
