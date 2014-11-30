DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]

BOOL    ("true"|"false")
NOT     ("!"|"not")
DIF     ("!="|"not equal")
IGUAL   ("=="|"equal")
OR      ("or"|"||")
AND     ("and"|"&&")
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)
STRING  (\"([^"]|\\\")*\")

ID      {LETRA}({LETRA}|{NUMERO})*

%%

{LINHA}    { nlinha++; }
{DELIM}    {}

%{ /* Comandos */ %}
    "if"       { yylval = Atributo( yytext ); return _TK_IF; }
    "else"     { yylval = Atributo( yytext ); return _TK_ELSE; }
    "for"      { yylval = Atributo( yytext ); return _TK_FOR; }
    "do"       { yylval = Atributo( yytext ); return _TK_DO; }
    "while"    { yylval = Atributo( yytext ); return _TK_WHILE; }
    "switch"   { yylval = Atributo( yytext ); return _TK_SWITCH; }
    "case"     { yylval = Atributo( yytext ); return _TK_CASE; }
    "break"    { yylval = Atributo( yytext ); return _TK_BREAK; }
    "default"  { yylval = Atributo( yytext ); return _TK_DEFAULT; }
    "return"   { yylval = Atributo( yytext ); return _TK_RETURN; }
    
%{ /* Tipos */ %}
    "int"       {  yylval = Atributo( "", yytext ); return _TK_INT; }
    "char"      {  yylval = Atributo( "", yytext ); return _TK_CHAR; }
    "boolean"   {  yylval = Atributo( "", yytext ); return _TK_BOOL; }
    "double"    {  yylval = Atributo( "", yytext ); return _TK_DOUBLE; }
    "float"     {  yylval = Atributo( "", yytext ); return _TK_FLOAT; }
    "string"    {  yylval = Atributo( "", yytext ); return _TK_STRING; }
    "void"      {  yylval = Atributo( "", yytext ); return _TK_VOID; }

%{ /* Operadores */ %}
    {NOT}       {  yylval = Atributo( "!" ); return _OP_NOT; }
    {DIF}       {  yylval = Atributo( "!=" ); return _OP_DIF; }
    {IGUAL}     {  yylval = Atributo( "==" ); return _OP_EQUAL; }
    {OR}        {  yylval = Atributo( "||" ); return _OP_OR; }
    {AND}       {  yylval = Atributo( "&&" ); return _OP_AND; }
    "<="        {  yylval = Atributo( yytext ); return _OP_LESS_OR_EQUAL; }
    ">="        {  yylval = Atributo( yytext ); return _OP_GREATER_OR_EQUAL; }
    "++"        {  yylval = Atributo( yytext ); return _OP_INC; }
    "--"        {  yylval = Atributo( yytext ); return _OP_DEC; }

%{ /* Constantes */ %}
    {BOOL}     { std::string s = "true"; yylval = Atributo( !s.compare(yytext)? "1" : "0", "boolean"); return _C_BOOL; }
    {INT}      { yylval = Atributo( yytext, "int" ); return _C_INT; }
    {DOUBLE}   { yylval = Atributo( yytext, "double" ); return _C_DOUBLE; }
    {STRING}   { yylval = Atributo( yytext, "string" ); return _C_STRING; }

%{ /* IO */ %}
    "print" {yylval = Atributo( yytext ); return _IO_PRINT;}
    "scan"  {yylval = Atributo( yytext ); return _IO_SCAN;}

%{ /* Identificadores */ %}
    {ID}       { yylval = Atributo( yytext ); return _TK_ID; }

%{ /* Caracteres simples */ %}
    .          { yylval = Atributo( yytext ); return *yytext; }

%%


