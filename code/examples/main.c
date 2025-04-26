#include <stdio.h>

extern int sum(int a, int b);
extern int factorial(int n);

int main()
{

  int start = 1;

  while (start)
  {
    int a = 0, b = 0;
    int op = 0;
    printf("1 - Soma\n2 - Fatorial\n0 - Sair\n\nDigite a opção: ");
    scanf("%d", &op);

    if (op == 0)
    {
      start = 0;
    }
    else if (op == 1)
    {
      printf("Digite o valor de a: ");
      scanf("%d", &a);
      printf("Digite o valor de b: ");
      scanf("%d", &b);

      printf("Resultado: %d\n\n", sum(a, b));
    }
    else if (op == 2)
    {
      printf("\nDigite o valor de a: ");
      scanf("%d", &a);

      printf("\nResultado: %d! = %d\n\n", a, factorial(a));
    }
    else
    {
      printf("\nOpção inválida!\n\n");
    }
  }

  return 0;
}