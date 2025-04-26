#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int menu();
void matrix_read(int n, short int *matrix);
void operationWithOneMatrix(int size, short int *matrix1);
void matrix_result_visualization(int n, short int *matrix);
void operationWithTwoMatrices(int size, short int *matrix1, short int *matrix2);

int main()
{
  int start = 1;
  while (start)
  {
    int op = menu();

    if (op == 0)
    {
      start = 0;
    }
    else if (op == 1)
    {
      int size = 0;
      short int opcode = 0;

      printf("\nDigite o tamanho da matriz (n para n x n): ");
      scanf("%d", &size);

      if (size < 2 || size > 5)
      {
        printf("\nTamanho inválido!\n");
        continue;
      }

      short int *matrix1 = calloc(25, sizeof(short int));
      short int *matrix2 = calloc(25, sizeof(short int));
      short int *matrixr = calloc(25, sizeof(short int));

      if (matrix1 == NULL || matrix2 == NULL || matrixr == NULL)
      {
        printf("\nErro de alocação de memória!\n");
        free(matrix1);
        free(matrix2);
        free(matrixr);
        continue;
      }

      short int opcode_matrix = 0;
      printf("\n1 - Soma\n2 - Subtração\n3 - Multiplicação\n4 - Oposta\n5 - Transposição\n6 - Escalar\n7 - Determinante\n\nDigite a operação: ");
      scanf("%hd", &opcode_matrix);

      if (opcode_matrix == 1) // Soma
      {
        operationWithTwoMatrices(size, matrix1, matrix2);
      }
      else if (opcode_matrix == 2) // Subtração
      {
        operationWithTwoMatrices(size, matrix1, matrix2);
      }
      else if (opcode_matrix == 3) // Multiplicação
      {
        operationWithTwoMatrices(size, matrix1, matrix2);
      }
      else if (opcode_matrix == 4) // Oposta
      {
        operationWithOneMatrix(size, matrix1);
      }
      else if (opcode_matrix == 5) // Transposição
      {
        operationWithOneMatrix(size, matrix1);
      }
      else if (opcode_matrix == 6) // Escalar
      {
        short int scalar = 0;
        operationWithOneMatrix(size, matrix1);
        printf("Digite o valor escalar: ");
        scanf("%hd", &scalar);

        matrix2[0] = scalar;
      }
      else if (opcode_matrix == 7) // Determinant
      {
        operationWithOneMatrix(size, matrix1);
      }
      else
      {
        printf("\nOpção inválida!\n");
        free(matrix1);
        free(matrix2);
        free(matrixr);
        continue;
      }

      clock_t start, end;
      double execute_time = 0;

      start = clock();

      // Enviar os dados para o driver.
      // esperar o retorno do resultado.

      end = clock();

      execute_time = ((double)(end - start) / CLOCKS_PER_SEC);

      printf("\nTempo de execução: %fs +/- 0.000002s \n", execute_time);

      if (opcode == 7) // Visualização do resultado
      {
        printf("\nDeterminante: %hd\n", matrixr[0]);
      }
      else
      {
        matrix_result_visualization(size, matrixr);
      }

      free(matrix1);
      free(matrix2);
      free(matrixr);
    }
    else
    {
      printf("\nOpção inválida!\n");
    }
  }

  printf("\nPrograma encerrado.\n");
  return 0;
}

void operationWithOneMatrix(int size, short int *matrix1)
{
  printf("\nMatriz 1:\n");
  matrix_read(size, matrix1);
}

void operationWithTwoMatrices(int size, short int *matrix1, short int *matrix2)
{
  printf("\nMatriz 1:\n");
  matrix_read(size, matrix1);
  printf("\nMatriz 2:\n");
  matrix_read(size, matrix2);
}

void matrix_result_visualization(int n, short int *matrix)
{
  if (matrix == NULL || n <= 0)
  {
    printf("\nMatriz inválida!\n");
    return;
  }

  printf("\nResultado:\n");

  for (int j = 0; j < n; j++)
    printf("+------");
  printf("+\n");

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      printf("| %4hd ", matrix[i * n + j]);
    }
    printf("|\n");

    for (int j = 0; j < n; j++)
      printf("+------");
    printf("+\n");
  }
}

void matrix_read(int n, short int *matrix)
{
  if (matrix == NULL || n <= 0)
  {
    return;
  }

  printf("Digite os %d elementos da matriz (em ordem de linha):\n", n * n);
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      printf("Elemento [%d][%d]: ", i, j);
      scanf("%hd", &matrix[i * n + j]);
    }
  }
}

int menu()
{
  int op = 0;
  printf("\nCalculadora Matricial - Grupo: Engenheiros Eletrocutados\n\n");
  printf("1 - Operações\n0 - Sair\n\nDigite a opção: ");
  scanf("%d", &op);
  return op;
}