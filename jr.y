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
%token _TK_ID _TK_IF _TK_ELSE _TK_FOR _TK_WHILE _TK_DO _TK_SWITCH _TK_CASE _TK_BREAK _TK_DEFAULT

%nonassoc _PRECEDENCIA_ELSE
%nonassoc _TK_ELSE
%nonassoc '<' '>'
%left '+' '-'
%left '*' '/'

%%

S0 : S { cout << $$.c << endl; }
   ;

S : DECLARAR_VAR ';'
  | ATR ';' S 
        { $$.c = $1.c + $3.c; }
  | COMANDO S 
        { $$.c = $1.c + $2.c; }
  | /* epsylon */  { $$.c = ""; }
  ;

BLOCO : '{' S '}' {$$.c = "\n" + $2.c;}
      ;

BLOCO_OPCIONAL : BLOCO   
                    { $$.c = $1.c; }
               | ATR ';'
                    { $$.c = $1.c; }
               | COMANDO 
                    { $$.c = $1.c; }
               ;

COMANDO : CMD_IF
        | CMD_FOR
        | CMD_WHILE
        | CMD_DOWHILE
	    | CMD_SWITCH
        ;

/*if (a == b) { //codigo qualquer }  */
CMD_IF : _TK_IF '(' EXP ')' BLOCO_OPCIONAL  %prec _PRECEDENCIA_ELSE
                                  { $$.label = gerarLabel(); $$.t = gerarTemp();
                                    $$.c =  $3.c + $$.t + " = " + "!" + $3.v + ";\n" + $1.v + " ( " + $$.t + " ) " + "goto " + 
                                    $$.label + $5.c + $$.label + ":";
                                  }
       | _TK_IF '(' EXP ')' BLOCO_OPCIONAL _TK_ELSE BLOCO_OPCIONAL
                                  { $$.label = gerarLabel(); $$.t = gerarTemp();
                                    $$.c =  $3.c + $$.t + " = " + "!" + $3.v + ";\n" + $1.v + " ( " + $$.t + " ) " + "goto " + 
                                    $$.label + $5.c + $$.label + ":\n" + $7.c;
                                  }
       ;

/* IDEIA: for (i=0; i<=5; i=i+1 ){ //codigo qualquer }*/
CMD_FOR : _TK_FOR '(' ATR ';' EXP ';' EXP ')' BLOCO_OPCIONAL
	;
/* IDEIA: while(true){ //codigo qualquer } */
CMD_WHILE : _TK_WHILE '(' EXP ')' BLOCO_OPCIONAL
	  ;

CMD_DOWHILE : _TK_DO BLOCO _TK_WHILE '(' EXP ')' ';'
	    ;

CMD_SWITCH : _TK_SWITCH '(' _TK_ID ')' '{' LST_CASE '}'
	   ;

LST_CASE : CASE LST_CASE
         | _TK_DEFAULT ':' S _TK_BREAK ';'
         | /* epsylon */
         ;
         
CASE : _TK_CASE  _TK_ID    ':' BLOCO_CASE
     | _TK_CASE  _C_INT    ':' BLOCO_CASE
     | _TK_CASE  _C_CHAR   ':' BLOCO_CASE
     | _TK_CASE  _C_STRING ':' BLOCO_CASE
	 ;

BLOCO_CASE : S _TK_BREAK ';'
	       ;

DECLARAR_VAR : VAR_ARRAY ';'
             ;

VAR_ARRAY : _TK_ID ARRAY
	      ;

ARRAY : '[' _C_INT ']'
      | '[' _C_INT ']' '[' _C_INT ']'
      ;

ATR : _TK_ID '=' EXP 
            { $$.c = $1.c + $3.c + $1.v + " = " + $3.v + ";\n"; }
    ;

EXP : EXP '+' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '-' EXP 
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '*' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '/' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '>' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '<' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | F
    ;

F : _TK_ID
  | _C_INT 
  | _C_DOUBLE
  | _C_BOOL
  | _C_STRING
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
