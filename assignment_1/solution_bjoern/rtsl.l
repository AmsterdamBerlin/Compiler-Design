/* Count and prints the number of lines. */
%option noyywrap
%{
  int num_lines = 1;
%}

/* search for comments at the very beginning, to ignore them right away */
COMMENT \/\/.*|\/\*(.|\n|\r)*?\*\/

BOOL true|false

INT (0x|0X)[1-9A-Fa-f]+|[0-9]+

/* extract copied part */
FLOAT ((([0-9]*\.[0-9]+|[0-9]+\.[0-9]*|[0-9]+)[eE]-?[0-9]+)|([0-9]*\.[0-9]+|[0-9]+\.[0-9]*))(lf|f)?

TYPE (int|float|bool|void|vec2|vec3|vec4|ivec2|ivec3|ivec4|bvec2|bvec3|bvec4|rt_Primitive|rt_Camera|rt_Material|rt_Texture|rt_Light)

QUALIFIER (attribute|uniform|varying|const|public|private|scratch)

STATE rt_[_a-zA-Z0-9]+

KEYWORD (class|break|case|const|continue|default|do|double|else|enum|extern|for|goto|if|sizeof|static|struct|switch|typedef|union|unsigned|while|illuminance|ambient|dominantAxis|dot|hit|inside|inverse|luminance|max|min|normalize|perpendicularTo|pow|rand|reflect|sqrt|trace)

SWIZZLE \.([_a-zA-Z][_a-zA-Z0-9]*)

IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*

BLANK [ \t]

CATCHALL .


%%

{COMMENT}  { /* Only count linkebreaks on match otherwise ignore. */
    int i;
    for (i=0; yytext[i]; i++) {
        if (yytext[i] == '\n') {
            num_lines++;
        }
    }
}

"+"     {printf("PLUS\n");}
"*"		{printf("MUL\n");}
"-"		{printf("MINUS\n");}
"/"		{printf("DIV\n");}
"="		{printf("ASSIGN\n");}
"=="	{printf("EQUAL\n");}
"!="	{printf("NOT_EQUAL\n");}
"<"		{printf("LT\n");}
"<="	{printf("LE\n");}
">"		{printf("GT\n");}
">="	{printf("GE\n");}
","		{printf("COMMA\n");}
":"		{printf("COLON\n");}
";"		{printf("SEMICOLON\n");}
"("		{printf("LPARENTHESIS\n");}
")"		{printf("RPARENTHESIS\n");}
"["		{printf("LBRACKET\n");}
"]"		{printf("RBRACKET\n");}
"{"		{printf("LBRACE\n");}
"}"		{printf("RBRACE\n");}
"&&"	{printf("AND\n");}
"||"	{printf("OR\n");}
"++"    {printf("INC\n");}
"--"    {printf("DEC\n");}

{BOOL}          {printf("BOOL %s\n", yytext);}
{INT}           {printf("INT %s\n", yytext);}
{FLOAT}         {printf("FLOAT %s\n", yytext);}
{TYPE}          {printf("TYPE %s\n", yytext);}
{QUALIFIER}     {printf("QUALIFIER %s\n", yytext);}
{STATE}         {printf("STATE %s\n", yytext);}
{KEYWORD}       {printf("KEYWORD %s\n", yytext);}
{SWIZZLE}       {printf("SWIZZLE %s\n", yytext+1);}
{IDENTIFIER}    {printf("IDENTIFIER %s\n", yytext);}


{BLANK}  /* do nothing on match. Just remove blanks */
\n      {++num_lines;} /* We use newline characters to count lines. */

{CATCHALL}      {printf("ERROR(%i): Unrecognized symbol \"%s\"\n", num_lines, yytext);} /* Lastly collect all previously unrecognized tokens and print an error message */

%%

int main()
{
  yylex();
  return 0;
}
