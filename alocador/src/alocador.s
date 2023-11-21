############ CABECALHO ############

.section .data                                        
	inicio: .quad 0
	topo: .quad 0
	sNadaAlocado: .string "Nada alocado.\n"
	sInicializandoAlocador: .string "Inicializando alocador.\n"
	sCerca: .string "#"
	sMenos: .string "-"
	sAsterisco: .string "*"
	sEspacamentos: .string "\n\n\n"
	flag: .string  "%d"


.section .bss
	.equ LIVRE, 1
	.equ OCUPADO, 0
	.equ TAM_ALOC, 1024

.section .text
	.globl iniciaAlocador
	.globl finalizaAlocador
	.globl alocaMem
	.globl liberaMem
	.globl liberaBrk
	.globl imprimeMapa



############ iniciaAlocador() ############
iniciaAlocador:
	pushq %rbp
	movq %rsp, %rbp
	
	movq $sInicializandoAlocador, %rdi
	call printf

	movq $0, %rdi					# chama brk(0)
	movq $12,%rax
	syscall							# ret valor atual de brk em %rax

	movq %rax, inicio				# inicio = inicio_heap
	addq $TAM_ALOC, %rax			# tamanho a ser alocado (TAM_ALOC)
	movq %rax, topo					# topo = inicio + alocador

	movq %rax, %rdi					# aloca o espaco reservado (TAM_ALOC)
	movq $12, %rax
	syscall
	
	movq inicio, %rax	
	movq $LIVRE, (%rax)				# deixa livre o primeiro slot de memoria (coloca 1 no endereço de %rax)
	movq $TAM_ALOC, %r13
	subq $16, %r13
	movq %r13, 8(%rax)				# disponibiliza o tamanho do espaco alocado
	
	popq %rbp
	ret



############ finalizaAlocador() ############
finalizaAlocador:
	pushq %rbp
	movq %rsp, %rbp

	movq inicio, %rax
	cmpq $0, %rax
	je fim_if
		movq %rax, %rdi		
		movq $12, %rax				# coloca brk no inicio
		syscall

		movq $0, topo				# zera topo e inicio da brk
		movq $0, inicio
		jmp fim_if
	fim_if:
	
	popq %rbp
	ret



############ alocaMem(int num_bytes) ############
alocaMem:
	pushq %rbp
	movq %rsp, %rbp
	# movq $sInicializandoAlocador, %rdi
	# call printf
	subq $8, %rsp					# aloca espaco para a variavel endr
	
	movq %rdi, %r12					# r12 = tamanho do malloc (parametro)
	cmpq $0, %r12
	jne not_zero					# se tentar alocar 0 bytes, retorna
		addq $8, %rsp
		popq %rbp
		ret
	not_zero:
	
	movq inicio, %rax
	cmpq $0, %rax					
	jne mem_alocada	
		call iniciaAlocador			# se a memoria nao foi inicializada (rax = 0), chama o inicializador
	mem_alocada:

	movq inicio, %rbx
	movq %rbx,-8(%rbp)
	
	movq %r12, %r11
	addq $16, %r11					# adiciona 16 (para o cabecalho) ao tamanho do malloc

	verifica_prox_bloco:
	cmpq topo, %rbx					# topo <= inicio?
	jg fim_aloca_mem			
		cmpq $LIVRE, (%rbx)			# conteudo do endereço q está em rbx é LIVRE (1)?
		jne fim_if_while_aloca_mem
			cmpq %r11, 8(%rbx)		# tamanho disponivel > solicitado (tem espaço)?

			jle sem_espaco	
				addq $16, %r12		# r12 = tam_malloc + 16
				subq %r12, 8(%rbx)	# tira o tamanho do malloc + cab do espaço disponível
				movq 8(%rbx), %r13  # r13 = sobra
				subq $16, %r12		# r12 = tam_malloc
				movq %r12, 8(%rbx)	# atualiza tamanho alocado no inicio
				movq $OCUPADO, (%rbx) # atualiza o flag de ocupado
				addq $16, %r12
				addq %r12, %rbx		# rbx = topo - solicitado (fim da heap)
				movq $LIVRE, (%rbx) # marca o bloco como ocupado
				movq %r13, 8(%rbx)	# label = tam_malloc
				subq %r12, %rbx
			jmp fim_alocacao

			sem_espaco:				# se nao tem espaço:
				movq topo, %rbx 	# &inicio = &topo
				
				movq %r12, %rax		# rax = solicitado
				addq $16, %rax		# tam_malloc + 16
				addq %rax, topo
				movq topo, %rdi
				movq $12, %rax
				syscall				# chama brk para o tamanho solicitado

				movq $OCUPADO, (%rbx) # marca o bloco como ocupado
				movq %r12, 8(%rbx)	# label = tam_malloc
				
				movq %rbx, %rcx
				addq %r12, %rcx
				addq $16, %rcx
				movq %rcx, topo 	# atualiza novo topo
			fim_alocacao:
			jmp fim_aloca_mem
		fim_if_while_aloca_mem:

		movq 8(%rbx), %r10
		addq $16, %r10
		addq %r10, %rbx
		jmp verifica_prox_bloco

		addq $16, 8(%rbx)			# adiciona tam do cabeçalho à label
		movq 8(%rbx), %r10
		addq %r10, %rbx				# atualiza inicio
	fim_aloca_mem:	
			
	movq %rbx, %rax					
	addq $16, %rax					# retorna endr + 16
	
	addq $8, %rsp
	popq %rbp
	ret



############ liberaMem(void* bloco) ############
liberaMem:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rbx
	movq $LIVRE, -16(%rbx)			# marca o bloco como livre
	call liberaBrk	

	popq %rbp
	ret



############ liberaBrk() ############
liberaBrk:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp					# aloca 2 var

	movq inicio, %r10
	movq %r10, -8(%rbp)				# endr_ant = &inicio
	movq -8(%rbp), %rax
	
	movq inicio, %rbx
	addq $16, %rbx
	addq 8(%rax), %rbx
	movq %rbx, -16(%rbp)			# endr = &inicio + label + 16

	loop_libera_brk:
	cmpq topo, %rbx					# endr chegou no topo da heap?
	jge fim_loop_libera_brk
		cmpq $1, (%rbx)				
		jne if_ambos_livres
		cmpq $1, (%rax)
		jne if_ambos_livres
			movq 8(%rbx), %r10		# se ambos livres, atualiza a qtd de bytes livres do endr anterior

			addq %r10, 8(%rax)		
			addq $16, 8(%rax)

		jmp fim_if_ambos_livres
		if_ambos_livres:
			movq %rbx, %rax			# endr = endr_ant
		jmp fim_if_ambos_livres
	fim_if_ambos_livres:
	
	movq 8(%rbx), %r13
	addq $16, %r13
	addq %r13, %rbx					# vai até o fim do bloco e repete o processo

	jmp loop_libera_brk
	fim_loop_libera_brk: 

	addq $16, %rsp					# desaloca as 2 vars
	popq %rbp
	ret



############ imprimeMapa() ############
imprimeMapa:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp					# aloca 2 vars

	movq inicio, %rbx				# rbx = &inicio
	movq topo, %r11					# r11 = &topo
	
	cmpq $0, %rbx					# &inicio vazio (nd alocado)?
	jne if_piso_naovazio	
		movq $sNadaAlocado, %rdi
		call printf					# msg: nada alocado
		addq $16, %rsp
		popq %rbp
		ret		 
	
	if_piso_naovazio:
	movq %rbx,-16(%rbp)				# endr = -8(rbp)
	while_loop:
	cmpq topo, %rbx
	jge fim_while_loop

		movq $0, -8(%rbp)	
		movq -8(%rbp), %r12	
		for_printa_cabecalho:
		cmpq $16, %r12
		jge fim_for_printa_cabecalho
			movq $sCerca, %rdi
			call printf
			addq $1, %r12
			jmp for_printa_cabecalho
		fim_for_printa_cabecalho:
			
			#movq $flag, %rdi
			#movq 8(%rbx), %rsi
			#call printf
		
		cmpq $LIVRE, (%rbx)			# endereco livre?
		jne endr_ocupado
			movq $0, -8(%rbp)
			movq -8(%rbp), %r12
			for_livre:
			cmpq 8(%rbx), %r12		# for i < tam_alocado
			jge fim_for_livre
				movq $sMenos, %rdi
				call printf
				addq $1, %r12
				jmp for_livre
			fim_for_livre:
			jmp continuacao_while

		endr_ocupado:
			movq $0, -8(%rbp)
			movq -8(%rbp), %r12
			for_ocupado:
			cmpq 8(%rbx), %r12		# for i < tam_alocado
			jge fim_for_ocupado
				movq $sAsterisco, %rdi
				call printf
				addq $1, %r12
				jmp for_ocupado
			fim_for_ocupado:
			jmp continuacao_while
		
		continuacao_while:
		movq 8(%rbx), %r13			
		addq $16, %r13
		addq %r13, %rbx				# endr = proximo bloco

		jmp while_loop
	
	fim_while_loop:
	
	movq $sEspacamentos, %rdi
	call printf

	addq $16, %rsp
	popq %rbp
	ret
