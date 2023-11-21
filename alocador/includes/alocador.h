#ifndef __ALOCADOR__
#define __ALOCADOR__

//inicia o alocador chamando a brk e atribuindo um valor pre determinado
void iniciaAlocador();

//finaliza o alocador voltando a heap para o seu inicio
void finalizaAlocador();

//Aloca o ponteiro na heap
void* alocaMem(int tam_alloc);

//libera o ponteiro da heap
void liberaMem(void* bloco);

//rearranja os elementos dentro da heap liberando espacos desnecessarios
void liberaBrk();

//escreve o estado atual da heap
void imprimeMapa();

#endif