help:
	@echo ""
	@echo "--------------------------------------------"
	@echo "Comandos disponíveis no make:"
	@echo ""
	@echo "run: Compilar e executar"
	@echo "clean: Limpar executável e códigos objetos"
	@echo "compile: Gera apenas os códigos objetos"
	@echo "--------------------------------------------"
	@echo ""

run:
	@gcc -c -std=c99 -o main.o main.c
	@as -o driver.o driver.s
	@gcc main.o driver.o -o main
	@sudo ./main

clean:
	@rm *.o 
	@rm main 
	@echo ""
	@echo "----------------------------------------------"
	@echo "Limpeza realizada"
	@echo "----------------------------------------------"
	@echo ""

compile:
	@gcc -c -std=c99 -o main.o main.c
	@as -o driver.o driver.s
	@gcc main.o driver.o -o main