#ifndef MATRIXASM_H
#define MATRIXASM_H

// Operações básicas
void writeMatrixA(char *m_pointer_a, int size, int *address);
void writeMatrixB(char *m_pointer_b, int size, int *address);
void readMatrix(int size, int *address);

// Operações matriciais
void sum(int *address);
void sub(int *address);
void mul(int *address);
void scalar_mul(int *address);
void oposite(int *address);
void transpose(int *address);

// Cálculo de determinantes
void det2(int *address);
void det3(int *address);
void det4(int *address);
void det5(int *address);

// Auxiliares
int open_memory();
int* map_memory(unsigned int address, unsigned int size);
void unmap_memory(int *mapped_address, unsigned int size);

#endif