/* Count and prints the number of lines. */
%option noyywrap
%{
    #include "rtsl.yy.h"

  int num_lines = 1;
%}

/* search for comments at the very beginning, to ignore them right away */
COMMENT \/\/.*|\/\*(.|\n|\r)*?\*\/

BOOL true|false

INT (0x|0X)[1-9A-Fa-f]+|[0-9]+

/* extract copied part */
FLOAT ((([0-9]*\.[0-9]+|[0-9]+\.[0-9]*|[0-9]+)[eE]-?[0-9]+)|([0-9]*\.[0-9]+|[0-9]+\.[0-9]*))(lf|f)?

TYPE (int|float|bool|color|void|vec2|vec3|vec4|ivec2|ivec3|ivec4|bvec2|bvec3|bvec4|rt_Primitive|rt_Camera|rt_Material|rt_Texture|rt_Light)

QUALIFIER (attribute|uniform|varying|const|public|private|scratch)

STATE rt_[_a-zA-Z0-9]+

KEYWORD (break|case|const|continue|default|do|double|enum|extern|goto|sizeof|static|struct|switch|typedef|union|unsigned|illuminance|ambient|dominantAxis|dot|hit|inside|inverse|luminance|max|min|normalize|perpendicularTo|pow|rand|reflect|sqrt|trace)

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

"++"    {return INC;}
"--"    {return DEC;}
"+="	{return INCASSIGN;}
"-="	{return DECASSIGN;}
"+"     {return PLUS;}
"*"		{return MUL;}
"-"		{return MINUS;}
"/"		{return DIV;}
"="		{return ASSIGN;}
"=="	{return EQUAL;}
"!="	{return NOT_EQUAL;}
"<"		{return LT;}
"<="	{return LE;}
">"		{return GT;}
">="	{return GE;}
","		{return COMMA;}
":"		{return COLON;}
";"		{return SEMICOLON;}
"("		{return LPARENTHESIS;}
")"		{return RPARENTHESIS;}
"["		{printf("LBRACKET\n");}
"]"		{printf("RBRACKET\n");}
"{"		{return LBRACE;}
"}"		{return RBRACE;}
"&&"	{printf("AND\n");}
"||"	{printf("OR\n");}


"class"   {return CLASS;}
"return"  {return RETURN;}

"if"      {return IF;}
"else"    {return ELSE;}

"while"   {return WHILE;}
"for"     {return FOR;}

{BOOL}          {yylval.string = (char*) strdup(yytext); return BOOL;}
{INT}           {yylval.string = (char*) strdup(yytext); return INT;}
{FLOAT}         {yylval.string = (char*) strdup(yytext); return FLOAT;}
{TYPE}          {yylval.string = (char*) strdup(yytext+3); return TYPE;}
{QUALIFIER}     {yylval.string = (char*) strdup(yytext+3); return QUALIFIER;}
{STATE}         {yylval.string = (char*) strdup(yytext); return STATE;}
{KEYWORD}       {return KEYWORD;}
{SWIZZLE}       {yylval.string = (char*) strdup(yytext); return SWIZZLE;}
{IDENTIFIER}    {return IDENTIFIER;}


{BLANK}  /* do nothing on match. Just remove blanks */
\n      {++num_lines;} /* We use newline characters to count lines. */

{CATCHALL}      {printf("ERROR(%i): Unrecognized symbol \"%s\"\n", num_lines, yytext);} /* Lastly collect all previously unrecognized tokens and print an error message */

%%

// int main()
// {
//   yylex();
//   return 0;
// }
