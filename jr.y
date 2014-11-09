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
  
  Atributo() {}  // inicializacao automatica para vazio ""
  Atributo( string v, string t = "", string c = "" ) {
    this->v = v;
    this->t = t;
    this->c = c;
  }
};

void gerarCodigo_EXPNUM(Atributo *atr, Atributo *atr1 , string oper, Atributo *atr2);

string geraTemp();

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token _INT _CHAR _DOUBLE _STRING _BOOL _ID _IF

%left '+' '-'
%left '*' '/'

%%

S : ATR ';' { cout << $1.c << endl; }
  | COMANDOS { cout << $1.c << endl; }
  | S S
  | /* epsylon */
  ;

BLOCO_IF : '{' S '}' {$$.c = "{\n" + $2.c + "}";}
         ;

COMANDOS : CMD_IF { $$ = $1; }
         ;

CMD_IF : _IF '(' _BOOL ')' BLOCO_IF {$$.c = $1.c + $1.v + " ( " + $3.v + " ) " + $5.c; }
       ;

ATR : _ID '=' EXP_NUM { $$.c = $3.c + $1.v + " = " + $3.v + ";\n"; }
    ;

EXP_NUM : EXP_NUM '+' EXP_NUM  { gerarCodigo_EXPNUM(&$$, &$1 , "+", &$3); }
        | EXP_NUM '-' EXP_NUM  { gerarCodigo_EXPNUM(&$$, &$1 , "-", &$3); }
        | EXP_NUM '*' EXP_NUM  { gerarCodigo_EXPNUM(&$$, &$1 , "*", &$3); }
        | EXP_NUM '/' EXP_NUM  { gerarCodigo_EXPNUM(&$$, &$1 , "/", &$3); }
        | F
        ;

F : _ID		
  | _INT    
  | _DOUBLE 
  | '(' EXP_NUM ')'  { $$ = $2; }
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

void gerarCodigo_EXPNUM(Atributo *atr, Atributo *atr1 , string oper, Atributo *atr2) 
{
  atr->v = geraTemp(); atr->c = atr1->c + atr2->c + atr->v + " = " + atr1->v + " " + oper + " " + atr2->v + ";\n";
}

string geraTemp()
{
  return "temp_" + toStr( ++n_var_temp );
}

string geraLabel()
{
  return "LABEL_" + toStr( ++n_label_temp );
}

int main( int argc, char* argv[] )
{
  yyparse();
}
