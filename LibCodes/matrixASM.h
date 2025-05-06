#ifndef MATRIXASM_H
#define MATRIXASM_H

void writeMatrix(char *m_pointer_a, char *m_pointer_b, int size, int *address);

void readMatrix(int size, int *address);

void sum();

void sub();

void mul();

void scalar_mul();

void oposite();

void transpose();

void det2();

void det3();

void det4();

void det5();

#endif