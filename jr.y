/**
Nome: Renan Hozumi Barbieri;  DRE: 111201610
Nome: Jean Da Silva Felix;    DRE: 111318920
**/

%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>
#include <vector>

using namespace std;

const int MAX_STRING = 256;
/*
*   Utilizo tamanhos tanto para guardar os valores do indice de uma matriz
*   como para guardar os valores do tamanho de linha e coluna de uma matriz.
*/
struct Tipo {
  string nome;
  vector<string> tamanhos;
  
  Tipo() {}
  Tipo(string nome) {
    this->nome = nome;
  }
};

struct Atributo {
  string v;  // Valor
  Tipo t;    // Tipo
  string c;  // Codigo
  string fimLoop;
  
  Atributo() {}  // inicializacao automatica para vazio ""
  Atributo( string v, string t = "", string c = "", string fimLoop = "") {
    this->v = v;
    this->t.nome = t;
    this->c = c;
    this->fimLoop = fimLoop;
  }
};

typedef map< string, Tipo > TS;
typedef map< string, TS > FunctionScopes;

TS tsGlobais;
FunctionScopes fs;
vector<string> pilhaFimLoop;

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

void gerarDeclaracaoVariavel(Atributo* SS, const Atributo& tipo, const Atributo& id );
void gerarDeclaracaoVariavelArray(Atributo* SS, const Atributo& tipo, const Atributo& id, const Atributo& array );

void gerarCodigo_Atribuicao(Atributo *SS, Atributo *S1, const Atributo S3);
void inserirVariavelTS( string nomeVar, Tipo tipo );

void gerarCodigo_F_para_TK_ID(Atributo *atr, const Atributo& id);
void gerarCodigo_F_para_TK_ID_ARRAY(Atributo *atr, const Atributo& id, const Atributo& index);
int calcularIndice(vector<string> valorDimensoes, vector<string> dimensoes);

void gerarCodigoIf(Atributo *SS, Atributo exp_if, Atributo bloco_if);
void gerarCodigoIfElse(Atributo *SS, Atributo exp_if, Atributo bloco_if, Atributo bloco_else);

string gerarCodigoBreak();
void gerarCodigoWhile(Atributo *SS, const string fim_while, const Atributo& condicao, const Atributo& bloco_while);
void gerarCodigoDoWhile(Atributo *SS, const string fim_dowhile, const Atributo& condicao, const Atributo& bloco_while);
void gerarCodigoFor( Atributo* SS, const string fim_for,const Atributo& inicial, const Atributo& condicao, const Atributo& passo, const Atributo& cmds);

void gerarCodigoSwitch();//TODO

void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo operador, Atributo atr2);
void gerarCodAux_Int_String(string *atr1Value, string *atr2Value, string *cod_aux, string *cod_free, Tipo atr1_t, Tipo atr2_t);

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
                          "\n{\n" + gerarDeclaracaoVariaveisLocais($2.v) + "\n" + $6.c + "}\n\n" + $7.c; }
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

BLOCO : '{' S '}' {$$.c = $2.c;}
      ;

BLOCO_OPCIONAL : BLOCO   
                    { $$.c = $1.c; }
               | ATR ';'
                    { $$.c = $1.c; }
               | COMANDO 
                    { $$.c = $1.c; }
               | _TK_BREAK ';'
                    { $$.c = gerarCodigoBreak(); }
               ;

BLOCO_CASE : S ';'
               { $$.c = $1.c + gerarCodigoBreak(); }
	       | CASE
	       ;

S : VAR ';' S 
        { $$.c = $1.c + $3.c; }
  | VAR_ARRAY ';' S
        { $$.c = $1.c + $3.c; }
  | ATR ';' S 
        { $$.c = $1.c + $3.c; }
  | COMANDO S 
        { $$.c = $1.c + $2.c; }
  | _TK_BREAK ';'
         { $$.c = gerarCodigoBreak(); }
  | /* epsylon */
        { $$.c = ""; }
  ;

COMANDO : CMD_IF
            {$$ = $1;}
        | CMD_FOR
            {$$ = $1; $$.c += "\n";}
        | CMD_WHILE
            {$$ = $1; $$.c += "\n";}
        | CMD_DOWHILE
            {$$ = $1; $$.c += "\n";}
        | CMD_SWITCH
            {$$ = $1; $$.c += "\n";}
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

LOOP_WHILE : _TK_WHILE
               {pilhaFimLoop.push_back($1.fimLoop);}
           ;
LOOP_DOWHILE : _TK_DO
                 {pilhaFimLoop.push_back($1.fimLoop);}
             ;
            
LOOP_FOR : _TK_FOR
             {pilhaFimLoop.push_back($1.fimLoop);}
         ;

CMD_FOR : LOOP_FOR '(' ATR ';' EXP ';' ATR ')' BLOCO_OPCIONAL
        { gerarCodigoFor(&$$, $1.fimLoop, $3, $5, $7, $9); }
        ;

CMD_WHILE : LOOP_WHILE '(' EXP ')' BLOCO_OPCIONAL
            { gerarCodigoWhile(&$$, $1.fimLoop, $3, $5); }
          ;

CMD_DOWHILE : LOOP_DOWHILE BLOCO _TK_WHILE '(' EXP ')' ';'
            { gerarCodigoDoWhile(&$$, $1.fimLoop, $5, $2); }
            ;

CMD_SWITCH : _TK_SWITCH '(' _TK_ID ')' '{' LST_CASE '}'

           ;

CMD_ESCRITA : _IO_PRINT '(' EXP ')' ';'
                    { $$.c = $3.c + "    printf(\"%s\"," + $3.v + ");\n"; }
	        ;
			
CMD_LEITURA : _IO_SCAN '(' _TK_ID ')' ';'
	        ;

LST_CASE : CASE LST_CASE
         | _TK_DEFAULT ':' S ';'
         | /* epsylon */
                { $$.c = ""; }
         ;
         
CASE : _TK_CASE  _TK_ID    ':' BLOCO_CASE
        { $$.c = $2.c + $3.v + $4.c; }
     | _TK_CASE  _C_INT    ':' BLOCO_CASE
        { $$.c = $2.c + $3.v + $4.c; }
     | _TK_CASE  _C_CHAR   ':' BLOCO_CASE
        { $$.c = $2.c + $3.v + $4.c; }
     | _TK_CASE  _C_STRING ':' BLOCO_CASE
        { $$.c = $2.c + $3.v + $4.c; }
     ;

VAR_ARRAY : TIPO _TK_ID ARRAY
                 { gerarDeclaracaoVariavelArray(&$$, $1, $2, $3); }
          ;

ARRAY : ARRAY '[' _C_INT ']'
             { $$.c = ""; $$.t.tamanhos = $1.t.tamanhos; $$.t.tamanhos.push_back($3.v); }
      | '[' _C_INT ']'
             { $$.c = ""; $$.t.tamanhos.push_back($2.v); }
      ;
      
INDICE : INDICE ',' F
             { $$.c = ""; $$.t.tamanhos = $1.t.tamanhos; $$.t.tamanhos.push_back($3.v); }
       | F
             { $$.c = ""; $$.t.tamanhos.push_back($1.v); }
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
    | _TK_ID '[' INDICE ']' '=' EXP 
            { $$.c = $6.c + $3.c + "    " + $1.v + "[" + $3.v + "]" + $3.c + " = " + $6.v + ";\n"; }
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
    | F
        {$$ = $1;}
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
  | _TK_ID '[' INDICE ']'
                 { gerarCodigo_F_para_TK_ID_ARRAY(&$$, $1, $3); }
  ;

%%
int nlinha = 1;

map<string,int> n_var_temp;
map<string,Tipo> resultadoOperacao;
map<string,int> n_label;

#include "lex.yy.c"

int yyparse();

void erro( string msg ){
  yyerror( msg.c_str() );
  exit(0);
}

string toStr( int n ){
  char buf[1024] = "";
  
  sprintf( buf, "%d", n );
  
  return buf;
}

void yyerror( const char* st ){
  puts( st );
  printf( "Linha: %d\nPerto de: '%s'\n", nlinha, yytext );
}

Tipo tipoResultado( Tipo a, string operador, Tipo b )
{
  if( resultadoOperacao.find( a.nome + operador + b.nome ) == resultadoOperacao.end() )
    erro( "Operacao nao permitida: " + a.nome + operador + b.nome );

  return resultadoOperacao[a.nome + operador + b.nome];
}

void gerarCodigoIf(Atributo *SS, Atributo exp_if, Atributo bloco_if)
{
    string label_if_false = gerarLabel("if_false"); 
    string temp = gerarTemp(Tipo("boolean"));
    
    SS->c =  exp_if.c + "    " + temp + " = " + "!" + exp_if.v + ";\n    if ( " + temp + " ) goto "
             + label_if_false + ";\n" + bloco_if.c + label_if_false + ":\n";
}

void gerarCodigoIfElse(Atributo *SS, Atributo exp_if, Atributo bloco_if, Atributo bloco_else)
{
    string label_if_true        = gerarLabel("if_true");
    string label_fim_if_else    = gerarLabel("fim_if_else");
    
    SS->c =  exp_if.c + "    if ( " + exp_if.v + " ) goto " + label_if_true + ";\n" 
             + bloco_else.c + "    goto " + label_fim_if_else + ";\n" + label_if_true
             + ":\n" + bloco_if.c + label_fim_if_else + ":\n";
}

string gerarCodigoBreak() 
{
    string codigoBreak;
    codigoBreak = "    goto " + pilhaFimLoop.back() + ";\n";
    pilhaFimLoop.pop_back();
    
    return codigoBreak;
}

/**
    Criando o código do while
    solução baseada na construção do 'for'
**/
void gerarCodigoWhile(Atributo *SS, const string fim_while, const Atributo& condicao, const Atributo& bloco_while)
{
    string whileCond = gerarLabel("while_cond");
    string valorNotCond = gerarTemp(Tipo("boolean"));

    if( condicao.t.nome != "boolean" )
        erro( "A expressão de teste deve ser booleana: " + condicao.t.nome );

    SS->c = whileCond + ":\n" + condicao.c
            + "    " + valorNotCond + " = !" + condicao.v + ";\n" 
            + "    if ( " + valorNotCond + " ) goto " + fim_while +";\n"
            + bloco_while.c + "    goto " + whileCond + ";\n" + fim_while + ":\n";
}

/**
    Criando o codigo do 'do while'
    usei como base o while para a construção.
    apenas 'inverti' a variavel valorNotCond
**/
void gerarCodigoDoWhile(Atributo *SS, const string fim_dowhile, const Atributo& condicao, const Atributo& bloco_while)
{
    string whileCond = gerarLabel("while_cond");
    string valorNotCond = gerarTemp(Tipo("boolean"));

    if( condicao.t.nome != "boolean" )
        erro( "A expressão de teste deve ser booleana: " + condicao.t.nome );

    SS->c = whileCond + ":\n" + condicao.c 
            + "    " + valorNotCond + " = !" + condicao.v + ";\n"
            + bloco_while.c 
            + "    if ( !" + valorNotCond + " ) goto " + whileCond + ";\n"
            + fim_dowhile + ":\n";
}

/**
    Criando o código do 'for'
    solução baseada na apresentada em aula
**/
void gerarCodigoFor( Atributo* SS, const string fim_for, const Atributo& inicial, const Atributo& condicao, const Atributo& passo, const Atributo& cmds )
{
  string forCond = gerarLabel( "for_cond" );
  string valorNotCond = gerarTemp( Tipo( "boolean" ) );
         
  if( condicao.t.nome != "boolean" )
    erro( "A expressão de teste deve ser booleana: " + condicao.t.nome ); 
  
  // Funciona apenas para filtro, sem pipe que precisa de buffer 
  // (sort, por exemplo, não funciona)
  SS->c = inicial.c + forCond + ":\n" + condicao.c
          + "    " + valorNotCond + " = !" + condicao.v + ";\n"
          + "    if( " + valorNotCond + " ) goto " + fim_for + ";\n"
          + cmds.c + passo.c 
          + "    goto " + forCond + ";\n"
          + fim_for + ":\n";
}

/**
    Construção do código do switch
**/
void gerarCodigoSwitch(Atributo* SS, const Atributo& comparacao, const Atributo& bloco_switch)
{
    // CMD_SWITCH : _TK_SWITCH '(' _TK_ID ')' '{' LST_CASE '}'
    //        ;

    // LST_CASE : CASE LST_CASE
    //          | _TK_DEFAULT ':' S _TK_BREAK ';'
    //          | /* epsylon */
    //                 { $$.c = ""; }
    //          ;
    *SS = Atributo();
    SS->c = "";

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
        string max = toStr(MAX_STRING - 1);
    
        if (S1->t.nome == "string")
        {
            SS->c = S1->c + S3.c 
                    + "    strncpy(" + S1->v + ", " + S3.v + ", " + max + ");\n"
                    + "    " + S1->v + "[" + max + "]" + " = 0;\n";
                    
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

void gerarCodigo_EXP(Atributo *atr, Atributo atr1 , Atributo operador, Atributo atr2)
{
    atr->t = tipoResultado( atr1.t, operador.v, atr2.t );
    
    if (atr->t.nome == "string") 
    {
        string atr1Value;
        string atr2Value;
        
        string cod_aux;
        
        /* Caso um dia eu queira otimizar é só tornar o char[256] em char * x ; x = malloc(256)
         * e adicionar este cod_free ao fim dessa geração.
         */
        string cod_free;
       
        atr1Value = atr1.v;
        atr2Value = atr2.v;
        
        gerarCodAux_Int_String(&atr2Value, &atr1Value, &cod_aux, &cod_free, atr2.t, atr1.t);
        gerarCodAux_Int_String(&atr1Value, &atr2Value, &cod_aux, &cod_free, atr1.t, atr2.t);
        
        string temp = gerarTemp(atr->t);
        atr->v = gerarTemp(atr->t);      
        
        atr->c = atr1.c + atr2.c + cod_aux
                                 + "    strncpy(" + temp + ", " + atr1Value + ", " + toStr(MAX_STRING - 1) + ");\n"
                                 + "    " + temp + "[" + toStr(MAX_STRING - 1) + "] = 0;\n"
                                 + "    strncat( " + temp + ", " + atr2Value + ", " + toStr(MAX_STRING - 1)
                                 + " - " + "strlen(" + atr1Value + ")" + " );\n"
                                 + "    strncpy(" + atr->v + ", " + temp + ", " + toStr(MAX_STRING - 1) + ");\n" 
                                 + "    " + atr->v + "[" + toStr(MAX_STRING - 1) + "] = 0;\n"
                                 ;
        return;
    }
    
    atr->v = gerarTemp(atr->t);
    atr->c = atr1.c + atr2.c + "    " + atr->v + " = " + atr1.v + " " + operador.v + " " + atr2.v + ";\n";
}

void gerarCodigo_EXP_UNARIA(Atributo *atr, Atributo atr1 , Atributo atr2)
{
    atr->t = tipoResultado( Tipo(""), atr1.v, atr2.t );
    atr->v = gerarTemp(atr->t); 
    atr->c = atr2.c + "    " + atr->v + " = " + atr1.v + atr2.v + ";\n";
}

void gerarCodAux_Int_String(string *atr1Value, string *atr2Value, string *cod_aux, string *cod_free, Tipo atr1_t, Tipo atr2_t)
{  
    if ( atr1_t.nome == "int" && atr2_t.nome == "string" )
    {
        string temp_atr1;
        string temp_atr2;
        
        temp_atr1 = gerarTemp(Tipo("string"));
        *cod_aux = "    sprintf(" + temp_atr1 + ",\"%d\", " + *atr1Value + ");\n";
        *atr1Value = temp_atr1;
        *cod_free = "    free(" + temp_atr1 + ");\n";
    }
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
  if( ts.find( nomeVar ) != ts.end() ){
    return true;
  }
  else
    return false;
}

void gerarDeclaracaoVariavel(Atributo* SS, const Atributo& tipo, const Atributo& id )
{
    SS->c = "";

    if (verificarSeVariavelFoiDeclarada(id.v))
    {
        erro( "Redeclaração da variavel: " + id.v );
    }

    inserirVariavelTS(id.v, tipo.t );
}

void gerarDeclaracaoVariavelArray(Atributo* SS, const Atributo& tipo, const Atributo& id, const Atributo& array)
{
    SS->c = "";
    Tipo tipoArray;
    
    if (verificarSeVariavelFoiDeclarada(id.v))
    {
        erro( "Redeclaração da variavel do tipo array: " + id.v );
    }
    
    tipoArray.nome = tipo.t.nome;
    tipoArray.tamanhos = array.t.tamanhos;
    
    inserirVariavelTS(id.v, tipoArray);
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

void gerarCodigo_F_para_TK_ID(Atributo *atr, const Atributo& id)
{
    if (buscarVariavelTS(tsGlobais, id.v))
    {
        atr->v = id.v;
        atr->t = tsGlobais[atr->v];
        return;
    }

    if( buscarVariavelTS(fs[scope], id.v) )
    {
        atr->v = id.v;
        atr->t = fs[scope][atr->v];
        return;
    }
    erro( "Variavel nao declarada: " + id.v );
}

void gerarCodigo_F_para_TK_ID_ARRAY(Atributo *atr, const Atributo& id, const Atributo& index)
{
    atr->c = index.c;
    
    if (index.t.nome != "int") 
    {
        erro("Passando índice não inteiro: " + index.v);
    }

    if (buscarVariavelTS(tsGlobais, id.v))
    {
        atr->t = tsGlobais[atr->v];
        
        int aux = calcularIndice(index.t.tamanhos, atr->t.tamanhos);
        
        atr->v = " " + id.v + "[" + toStr(aux) + "]";
        return;
    }

    if(buscarVariavelTS(fs[scope], id.v))
    {
        atr->t = fs[scope][atr->v];
        
        int aux = calcularIndice(index.t.tamanhos, atr->t.tamanhos);
        
        atr->v = " " + id.v + "[" + toStr(aux) + "]";
        return;
    }
    erro( "Variavel nao declarada: " + id.v );
}

int calcularIndice(vector<string> valorDimensoes, vector<string> dimensoes)
{
    int valorFinal = 0;
    const int numeroDimensao = valorDimensoes.size();

    if (numeroDimensao == 2)
    {
        const char *aux1 = (dimensoes.at(0)).c_str();
        const char *aux2 = (valorDimensoes.at(0)).c_str();
        const char *aux3 = (valorDimensoes.at(1)).c_str();
        
        return atoi(aux1) * atoi(aux2) + atoi(aux3);
    }
    
    const char *aux = (valorDimensoes.at(0)).c_str();
    return atoi(aux);
}

string gerarDeclaracaoVariaveisGlobais()
{
    string c = "";
    
    for (std::map<string, Tipo>::iterator it=tsGlobais.begin(); it!=tsGlobais.end(); ++it)
    {
        if (it->second.nome != "string")
        {
            c = c + it->second.nome + " " + it->first + ";\n";
        }
        else
        {
            c = c + "char " + it->first + "["+ toStr( MAX_STRING ) +"];\n"; ;
        }
    }
    
    return c;
}

string gerarDeclaracaoVariaveisLocais(string escopoFuncao)
{
    TS ts = fs[escopoFuncao];
    
    string c = "";
    
    for (std::map<string, Tipo>::iterator it=ts.begin(); it!=ts.end(); ++it)
    {
        if (!it->second.tamanhos.empty())
        {
            int contadorDimensao = 1;
            const int numeroDimensao = it->second.tamanhos.size();
        
            for (int i=0; i < numeroDimensao ; i++)
            {
                const char *aux = (it->second.tamanhos.at(i)).c_str();
                contadorDimensao *= atoi(aux);
            }
        
            c = c + "    " + it->second.nome + " " + it->first + "[" + toStr(contadorDimensao) + "]" + ";\n";
            continue;
        }
        
        if (it->second.nome == "string")
        {
            c = c + "    char " + it->first + "["+ toStr( MAX_STRING ) +"];\n"; ;
            continue;        
        }
        
        c = c + "    " + it->second.nome + " " + it->first + ";\n";
    }
    
    return c;
}

string gerarDeclaracaoVariaveisTemporarias()
{
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
