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

"if"       { yylval = Atributo( yytext ); return _TK_IF; }
"for"      { yylval = Atributo( yytext ); return _TK_FOR; }
"do"       { yylval = Atributo( yytext ); return _TK_DO; }
"while"    { yylval = Atributo( yytext ); return _TK_WHILE; }

{BOOL}     { std::string s = "true"; yylval = Atributo( !s.compare(yytext)? "1" : "0" ); return _C_BOOL; }

{ID}       { yylval = Atributo( yytext ); return _TK_ID; }
{INT}      { yylval = Atributo( yytext ); return _C_INT; }
{DOUBLE}   { yylval = Atributo( yytext ); return _C_DOUBLE; }

.          { yylval = Atributo( yytext ); return *yytext; }

%%


