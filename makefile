all: gerarSaida saida
	gcc -o saida saida.c -Wall

gerarSaida: trabalho entrada.cc
	./jr < entrada.cc > saida.c

lex.yy.c: jr.lex
	lex jr.lex

y.tab.c: jr.y
	yacc jr.y

trabalho: lex.yy.c y.tab.c
	g++ -o jr y.tab.c -lfl
