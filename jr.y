/**
Nome: Renan Hozumi Barbieri; DRE: 111201610
Nome: Jean Da Silva Felix; DRE: 111318920
**/

%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

const int MAX_STRING = 256;

struct Tipo {
  string nome;
  
  Tipo() {}
  Tipo( string nome ) {
    this->nome = nome;
  }
};

struct Atributo {
  string v;  // Valor
  Tipo t;    // Tipo
  string c;  // Codigo
  string label;
  
  Atributo() {}  // inicializacao automatica para vazio ""
  Atributo( string v, string t = "", string c = "", string label = "") {
    this->v = v;
    this->t.nome = t;
    this->c = c;
    this->label = label;
  }
};

typedef map< string, Tipo > TS;
typedef map< string, TS > FunctionScopes;

TS tsGlobais;
FunctionScopes fs;

string scope = "global";

string gerarLabel(string cmd);
string gerarTemp(Tipo tipo);

void erro( string msg );

void inicializarResultadoOperacao();
Tipo tipoResultado( Tipo a, string operador, Tipo b );

string gerarDeclaracaoVariaveisTemporarias();
string gerarDeclaracaoVariaveisGlobais();
string gerarDeclaracaoVariaveisLocais(string escopoFuncao);

bool buscarVariavelTS( TS& ts, string nomeVar, Tipo* tipo );
bool buscarVariavelTS( TS& ts, string nomeVar );
bool verificarSeVariavelFoiDeclarada(string nomeVar);

void gerarCodigo_Atribuicao(Atributo *SS, Atributo *S1, const Atributo S3);
void gerarDeclaracaoVariavel(Atributo* SS, const Atributo& tipo, const Atributo& id );
void inserirVariavelTS( string nomeVar, Tipo tipo );
void gerarCodigo_F_para_TK_ID(Atributo *atr, Atributo atr1);

void gerarCodigoIf(Atributo *SS, Atributo exp_if, Atributo bloco_if);
void gerarCodigoIfElse(Atributo *SS, Atributo exp_if, Atributo bloco_if, Atributo bloco_else);
void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo atr2, Atributo atr3);
void gerarCodigo_EXP_UNARIA(Atributo *atr, Atributo atr1 , Atributo atr2);


#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token _C_INT _C_CHAR _C_DOUBLE _C_STRING _C_BOOL _C_FLOAT
%token _TK_ID _TK_IF _TK_ELSE _TK_FOR _TK_WHILE _TK_DO _TK_SWITCH _TK_CASE _TK_BREAK _TK_DEFAULT _TK_RETURN
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

S0 : GLOBAL_VAR { cout << "#include <stdio.h>\n"
                          "#include <stdlib.h>\n"
                          "#include <string.h>\n\n"
                       << gerarDeclaracaoVariaveisTemporarias() << gerarDeclaracaoVariaveisGlobais() + "\n" << $1.c << endl; }
   ;

GLOBAL_VAR : VAR_ARRAY ';' GLOBAL_VAR
                    {$$.c = $3.c;}
           | VAR ';' GLOBAL_VAR 
                    {$$.c = $3.c;}
           | FUNCOES 
                    {$$.c = $1.c;}
           ;

FUNCOES : TIPO NOME_FUNC '(' ARGUMENTOS ')' BLOCO FUNCOES
                    { $$.c = $1.t.nome + " " + $2.v + $3.v + $4.c + $5.v + 
                          "\n{\n" + gerarDeclaracaoVariaveisLocais($2.v) + $6.c + "}\n\n" + $7.c; }
         | /* epsylon */
                    { $$.c = ""; }
         ;
         
NOME_FUNC : _TK_ID
              {scope = $1.v; $$ = $1;}
          ;

ARGUMENTOS : TIPO _TK_ID ',' ARGUMENTOS 
                { $$.c = $1.t.nome + " " + $2.v + $3.v + " " + $4.c; }
           | TIPO _TK_ID
                { $$.c = $1.t.nome + " " + $2.v; }
           | /* epsylon */
                { $$.c = ""; }
           ;

PARAMETROS : EXP ',' PARAMETROS
           | EXP
           | /* epsylon */
                { $$.c = ""; }
           ;

S : VAR ';' S 
        { $$.c = $1.c + "\n" + $3.c; }
  | VAR_ARRAY ';' S
        { $$.c = $1.c + "\n" + $3.c; }
  | ATR ';' S 
        { $$.c = $1.c + $3.c; }
  | COMANDO S 
        { $$.c = $1.c + $2.c; }
  | /* epsylon */
        { $$.c = ""; }
  ;

BLOCO : '{' S '}' {$$.c = $2.c;}
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
            {$$ = $1;}
        | CMD_FOR
            {$$ = $1;}
        | CMD_WHILE
            {$$ = $1;}
        | CMD_DOWHILE
            {$$ = $1;}
        | CMD_SWITCH
            {$$ = $1;}
        | CMD_RETURN
            {$$ = $1;}
      	| CMD_LEITURA
      	    {$$ = $1;}
	    | CMD_ESCRITA
	        {$$ = $1;}
	    | CHAMA_FUNC
	        {$$ = $1;}
        ;

CMD_RETURN : _TK_RETURN F ';'
                {$$.c = "    " + $1.v + " " + $2.v + ";\n";}
           | _TK_RETURN ';'
                {$$.c = "    " + $1.v + ";\n";}
           ;

CMD_IF : _TK_IF '(' EXP ')' BLOCO_OPCIONAL  %prec _PRECEDENCIA_ELSE
                                  { gerarCodigoIf(&$$, $3, $5); }
       | _TK_IF '(' EXP ')' BLOCO_OPCIONAL _TK_ELSE BLOCO_OPCIONAL
                                  { gerarCodigoIfElse(&$$, $3, $5, $7); }
       ;

CMD_FOR : _TK_FOR '(' ATR ';' EXP ';' ATR ')' BLOCO_OPCIONAL
        ;

CMD_WHILE : _TK_WHILE '(' EXP ')' BLOCO_OPCIONAL
          ;

CMD_DOWHILE : _TK_DO BLOCO _TK_WHILE '(' EXP ')' ';'
            ;

CMD_SWITCH : _TK_SWITCH '(' _TK_ID ')' '{' LST_CASE '}'
           ;

CMD_ESCRITA : _IO_PRINT '(' F ')' ';'
                    { $$.c = "    printf(\"%s\"," + $3.v + ");\n"; }
	        ;
			
CMD_LEITURA : _IO_SCAN '(' _TK_ID ')' ';'
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

VAR_ARRAY : TIPO '[' ']' _TK_ID ARRAY
                 { gerarDeclaracaoVariavel( &$$, $1, $2 ); }
          ;

ARRAY : '[' _C_INT ']' ARRAY
             { $$.c = $2.v ;}
      | /* epsylon */
             { $$.c = ""; }
      ;

VAR : VAR ',' _TK_ID
        { gerarDeclaracaoVariavel( &$$, $1, $3 ); }
    | TIPO _TK_ID
        { gerarDeclaracaoVariavel( &$$, $1, $2 ); }
    ;
    
TIPO : _TK_INT      { $$ = $1; }
     | _TK_CHAR     { $$ = $1; }
     | _TK_BOOL     { $$ = $1; }
     | _TK_DOUBLE   { $$ = $1; }
     | _TK_FLOAT    { $$ = $1; }
     | _TK_STRING   { $$ = $1; }
     | _TK_VOID     { $$ = $1; }
     ;
     
CHAMA_FUNC : _TK_ID '(' PARAMETROS ')'
	       ;     
	       
ATR : _TK_ID '=' EXP
            { gerarCodigo_Atribuicao(&$$, &$1, $3); }
    | _TK_ID '[' EXP ']' '=' EXP 
            { $$.c = $6.c + $3.c + "    " + $1.v + $2.v + $3.v + $4.v + $3.c + " = " + $6.v + ";\n"; }
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
            { $$.v = gerarTemp($1.t); $$.c = $1.v + $2.v + $3.v + $4.v + "\n"; }
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

F : _TK_ID       { gerarCodigo_F_para_TK_ID(&$$, $1); }	
  | _C_INT       { $$ = $1; }
  | _C_DOUBLE    { $$ = $1; }
  | _C_BOOL      { $$ = $1; }
  | _C_STRING    { $$ = $1; }
  | _C_FLOAT     { $$ = $1; }
  | '(' EXP ')'  { $$ = $2; }
  | CHAMA_FUNC   { $$ = $1; }
  ;

%%
int nlinha = 1;

map<string,int> n_var_temp;
map<string,Tipo> resultadoOperacao;
map<string,int> n_label;

#include "lex.yy.c"

int yyparse();

void erro( string msg )
{
  yyerror( msg.c_str() );
  exit(0);
}

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

Tipo tipoResultado( Tipo a, string operador, Tipo b ) 
{
  if( resultadoOperacao.find( a.nome + operador + b.nome ) == resultadoOperacao.end() )
    erro( "Operacao nao permitida: " + a.nome + operador + b.nome );

  return resultadoOperacao[a.nome + operador + b.nome];
}

void gerarCodigo_Atribuicao(Atributo *SS, Atributo *S1, Atributo S3)
{
    bool varEhGlobal = buscarVariavelTS( tsGlobais, S1->v);

    if (!varEhGlobal && !buscarVariavelTS(fs[scope], S1->v)) 
    {
         erro( "Variavel nao declarada: " + S1->v );
    }
       
    if (varEhGlobal) 
    {
        S1->t = tsGlobais[S1->v];
    }
    else
    {
        S1->t = fs[scope][S1->v];
    }

    if (S1->t.nome == S3.t.nome ) 
    {
        if (S1->t.nome == "string") 
        {
            SS->c = S3.c + "    strcpy(" + S1->v + ", " + S3.v + ");\n";
            SS->t = S1->t;
        }
        else 
        {
            SS->c = S3.c + "    " + S1->v + " = " + S3.v + ";\n";
            SS->t = S1->t;
        }
    }
    else
    {
        erro("Tipo " +  S3.t.nome + " não pode ser atribuído a " + S1->t.nome + " \n");
    }
}

void gerarCodigoIf(Atributo *SS, Atributo exp_if, Atributo bloco_if)
{
    string label_if_false = gerarLabel("if_false"); 
    string temp = gerarTemp(Tipo("boolean"));
    
    SS->c =  exp_if.c + "    " + temp + " = " + "!" + exp_if.v + ";\n    if ( " + temp + " ) goto " + label_if_false + ";\n" + 
             bloco_if.c + label_if_false + ":\n";
}

void gerarCodigoIfElse(Atributo *SS, Atributo exp_if, Atributo bloco_if, Atributo bloco_else)
{
    string label_if_true        = gerarLabel("if_true");
    string label_fim_if_else    = gerarLabel("fim_if_else");
    
    SS->c =  exp_if.c + "    if ( " + exp_if.v + " ) goto " + label_if_true + ";\n" + 
             bloco_else.c + "    goto " + label_fim_if_else + ";\n" + label_if_true + ":\n" +
             bloco_if.c + label_fim_if_else + ":\n";
}

void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo atr2, Atributo atr3) 
{
    atr->t = tipoResultado( atr1.t, atr2.v, atr3.t );
    atr->v = gerarTemp(atr->t);
    atr->c = atr1.c + atr3.c + "    " + atr->v + " = " + atr1.v + " " + atr2.v + " " + atr3.v + ";\n";
}

void gerarCodigo_EXP_UNARIA(Atributo *atr, Atributo atr1 , Atributo atr2) 
{
    atr->t = tipoResultado( Tipo(""), atr1.v, atr2.t );
    atr->v = gerarTemp(atr->t); 
    atr->c = atr2.c + "    " + atr->v + " = " + atr1.v + atr2.v + ";\n";
}

bool buscarVariavelTS( TS& ts, string nomeVar, Tipo* tipo )
{
  if( ts.find( nomeVar ) != ts.end() ) 
  {
    *tipo = ts[ nomeVar ];
    return true;
  }
  else
    return false;
}

bool buscarVariavelTS( TS& ts, string nomeVar )
{
  if( ts.find( nomeVar ) != ts.end() ) 
  {
    return true;
  }
  else
    return false;
}

void gerarDeclaracaoVariavel(Atributo* SS, const Atributo& tipo, const Atributo& id )
{
    SS->v = "";

    if (verificarSeVariavelFoiDeclarada(id.v)) 
    {
        erro( "Redeclaração da variavel: " + id.v );
    }

    inserirVariavelTS(id.v, tipo.t );
}

void inserirVariavelTS(string nomeVar, Tipo tipo ) 
{
    if (scope == "global") 
    {
        if( !buscarVariavelTS( tsGlobais, nomeVar, &tipo ))
        {
            tsGlobais[nomeVar] = tipo;
            return;
        }
        else  
        {
            erro( "Variavel já definida: " + nomeVar );
        }
    }

    if( !buscarVariavelTS( tsGlobais, nomeVar, &tipo ) && !buscarVariavelTS(fs[scope], nomeVar, &tipo))
    {
        fs[scope][nomeVar] = tipo;
    }
    else  
    {
        erro( "Variavel já definida: " + nomeVar );
    }
}

bool verificarSeVariavelFoiDeclarada(string nomeVar)
{
    if( buscarVariavelTS( tsGlobais, nomeVar) || buscarVariavelTS(fs[scope], nomeVar) )  
    {
        return true;
    }
    return false;
}

void gerarCodigo_F_para_TK_ID(Atributo *atr, Atributo atr1) 
{
    if (buscarVariavelTS(tsGlobais, atr1.v))
    {
        atr->v = atr1.v;
        atr->t = tsGlobais[atr->v];
        return;
    }

    if( buscarVariavelTS(fs[scope], atr1.v) )  
    {
        atr->v = atr1.v;
        atr->t = fs[scope][atr->v];
        return;
    }
    erro( "Variavel nao declarada: " + atr1.v );
}

string gerarDeclaracaoVariaveisGlobais() {
    string c = "";
    
    for (std::map<string, Tipo>::iterator it=tsGlobais.begin(); it!=tsGlobais.end(); ++it)
    {
        if (it->second.nome != "string")
        {
            c = c + it->second.nome + " " + it->first + ";\n";
        }
        else {
            c = c + "char " + it->first + "["+ toStr( MAX_STRING ) +"];\n"; ;
        }
    }
    
    return c;
}

string gerarDeclaracaoVariaveisLocais(string escopoFuncao) {
    TS ts = fs[escopoFuncao];
    
    string c = "";
    
    for (std::map<string, Tipo>::iterator it=ts.begin(); it!=ts.end(); ++it)
    {
        if (it->second.nome != "string")
        {
            c = c + "    " + it->second.nome + " " + it->first + ";\n";
        }
        else {
            c = c + "    char " + it->first + "["+ toStr( MAX_STRING ) +"];\n"; ;
        }
    }
    
    return c;
}

string gerarDeclaracaoVariaveisTemporarias() {
    string c;

    for( int i = 0; i < n_var_temp["boolean"]; i++ )
        c += "int temp_boolean_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["int"]; i++ )
        c += "int temp_int_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["char"]; i++ )
        c += "char temp_char_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["double"]; i++ )
        c += "double temp_double_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["float"]; i++ )
        c += "float temp_float_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["string"]; i++ )
        c += "char temp_string_" + toStr( i + 1 ) + "[" + toStr( MAX_STRING )+ "];\n";

    return c;  
}

string gerarTemp(Tipo tipo)
{
    return "temp_" + tipo.nome + "_" + toStr( ++n_var_temp[tipo.nome] );
}

string gerarLabel(string cmd)
{
    return "LABEL_" + cmd + "_" + toStr( ++n_label[cmd] );
}

void inicializarResultadoOperacao()
{
  resultadoOperacao["string+string"] = Tipo("string");
  resultadoOperacao["string+int"] = Tipo("string");
  resultadoOperacao["int+string"] = Tipo("string");
  
  resultadoOperacao["int+int"] = Tipo("int");
  resultadoOperacao["int-int"] = Tipo("int");
  resultadoOperacao["int*int"] = Tipo("int");
  resultadoOperacao["int%int"] = Tipo("int");
  resultadoOperacao["int/int"] = Tipo("int");
  resultadoOperacao["++int"] = Tipo("int");
  resultadoOperacao["--int"] = Tipo("int");
  
  resultadoOperacao["int==int"] = Tipo("boolean");
  resultadoOperacao["int<int"] = Tipo("boolean");
  resultadoOperacao["int>int"] = Tipo("boolean");
  resultadoOperacao["int<=int"] = Tipo("boolean");
  resultadoOperacao["int>=int"] = Tipo("boolean");
  resultadoOperacao["!boolean"] = Tipo("boolean");
  
  resultadoOperacao["double+int"] = Tipo("double");
  resultadoOperacao["int*double"] = Tipo("double");
}

int main( int argc, char* argv[] )
{
    inicializarResultadoOperacao();
    yyparse();
}
