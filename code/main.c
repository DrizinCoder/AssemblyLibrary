#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>

#define OPCODE_LOAD 0
#define OPCODE_STORE 7

#define OPCODE_ADD 1
#define OPCODE_SUB 2

#define FPGA_BASE_ADDR 0xFF200
#define PAGE_SIZE 4096
#define MAP_MASK (PAGE_SIZE - 1)

int load_control_signals(volatile uint32_t *fpga_register);
void store_control_signals(volatile uint32_t *fpga_register);
void send_instruction(volatile uint32_t *fpga_register, int num1, int num2, int num3, int mat_target, int mat_size, int opcode);
void start_signal(volatile uint32_t *fpga_register);
void wait_for_done(volatile uint32_t *fpga_register);
int load_matrix(volatile uint32_t *fpga_register, int *matrix, int size, int mat_target);
int store_matrix(volatile uint32_t *fpga_register, int *matrix, int size);
void read_matrix(int *matrix, int size, const char *name);
void print_matrix(int *matrix, int size, const char *name);
int memory_mman(int *fd, volatile uint32_t **fpga_register, void **map_base, void **virt_addr);

// Código Principal

int main()
{
  int fd;
  volatile uint32_t *fpga_register;
  void *map_base, *virt_addr;

  if (memory_mman(&fd, &fpga_register, &map_base, &virt_addr) != 0)
  {
    fprintf(stderr, "Falha ao mapear memória\n");
    return -1;
  }

  int start = 1;
  while (start)
  {
    printf("1 - Operação\n0 - Sair\nDigite: ");
    scanf("%d", &start);

    if (!start)
      break;

    int size = 0;
    int operation = 0;

    printf("Digite o tamanho da matriz: ");
    scanf("%d", &size);

    printf("Digite a operação: ");
    scanf("%d", &operation);

    int *matrixA = (int *)calloc(size * size, sizeof(int));
    int *matrixB = (int *)calloc(size * size, sizeof(int));
    int *matrixR = (int *)calloc(size * size, sizeof(int));

    read_matrix(matrixA, size, "A");
    read_matrix(matrixB, size, "B");

    printf("\nCarregando matriz A na FPGA...\n");
    load_matrix(fpga_register, matrixA, size, 0);

    printf("\nCarregando matriz B na FPGA...\n");
    load_matrix(fpga_register, matrixB, size, 1);

    printf("\nEnviando operação...\n");
    if (operation == 1)
    {
      send_instruction(fpga_register, 0, 0, 0, 0, 0, OPCODE_ADD);
      start_signal(fpga_register);
      wait_for_done(fpga_register);
    }
    else
    {
      send_instruction(fpga_register, 0, 0, 0, 0, 0, OPCODE_SUB);
      start_signal(fpga_register);
      wait_for_done(fpga_register);
    }

    printf("\nRecebendo resultado da FPGA...\n");
    store_matrix(fpga_register, matrixR, size);

    printf("\nResultado da operação:\n");
    print_matrix(matrixR, size, "Resultado");

    free(matrixA);
    free(matrixB);
    free(matrixR);

    munmap(map_base, PAGE_SIZE);
    close(fd);
  }

  return 0;
}

// Funções de comunicação com a FPGA

// Observa sinais da FPGA
int load_control_signals(volatile uint32_t *fpga_register)
{
  volatile uint32_t *control_signals_addr = fpga_register + (0x40 / sizeof(uint32_t));
  uint32_t control_signals = *control_signals_addr;
  return (control_signals & 0x01);
}

// Envia sinais para FPGA
void store_control_signals(volatile uint32_t *fpga_register)
{
  volatile uint32_t *control_signals_addr = fpga_register + (0x20 / sizeof(uint32_t));
  *control_signals_addr = 0x01;
}

void send_instruction(volatile uint32_t *fpga_register, int num1, int num2, int num3, int mat_target, int mat_size, int opcode)
{
  volatile uint32_t *instruction_register = fpga_register + (0x60 / sizeof(uint32_t));

  uint32_t instruction = 0;

  instruction |= (opcode & 0xF);          // Opcode: bits 0-3 (4 bits)
  instruction |= (mat_size & 0x3) << 4;   // Mat. Size: bits 4-5 (2 bits)
  instruction |= (mat_target & 0x1) << 6; // Mat Target: bit 6 (1 bit)
  instruction |= (num1 & 0xFF) << 7;      // num1: bits 7-14 (8 bits)
  instruction |= (num2 & 0xFF) << 15;     // num2: bits 15-22 (8 bits)
  instruction |= (num3 & 0xFF) << 23;     // num3: bits 23-30 (8 bits)

  // Garante que o bit 31 fique zerado
  instruction &= 0x7FFFFFFF;

  *instruction_register = instruction;

  printf("Instrução de 32 bits montada e enviada: 0x%08X\n", instruction);
}

void start_signal(volatile uint32_t *fpga_register)
{
  printf("Enviando sinal START\n");
  store_control_signals(fpga_register);
}

void wait_for_done(volatile uint32_t *fpga_register)
{
  while (!load_control_signals(fpga_register))
  {
    printf("Esperando por sinal DONE...\n");
  }
  printf("\nDONE recebido!\n\n");
}

// Funções auxiliares

int load_matrix(volatile uint32_t *fpga_register, int *matrix, int size, int mat_target)
{
  int elements = size * size;
  int sent = 0;

  while (sent < elements)
  {
    int num1 = 0, num2 = 0, num3 = 0;

    // Preenche os 3 valores (ou menos se for o último envio)
    if (sent < elements)
      num1 = matrix[sent++];
    if (sent < elements)
      num2 = matrix[sent++];
    if (sent < elements)
      num3 = matrix[sent++];

    // Envia a instrução LOAD
    send_instruction(fpga_register, num1, num2, num3, mat_target, size, OPCODE_LOAD);
    start_signal(fpga_register);
    wait_for_done(fpga_register);
  }

  return 0;
}

int store_matrix(volatile uint32_t *fpga_register, int *matrix, int size)
{
  int elements = size * size;
  int received = 0;
  int store_count = (elements + 3) / 4; // Calcula quantos STOREs são necessários

  // Array de registradores para ler 4 valores de 32 bits (total 128 bits)
  volatile uint32_t *data_registers = fpga_register + (0x60 / sizeof(uint32_t));

  for (int i = 0; i < store_count; i++)
  {
    send_instruction(fpga_register, 0, 0, 0, 0, size, OPCODE_STORE);
    start_signal(fpga_register);
    wait_for_done(fpga_register);

    int val1 = data_registers[0];
    int val2 = data_registers[1];
    int val3 = data_registers[2];
    int val4 = data_registers[3];

    // Armazena os valores recebidos na matriz
    if (received < elements)
      matrix[received++] = val1;
    if (received < elements)
      matrix[received++] = val2;
    if (received < elements)
      matrix[received++] = val3;
    if (received < elements)
      matrix[received++] = val4;
  }

  return 0;
}

void read_matrix(int *matrix, int size, const char *name)
{
  printf("Digite os valores da matriz %s (%dx%d):\n", name, size, size);
  for (int i = 0; i < size * size; i++)
  {
    printf("%s[%d][%d]: ", name, i / size, i % size);
    scanf("%d", &matrix[i]);
  }
}

void print_matrix(int *matrix, int size, const char *name)
{
  printf("Matriz %s:\n", name);
  for (int i = 0; i < size; i++)
  {
    for (int j = 0; j < size; j++)
    {
      printf("%4d", matrix[i * size + j]);
    }
    printf("\n");
  }
}

// Mapeamento de memória

int memory_mman(int *fd, volatile uint32_t **fpga_register, void **map_base, void **virt_addr)
{
  // Abrir /dev/mem para acessar memória física
  if ((*fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1)
  {
    perror("Erro ao abrir /dev/mem");
    return -1;
  }

  // Mapear a página de memória que contém o registrador
  *map_base = mmap(0, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, *fd, FPGA_BASE_ADDR & ~MAP_MASK);
  if (*map_base == (void *)-1)
  {
    perror("Erro no mapeamento");
    close(*fd);
    return -1;
  }

  // Calcular o endereço virtual do registrador
  *virt_addr = *map_base + (FPGA_BASE_ADDR & MAP_MASK);
  *fpga_register = (volatile uint32_t *)*virt_addr;

  return 0;
}
