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

#define FPGA_BASE_ADDR 0xFF200000
#define FPGA_SPAN_ADDR 0x00005000

void send_instruction(int num1, int num2, int position, int mat_target, int mat_size, int opcode);
int load_control_signals();

void wait_for_done();

int load_matrix(int *matrix, int size, int mat_target);
int store_matrix(int *matrix, int size, int target);

void read_matrix(int *matrix, int size, const char *name);
void print_matrix(int *matrix, int size, const char *name);
void print_binary(uint8_t byte);

int fd = -1;
void *virt_addr;
volatile int *fpga_register;

// Código Principal
int main()
{
  // Abrir /dev/mem para acessar memória física
  if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1)
  {
    perror("Erro ao abrir /dev/mem");
    return -1;
  }

  // Obter endereço virtual
  virt_addr = mmap(NULL, FPGA_SPAN_ADDR, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, FPGA_BASE_ADDR);
  if (virt_addr == MAP_FAILED)
  {
    perror("Erro no mapeamento");
    close(fd);
    return -1;
  }

  fpga_register = (int *)((virt_addr) + (0x30));
  int control_signals = *fpga_register;
  print_binary((uint8_t)control_signals);

  int start = 1;
  while (start)
  {
    printf("1 - Operação\n0 - Sair\nDigite: ");
    scanf("%d", &start);

    if (start != 1)
    {
      printf("Saindo do programa...");
      start = 0;
      break;
    }

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
    load_matrix(matrixA, size, 0);

    printf("\nCarregando matriz B na FPGA...\n");
    load_matrix(matrixB, size, 1);

    printf("\nEnviando operação...\n");
    if (operation == 1)
    {
      send_instruction(0, 0, 0, 0, 0, OPCODE_ADD);
      wait_for_done();
    }
    else
    {
      send_instruction(0, 0, 0, 0, 0, OPCODE_SUB);
      wait_for_done();
    }

    printf("\nRecebendo resultado da FPGA...\n");
    store_matrix(matrixR, size, 0);

    printf("\nResultado da operação:\n");
    print_matrix(matrixR, size, "Resultado");

    free(matrixA);
    free(matrixB);
    free(matrixR);
  }

  if (munmap(virt_addr, FPGA_SPAN_ADDR) != 0)
  {
    printf(" ERROR : munmap () failed ...\n");
    return (-1);
  }

  close(fd);

  return 0;
}

// Funções de Comunicação Com a FPGA
int load_control_signals()
{
  fpga_register = (int *)(virt_addr + (0x30));
  int control_signals = *fpga_register;

  print_binary((uint8_t)control_signals);

  return (control_signals & 0x08);
}

void send_instruction(int num1, int num2, int position, int mat_target, int mat_size, int opcode)
{
  uint32_t instruction = 0;

  instruction |= (0x7 & 0x7) << 29;       // Campo 'x' fixo (3 bits)
  instruction |= (0x1 & 0x1) << 28;       // Bit 'start' fixo (1 bit)
  instruction |= (num1 & 0xFF) << 20;     // num1 (8 bits)
  instruction |= (num2 & 0xFF) << 12;     // num2 (8 bits)
  instruction |= (position & 0x1F) << 7;  // position (5 bits)
  instruction |= (mat_target & 0x1) << 6; // mat_target (1 bit)
  instruction |= (mat_size & 0x3) << 4;   // mat_size (2 bits)
  instruction |= (opcode & 0xF);          // opcode (4 bits)
                                          // Opcode: 4 bits

  fpga_register = (int *)(virt_addr);
  *fpga_register = instruction;

  printf("Instrução de 32 bits montada e enviada: 0x%08X\n", instruction);
}

// Funções Auxiliares'
int load_matrix(int *matrix, int size, int mat_target)
{

  if (size == 2)
  {
    int num1 = matrix[0];
    int num2 = matrix[1];
    int num3 = matrix[2];
    int num4 = matrix[3];

    send_instruction(num1, num2, 0, mat_target, 0, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num3, num4, 5, mat_target, 0, OPCODE_LOAD);
    wait_for_done();
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

    send_instruction(num1, num2, 0, mat_target, 1, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num3, num4, 2, mat_target, 1, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num5, num6, 6, mat_target, 1, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num7, num8, 10, mat_target, 1, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num9, 0, 12, mat_target, 1, OPCODE_LOAD);
    wait_for_done();
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

    send_instruction(num1, num2, 0, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num3, num4, 2, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num5, num6, 5, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num7, num8, 7, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num9, num10, 10, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num11, num12, 12, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num13, num14, 15, mat_target, 2, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num15, num16, 17, mat_target, 2, OPCODE_LOAD);
    wait_for_done();
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

    send_instruction(num1, num2, 0, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num3, num4, 2, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num5, num6, 4, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num7, num8, 6, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num9, num10, 8, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num11, num12, 10, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num13, num14, 12, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num15, num16, 14, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num17, num18, 16, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num19, num20, 18, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num21, num22, 20, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num23, num24, 22, mat_target, 3, OPCODE_LOAD);
    wait_for_done();

    send_instruction(num25, 0, 24, mat_target, 3, OPCODE_LOAD);
    wait_for_done();
  }

  return 0;
}

void wait_for_done()
{
  while (!load_control_signals())
  {
    printf("...\n");
  }
  printf("\nDONE recebido!\n\n");
}

int store_matrix(int *matrix, int size, int mat_target)
{
  if (size == 2)
  {
    int positions[] = {0, 5};
    int count = 0;

    for (int i = 0; i < 2; i++)
    {
      send_instruction(0, 0, positions[i], mat_target, size, OPCODE_STORE);
      wait_for_done();

      fpga_register = (int *)((virt_addr) + (0x10));

      // Lê 32 bits
      uint32_t packed_data = *fpga_register;

      uint8_t byte0 = (packed_data >> 24) & 0xFF;
      uint8_t byte1 = (packed_data >> 16) & 0xFF;
      uint8_t byte2 = (packed_data >> 8) & 0xFF;
      uint8_t byte3 = packed_data & 0xFF;

      if (positions[i] == 0)
      {
        matrix[0] = (int)byte0;
        matrix[1] = (int)byte1;
      }
      else if (positions[i] == 5)
      {
        matrix[2] = (int)byte2;
        matrix[3] = (int)byte3;
      }
    }
  }
  else if (size == 3)
  {
    int positions[] = {0, 2, 6, 10, 12};
    int count = 0;

    for (int i = 0; i < 5; i++)
    {
      printf("Implementar!");
    }
  }
  else if (size == 4)
  {
    int positions[] = {0, 2, 5, 7, 10, 12, 15, 17};
    int count = 0;

    for (int i = 0; i < 8; i++)
    {
      printf("Implementar!");
    }
  }
  else if (size == 5)
  {
    int positions[] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24};
    int count = 0;

    for (int i = 0; i < 13; i++)
    {
      printf("Implementar!");
    }
  }
  else
  {
    printf("Tamanho não suportado: %d\n", size);
    return -1;
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

void print_binary(uint8_t byte)
{
  printf("FPGA_signals (bin): ");
  for (int i = 7; i >= 0; i--)
  {
    printf("%d", (byte >> i) & 1);
  }
  printf("\n");
}