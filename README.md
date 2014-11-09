Compilador
==========

Compilador feito através do uso do LEX e do YACC para estudo e compreensão de compilação de uma linguagem criada para a linguagem C-Assembly uma linguagem que nos lembra o assembly com algumas facilitações.


Requisitos Funcionais:

1) Tipos: int, char, boolean, float, double, string

2) Estruturas de controle: if/else, for, while, do-while, switch.

3) Array bi-dimensional

4) Blocos

5) Variáveis locais e globais, com escopo.

6) Expressões com precedência e associatividade de operadores

7) Funções com parametros por valor e referência

8) Concatenação de strings com operador "+"

9) Entrada e saida padrao (printf e scanf)

9) Verificação de tipos

10) Verificação do número e tipo dos parâmetros de funções

11) Operadores básicos: ( ) + - / * % && || ! > < >=


Pipes:

12) intervalo: [ 0 .. 10 ] 

13) filter[ x % 2 == 0 ]

14) forEach[ print( x ) ]

15) firstN[ 10 ]

16) lastN[ 10 ]

17) sort[ x ]

18) split[ x > 6 ]( a, b )

19) merge( a, b )[ x == y ]


C-Assembly

C-Assembly: C apenas com:

  1) Comando if/goto, sem blocos,
  2) Funções,
  3) Parâmetros,
  4) Arrays unidimensionais,
  5) Tipos: int, long, char, float e double,
  6) Expressões com uma atribuição e um dos operadores a seguir:
      + - * / % < > = == != || && ! | & ^ ~
  7) Uso de array: apenas um array por atribuição sem outro operador,
      a = m[x];
  8) Chamadas de função: sem expressões como parâmetros, apenas variáveis ou valores,
  9) Variáveis local e global.
  
