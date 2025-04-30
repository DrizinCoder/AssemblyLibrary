SOURCE = driver.s
OUTPUT = driver

# Alvo padrão: compila e executa
all: run

# Compila o código ARMv7
compile:
	as $(SOURCE) -o $(OUTPUT).o
	ld $(OUTPUT).o -o $(OUTPUT)

# Executa via QEMU
run: compile
	./$(OUTPUT)

# Limpa os arquivos gerados
clean:
	rm driver.o
	rm driver


