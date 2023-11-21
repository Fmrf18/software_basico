############COMPILADORES###############
GCC = gcc
AR = ar
AS = as

##########DIRETORIOS CRIADOS###########
INC=./includes
SRC=./src
BIN=./bin
LIB=./lib

#################FLAGS#################
LIBFLAGS=-lalocador -L$(LIB)
INCFLAGS=-I$(INC)
CFLAGS=-Wall -g -no-pie -fno-pie 
ARFLAGS=rcs


##############LIGACOES#################
build: diretorios libalocador.a
	$(GCC) $(CFLAGS) $(INCFLAGS) $(SRC)/teste.c -o alocador $(LIBFLAGS)

libalocador.a: alocador.o
	$(AR) $(ARFLAGS) $(LIB)/libalocador.a $(BIN)/alocador.o

alocador.o:
	$(AS) $(SRC)/alocador.s -o $(BIN)/alocador.o -g 


########CRICACAO DE DIRETORIOS#########
diretorios:
	@echo "Criando diretorios bin e lib \n"
	
	@if [ ! -d "$(BIN)" ]; then \
		mkdir $(BIN); \
	fi
	
	@if [ ! -d "$(LIB)" ]; then \
		mkdir $(LIB); \
	fi

####LIMPA OS DIRETORIOS E ARQUIVOS#####
clean:
	@echo "Limpando diretorios\n"
	
	@if [ -d "$(BIN)" ]; then \
		rm -r $(BIN); \
	fi
	
	@if [ -d "$(LIB)" ]; then \
		rm -r $(LIB); \
	fi