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
void send_instruction(volatile uint32_t *fpga_register, int num1, int num2, int position, int mat_target, int mat_size, int opcode);
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
      wait_for_done(fpga_register);
    }
    else
    {
      send_instruction(fpga_register, 0, 0, 0, 0, 0, OPCODE_SUB);
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

void send_instruction(volatile uint32_t *fpga_register, int num1, int num2, int position, int mat_target, int mat_size, int opcode)
{
  volatile uint32_t *instruction_register = fpga_register + (0x60 / sizeof(uint32_t));

  uint32_t instruction = 0;

  // Montagem da instrução conforme a organização especificada
  instruction |= (0x7 & 0x7) << 29;       // x: 3 bits (fixo como 0x7)
  instruction |= (0x1 & 0x1) << 28;       // start: 1 bit (fixo como 1)
  instruction |= (num1 & 0xFF) << 20;     // num1: 8 bits
  instruction |= (num2 & 0xFF) << 12;     // num2: 8 bits
  instruction |= (position & 0x1F) << 7;  // position: 5 bits
  instruction |= (mat_target & 0x1) << 6; // Mat Targ: 1 bit
  instruction |= (mat_size & 0x3) << 4;   // Mat. Siz: 2 bits
  instruction |= (opcode & 0xF);          // Opcode: 4 bits

  *instruction_register = instruction;

  printf("Instrução de 32 bits montada e enviada: 0x%08X\n", instruction);
}

// Funções auxiliares'
int load_matrix(volatile uint32_t *fpga_register, int *matrix, int size, int mat_target)
{

  if (size == 2)
  {
    int num1 = matrix[0];
    int num2 = matrix[1];
    int num3 = matrix[2];
    int num4 = matrix[3];

    send_instruction(fpga_register, num1, num2, 0, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num3, num4, 5, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);
  }
  else if (size == 3)
  {
    int num1 = matrix[0];
    int num2 = matrix[1];
    int num3 = matrix[2];
    int num4 = matrix[3];
    int num5 = matrix[4];
    int num6 = matrix[5];
    int num7 = matrix[6];
    int num8 = matrix[7];
    int num9 = matrix[8];

    send_instruction(fpga_register, num1, num2, 0, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num3, num4, 2, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num5, num6, 6, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num7, num8, 10, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num9, 0, 12, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);
  }
  else if (size == 4)
  {
    int num1 = matrix[0];
    int num2 = matrix[1];
    int num3 = matrix[2];
    int num4 = matrix[3];
    int num5 = matrix[4];
    int num6 = matrix[5];
    int num7 = matrix[6];
    int num8 = matrix[7];
    int num9 = matrix[8];
    int num10 = matrix[9];
    int num11 = matrix[10];
    int num12 = matrix[11];
    int num13 = matrix[12];
    int num14 = matrix[13];
    int num15 = matrix[14];
    int num16 = matrix[15];

    // Envia os pares de números com suas posições específicas
    send_instruction(fpga_register, num1, num2, 0, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num3, num4, 2, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num5, num6, 5, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num7, num8, 7, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num9, num10, 10, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num11, num12, 12, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num13, num14, 15, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num15, num16, 17, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);
  }
  else if (size == 5)
  {
    int num1 = matrix[0];
    int num2 = matrix[1];
    int num3 = matrix[2];
    int num4 = matrix[3];
    int num5 = matrix[4];
    int num6 = matrix[5];
    int num7 = matrix[6];
    int num8 = matrix[7];
    int num9 = matrix[8];
    int num10 = matrix[9];
    int num11 = matrix[10];
    int num12 = matrix[11];
    int num13 = matrix[12];
    int num14 = matrix[13];
    int num15 = matrix[14];
    int num16 = matrix[15];
    int num17 = matrix[16];
    int num18 = matrix[17];
    int num19 = matrix[18];
    int num20 = matrix[19];
    int num21 = matrix[20];
    int num22 = matrix[21];
    int num23 = matrix[22];
    int num24 = matrix[23];
    int num25 = matrix[24];

    // Envia os pares de números com suas posições específicas
    send_instruction(fpga_register, num1, num2, 0, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num3, num4, 2, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num5, num6, 4, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num7, num8, 6, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num9, num10, 8, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num11, num12, 10, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num13, num14, 12, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num15, num16, 14, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num17, num18, 16, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num19, num20, 18, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num21, num22, 20, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num23, num24, 22, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);

    send_instruction(fpga_register, num25, 0, 24, mat_target, size, OPCODE_LOAD);
    wait_for_done(fpga_register);
  }

  return 0;
}

void wait_for_done(volatile uint32_t *fpga_register)
{
  while (!load_control_signals(fpga_register))
  {
    printf("Esperando por sinal DONE...\n");
  }
  printf("\nDONE recebido!\n\n");
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
