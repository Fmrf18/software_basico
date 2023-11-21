#include <alocador.h>
#include <stdio.h>

int main () {
	void *a,*b,*c,*d;

	iniciaAlocador();
	imprimeMapa();

	a = alocaMem(1024);
	imprimeMapa();

	b = alocaMem(64);
	imprimeMapa();
	
	c = alocaMem(200);
	imprimeMapa();

	d = alocaMem(1000);
	imprimeMapa();

	liberaMem(a);
	imprimeMapa();

	liberaMem(d);
	imprimeMapa();

	liberaMem(b);
	imprimeMapa();

	liberaMem(c);
	imprimeMapa();

	return (0);
}
