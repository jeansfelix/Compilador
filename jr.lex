DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]

BOOL    ("true"|"false")
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)

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
    
%{ /* Tipos */ %}
    "int"       {  yylval = Atributo( "", yytext ); return _TK_INT; }
    "char"      {  yylval = Atributo( "", yytext ); return _TK_CHAR; }
    "boolean"   {  yylval = Atributo( "", yytext ); return _TK_BOOL; }
    "double"    {  yylval = Atributo( "", yytext ); return _TK_DOUBLE; }
    "float"     {  yylval = Atributo( "", yytext ); return _TK_FLOAT; }
    "string"    {  yylval = Atributo( "", yytext ); return _TK_STRING; }

%{ /* Constantes */ %}
    {BOOL}     { std::string s = "true"; yylval = Atributo( !s.compare(yytext)? "1" : "0" ); return _C_BOOL; }
    {INT}      { yylval = Atributo( yytext ); return _C_INT; }
    {DOUBLE}   { yylval = Atributo( yytext ); return _C_DOUBLE; }

%{ /* Identificadores */ %}
    {ID}       { yylval = Atributo( yytext ); return _TK_ID; }

%{ /* Caracteres simples */ %}
    .          { yylval = Atributo( yytext ); return *yytext; }

%%


