%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

struct Atributo {
  string v;  // Valor
  string t;  // Tipo
  string c;  // Codigo
  string label;
  
  Atributo() {}  // inicializacao automatica para vazio ""
  Atributo( string v, string t = "", string c = "", string label = "") {
    this->v = v;
    this->t = t;
    this->c = c;
    this->label = label;
  }
};

void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo atr2, Atributo atr3);

string gerarLabel();
string gerarTemp();

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token _C_INT _C_CHAR _C_DOUBLE _C_STRING _C_BOOL 
%token _TK_ID _TK_IF _TK_FOR _TK_WHILE _TK_DO

%nonassoc '<' '>'
%left '+' '-'
%left '*' '/'

%%

S0 : S { cout << $$.c << endl; }
   ;

S : ATR ';' S { $$.c = $1.c + $3.c; }
  | COMANDO S { $$.c = $1.c + $2.c; }
  | /* epsylon */  { $$.c = ""; }
  ;

BLOCO : '{' S '}' {$$.c = "\n" + $2.c + "\n";}
      ;
         
COMANDO : CMD_IF
        | CMD_FOR
        | CMD_WHILE
        | CMD_DOWHILE
        ;

/*if (a == b) { //codigo qualquer }  */
CMD_IF : _TK_IF '(' EXP ')' BLOCO { $$.label = gerarLabel(); $$.t = gerarTemp();
                                    $$.c = $$.t + " = " + "!" + $3.v + ";\n" + $1.v + " ( " + $$.t + " ) " + "goto " + 
                                    $$.label + $5.c + $3.c + $$.label + ":\n";
                                  }
       ;

/* IDEIA: for (i=0; i<=5; i=i+1 ){ //codigo qualquer }*/
CMD_FOR : _TK_FOR '(' ATR ';' EXP ';' EXP ')' BLOCO
	;
/* IDEIA: while(true){ //codigo qualquer } */
CMD_WHILE : _TK_WHILE '(' EXP ')' BLOCO
	  ;

CMD_DOWHILE : _TK_DO BLOCO _TK_WHILE '(' EXP ')' ';'
	    ;

ATR : _TK_ID '=' EXP { $$.c = $1.c + $3.c + $1.v + " = " + $3.v + ";\n"; }
    ;

EXP : EXP '+' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '-' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '*' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '/' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '>' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '<' EXP  { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | F
    ;

F : _TK_ID		
  | _C_INT    
  | _C_DOUBLE 
  | _C_BOOL
  | '(' EXP ')'  { $$ = $2; }
  ;

%%
int nlinha = 1;
int n_var_temp = 0;
int n_label_temp = 0;

#include "lex.yy.c"

int yyparse();

string toStr( int n )
{
  char buf[1024] = "";
  
  sprintf( buf, "%d", n );
  
  return buf;
}

void yyerror( const char* st )
{
  puts( st );
  printf( "Linha: %d\nPerto de: '%s'\n", nlinha, yytext );
}

void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo atr2, Atributo atr3) 
{
  atr->v = gerarTemp();
  atr->c = atr1.c + atr3.c + atr->v + " = " + atr1.v + " " + atr2.v + " " + atr3.v + ";\n";
}

string gerarTemp()
{
  return "temp_" + toStr( ++n_var_temp );
}

string gerarLabel()
{
  return "LABEL_" + toStr( ++n_label_temp );
}

int main( int argc, char* argv[] )
{
  yyparse();
}
