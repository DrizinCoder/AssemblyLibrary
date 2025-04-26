CC = gcc
AS = as
ASFLAGS = --64
TARGET = program

# Diretórios
SRC_DIR = .
SUM_DIR = sum
FACTORIAL_DIR = factorial

# Arquivos objeto
OBJS = main.o $(SUM_DIR)/sum.o $(FACTORIAL_DIR)/factorial.o

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(OBJS)

main.o: $(SRC_DIR)/main.c
	$(CC) -g -Wall -c $(SRC_DIR)/main.c -o main.o

$(SUM_DIR)/sum.o: $(SUM_DIR)/sum.s
	$(AS) $(ASFLAGS) -o $(SUM_DIR)/sum.o $(SUM_DIR)/sum.s

$(FACTORIAL_DIR)/factorial.o: $(FACTORIAL_DIR)/factorial.s
	$(AS) $(ASFLAGS) -o $(FACTORIAL_DIR)/factorial.o $(FACTORIAL_DIR)/factorial.s

.PHONY: clean run

clean:
	rm -f $(TARGET) $(OBJS)

run: $(TARGET)
	./$(TARGET)