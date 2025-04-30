# Configurações
IMAGE_NAME = armv7-dev
CONTAINER_NAME = armv7-builder
SOURCE = driver.s
OUTPUT = driver

# Alvo padrão: compila e executa
all: run

# Compila o código ARMv7
compile:
	arm-linux-gnueabihf-as $(SOURCE) -o $(OUTPUT).o
	arm-linux-gnueabihf-ld $(OUTPUT).o -o $(OUTPUT)

# Executa via QEMU
run: compile
	qemu-arm-static ./$(OUTPUT)

# Limpa os arquivos gerados
clean:
	rm driver.o
	rm driver


