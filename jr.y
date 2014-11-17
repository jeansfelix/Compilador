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
void gerarCodigo_EXP_UNARIA(Atributo *atr, Atributo atr1 , Atributo atr2);

string gerarLabel();
string gerarTemp();

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token _C_INT _C_CHAR _C_DOUBLE _C_STRING _C_BOOL _C_FLOAT
%token _TK_ID _TK_IF _TK_ELSE _TK_FOR _TK_WHILE _TK_DO _TK_SWITCH _TK_CASE _TK_BREAK _TK_DEFAULT _TK_RETURN _TK_GLOBAL
%token _TK_INT _TK_CHAR _TK_DOUBLE _TK_STRING _TK_BOOL _TK_FLOAT _TK_VOID
%token _OP_NOT _OP_EQUAL _OP_DIF _OP_LESS_OR_EQUAL _OP_GREATER_OR_EQUAL _OP_INC _OP_DEC _OP_OR _OP_AND
%token _IO_PRINT _IO_SCAN

%nonassoc _PRECEDENCIA_ELSE
%nonassoc _TK_ELSE
%nonassoc _OP_NOT _OP_EQUAL _OP_DIF _OP_LESS_OR_EQUAL _OP_GREATER_OR_EQUAL 
%nonassoc '<' '>'
%left _OP_OR
%left _OP_AND
%left '+' '-'
%left '*' '/'
%left _OP_INC _OP_DEC
%left '%'

%%

S0 : GLOBAL_VAR LST_FUNC { cout << $$.c << endl; }
   ;

LST_FUNC : TIPO _TK_ID '(' LST_ARGUMENTOS ')' BLOCO LST_FUNC
                    { $$.c = $1.c + " " + $2.v + $3.v + $4.c + $5.v + "\n{" + $6.c + "}\n" + $7.c; }
         | /* epsylon */
                    { $$.c = ""; }
         ;

LST_ARGUMENTOS : TIPO _TK_ID ',' LST_ARGUMENTOS 
                    { $$.c = $1.c + " " + $2.v + $3.v + " " + $4.c; }
               | TIPO _TK_ID
                    { $$.c = $1.c + " " + $2.v; }
               | /* epsylon */
                    { $$.c = ""; }
               ;

CHAMA_FUNC : _TK_ID '(' LST_CHAMA_FUNC ')'
	   ;

LST_CHAMA_FUNC : _TK_ID ',' LST_CHAMA_FUNC 
	       | EXP ',' LST_CHAMA_FUNC 
               | _TK_ID
	       | EXP
               | /* epsylon */
                    { $$.c = ""; }
               ;

S : VAR ';' S 
        { $$.c = $1.c + $3.c; }
  | VAR_ARRAY ';' S
        { $$.c = $1.c + $3.c; }
  | ATR ';' S 
        { $$.c = $1.c + $3.c; }
  | COMANDO S 
        { $$.c = $1.c + $2.c; }
  | /* epsylon */
        { $$.c = ""; }
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

BLOCO_CASE : S _TK_BREAK ';'
	   | CASE
	   ;

COMANDO : CMD_IF
        | CMD_FOR
        | CMD_WHILE
        | CMD_DOWHILE
        | CMD_SWITCH
        | CMD_RETURN
  	| CMD_LEITURA
	| CMD_ESCRITA
	| CHAMA_FUNC ';'
        ;

CMD_RETURN : _TK_RETURN F ';'
           | _TK_RETURN ';'
           ;

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

CMD_FOR : _TK_FOR '(' ATR ';' EXP ';' ATR ')' BLOCO_OPCIONAL
        ;

CMD_WHILE : _TK_WHILE '(' EXP ')' BLOCO_OPCIONAL
          ;

CMD_DOWHILE : _TK_DO BLOCO _TK_WHILE '(' EXP ')' ';'
            ;

CMD_SWITCH : _TK_SWITCH '(' _TK_ID ')' '{' LST_CASE '}'
           ;

LST_CASE : CASE LST_CASE
         | _TK_DEFAULT ':' S _TK_BREAK ';'
         | /* epsylon */
                { $$.c = ""; }
         ;
         
CASE : _TK_CASE  _TK_ID    ':' BLOCO_CASE
     | _TK_CASE  _C_INT    ':' BLOCO_CASE
     | _TK_CASE  _C_CHAR   ':' BLOCO_CASE
     | _TK_CASE  _C_STRING ':' BLOCO_CASE
     ;

VAR : VAR ',' _TK_ID
    | TIPO _TK_ID
    ;
    
TIPO : _TK_INT      { $$.c = $1.v; }
     | _TK_CHAR     { $$.c = $1.v; }
     | _TK_BOOL     { $$.c = $1.v; }
     | _TK_DOUBLE   { $$.c = $1.v; }
     | _TK_FLOAT    { $$.c = $1.v; }
     | _TK_STRING   { $$.c = $1.v; }
     | _TK_VOID     { $$.c = $1.v; }
     ;
     
VAR_ARRAY : TIPO '[' ']' _TK_ID ARRAY
          ;

ARRAY : '[' _C_INT ']' ARRAY
             { $$.c = $2.v ;}
      | /* epsylon */
             { $$.c = ""; }
      ;

GLOBAL_VAR : _TK_GLOBAL '{' LST_GLOBAL_VAR '}' ';'
	   | /* epsylon */
             { $$.c = ""; }
	   ;

LST_GLOBAL_VAR : VAR ';' LST_GLOBAL_VAR
	       | VAR_ARRAY ';' LST_GLOBAL_VAR
               | /* epsylon */
                    { $$.c = ""; }
               ;

ATR : _TK_ID '=' EXP 
            { $$.c = $3.c + $1.v + " = " + $3.v + ";\n"; }
    | _TK_ID '[' EXP ']' '=' EXP 
            { $$.c = $6.c + $3.c + $1.v + $2.v + $3.v + $4.v + $3.c + " = " + $6.v + ";\n"; }
    | _TK_ID '=' CHAMA_FUNC
    ;

EXP : EXP '+' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '-' EXP 
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '*' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '/' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '%' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '>' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP '<' EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_EQUAL EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_DIF EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_LESS_OR_EQUAL EXP
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_GREATER_OR_EQUAL EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_OR EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP _OP_AND EXP  
            { gerarCodigo_EXP(&$$, $1 , $2, $3); }
    | EXP_UNARIA
            { $$.c = $1.c; }
    | _TK_ID '[' INDICE ']'
            { $$.v = gerarTemp(); $$.c = $1.v + $2.v + $3.v +  $4.v + "\n"; }
    | F
    ;
    
INDICE : EXP ',' INDICE
       | EXP
       ;
           
EXP_UNARIA : _OP_INC EXP
                { gerarCodigo_EXP_UNARIA(&$$, $1, $2); }
           | _OP_DEC EXP
                { gerarCodigo_EXP_UNARIA(&$$, $1, $2); }
           | _OP_NOT EXP
                { gerarCodigo_EXP_UNARIA(&$$, $1, $2); }
           ;

CMD_ESCRITA : _IO_PRINT '(' F ')' ';'
	;
			
CMD_LEITURA : _IO_SCAN '(' _TK_ID ')' ';'
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

void gerarCodigo_EXP_UNARIA(Atributo *atr, Atributo atr1 , Atributo atr2) 
{
  atr->v = gerarTemp(); 
  atr->c = atr2.c + atr->v + " = " + atr1.v + atr2.v + ";\n";
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
