#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>

extern void mmap_setup();
extern void driver(int8_t *matrixA, int8_t *matrixB, int8_t *matrixR, int size, int op_opcode);
extern void mmap_cleanup();

void operations();
int size_mask(int value);
void freePtr(int8_t *a, int8_t *b, int8_t *c);
void read_matrix(int8_t *matrix, int size, const char *name);
void print_matrix(int8_t *matrix, int size, const char *name);

int main() {
  mmap_setup();

  int start = 1;
  printf("Welcome to matrix calculator drive!\n");

  while (start) {
    int opc;

    printf("\n1 - Operações\n0 - Sair\nDigite: ");
    scanf("%d", &opc);

    if (opc == 1) {
      printf("\nMenu de operações\n");
      operations();
    }
    else if (opc == 0) {
      printf("Exiting...\n");
      start = 0;
    }
    else {
      printf("\nOpção inválida. Tente novamente!\n");
    }
  }

  mmap_cleanup();

  return 0;
}

void operations() {
  int operation;
  int size = 0;
  printf("1 - Soma\n2 - Subtração\n3 - Multiplicação\n4 - Matriz Oposta\n5 - Transposta\n6 - Multiplicação por escalar\n7 - Determinante \nDigite a operação: ");
  scanf("%d", &operation);
  if (operation >= 8 || operation <= 0) {
    printf("\n\nOPERAÇÃO INVÁLIDA!\n\n");
    return;
  }

  printf("\n\n---Tamanhos---\n2 - Matrix2x2\n3 - Matrix3x3\n4 - Matrix4x4\n5 - Matrix5x5\n");
  printf("Digite o tamanho da matriz: ");
  scanf("%d", &size);
  if (size >= 6 || size <=1 ) {
    printf("\n\nTAMANHO DE MATRIZ INVÁLIDO!\n\n");
    return;
  }

  printf("\n");

  int8_t *matrixA = (int8_t *)calloc(size * size, sizeof(int8_t));
  int8_t *matrixB = (int8_t *)calloc(size * size, sizeof(int8_t));
  int8_t *matrixR = (int8_t *)calloc(size * size, sizeof(int8_t));

  if (operation == 1) {
    read_matrix(matrixA, size, "A");
    read_matrix(matrixB, size, "B");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 2) {
    read_matrix(matrixA, size, "A");
    read_matrix(matrixB, size, "B");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 3) {
    read_matrix(matrixA, size, "A");
    read_matrix(matrixB, size, "B");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 4) {
    read_matrix(matrixA, size, "A");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 5) {
    read_matrix(matrixA, size, "A");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 6) {
    read_matrix(matrixA, size, "A");

    int scalar = 0;
    printf("Digite o escalar: ");
    scanf("%d", &scalar);
    matrixB[0] = scalar;

    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 7) {
    read_matrix(matrixA, size, "A");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else if (operation == 0) {
    read_matrix(matrixA, size, "A");
    driver(matrixA, matrixB, matrixR, size_mask(size), operation);
    print_matrix(matrixR, size, "Resultado");
    freePtr(matrixA, matrixB, matrixR);
  }
  else {
    freePtr(matrixA, matrixB, matrixR);
    printf("\nOperação inválida\n");
  }
}

int size_mask(int value) {
  if (value == 2) {
    return 0;
  }
  else if (value == 3) {
    return 1;
  }
  else if (value == 4) {
    return 2;
  }
  else if (value == 5) {
    return 3;
  }
  else {
    return 2;
  }
}

void freePtr(int8_t *a, int8_t *b, int8_t *c) {
  free(a);
  free(b);
  free(c);
}

void read_matrix(int8_t *matrix, int size, const char *name) {
  printf("Digite os valores da matriz %s (%dx%d):\n", name, size, size);
  for (int i = 0; i < size * size; i++) {
    printf("%s[%d][%d]: ", name, i / size, i % size);
    scanf("%hhd", &matrix[i]);
  }
}

void print_matrix(int8_t *matrix, int size, const char *name) {
  printf("\nMatriz %s:\n", name);
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      printf("%4hhd", matrix[i * size + j]);
    }
    printf("\n");
  }
}
