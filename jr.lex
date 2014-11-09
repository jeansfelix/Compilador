DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]

BOOL    ("true"|"false")
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)

IF      "if"
ID      {LETRA}({LETRA}|{NUMERO})*

%%

{LINHA}    { nlinha++; }
{DELIM}    {}

{IF}       { yylval = Atributo( yytext ); return _IF; }
{BOOL}     { std::string s = "true"; yylval = Atributo( !s.compare(yytext)? "1" : "0" ); return _BOOL; }
{ID}       { yylval = Atributo( yytext ); return _ID; }
{INT}      { yylval = Atributo( yytext ); return _INT; }
{DOUBLE}   { yylval = Atributo( yytext ); return _DOUBLE; }

.          { yylval = Atributo( yytext ); return *yytext; }

%%

 


