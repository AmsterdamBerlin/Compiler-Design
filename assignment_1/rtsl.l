/**
  Compiler Design Course - TU Berlin
  Winter Term 2016/17

  Assignment 1
  Oliver Esser
**/

DG        [0-9]
HX        [A-Fa-f0-9]
EX        [eE][+-]?{DG}+
US        [uU]
FS        [fF]|([lL][fF])

ID_START  [a-zA-Z_]
ID_CHAR   {ID_START}|[0-9]
ID        {ID_START}{ID_CHAR}*

WS        [ \t\r\v]

DTYPE     "int"|"float"|"bool"|"void"
VTYPE     [ib]?"vec"[2-4]
BTYPE     "rt_"("Primitive"|"Camera"|"Material"|"Texture"|"Light")
TYPE      {DTYPE}|{VTYPE}|{BTYPE}

QUALIFIER "attribute"|"uniform"|"varying"|"const"|"public"|"private"|"scratch"

STVAR     "rt_"{ID_CHAR}+

CKEYWORD  "break"|"class"|"case"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"for"|"goto"|"if"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"while"
RKEYWORD  "illuminance"|"ambient"
BFUNC     "dominantAxis"|"dot"|"hit"|"inside"|"inverse"|"luminance"|"max"|"min"|"normalize"|"perpendicularTo"|"pow"|"rand"|"refrlect"|"sqrt"|"trace"
KEYWORD   {CKEYWORD}|{RKEYWORD}|{BFUNC}

%{
#include <stdio.h>

int g_line_number = 1;

void emit_swizzle();
void emit_error();

/* #define EMIT_VAL(token) fprintf(yyout, "%3d " #token " %s\n", g_line_number, yytext) */
/* #define EMIT_OP(token) fprintf(yyout, "%3d " #token "\n", g_line_number) */
/* #define EMIT_SWIZZLE fprintf(yyout, "%3d SWIZZLE %s\n", g_line_number, &yytext[1]) */
#define EMIT_VAL(token) fprintf(yyout, #token " %s\n", yytext)
#define EMIT_OP(token) fprintf(yyout, #token "\n")
#define EMIT_SWIZZLE fprintf(yyout, "SWIZZLE %s\n", &yytext[1])

%}

%x ML_COMMENT

%%
(true|false)                            { EMIT_VAL(BOOL); }

0[xX]{HX}+{US}?                          { EMIT_VAL(INT); }
0{DG}+{US}?                              { EMIT_VAL(INT); }
{DG}+{US}?                               { EMIT_VAL(INT); }

{DG}+{EX}{FS}?                          { EMIT_VAL(FLOAT); }
{DG}*"."{DG}+{EX}?{FS}?                 { EMIT_VAL(FLOAT); }
{DG}+"."{DG}*{EX}?{FS}?                 { EMIT_VAL(FLOAT); }

{TYPE}                                  { EMIT_VAL(TYPE); }
{QUALIFIER}                             { EMIT_VAL(QUALIFIER); }
{STVAR}                                 { EMIT_VAL(STATE); }
{KEYWORD}                               { EMIT_VAL(KEYWORD); }
{ID}                                    { EMIT_VAL(IDENTIFIER); }

"."{ID}                                 { EMIT_SWIZZLE; }

"=="                                    { EMIT_OP(EQUAL); }
"!="                                    { EMIT_OP(NOT_EQUAL); }
"<="                                    { EMIT_OP(LE); }
">="                                    { EMIT_OP(GE); }
"&&"                                    { EMIT_OP(AND); }
"||"                                    { EMIT_OP(OR); }
"++"                                    { EMIT_OP(INC); }
"--"                                    { EMIT_OP(DEC); }

"+"                                     { EMIT_OP(PLUS); }
"*"                                     { EMIT_OP(MUL); }
"-"                                     { EMIT_OP(MINUS); }
"/"                                     { EMIT_OP(DIV); }
"="                                     { EMIT_OP(ASSIGN); }
"<"                                     { EMIT_OP(LT); }
">"                                     { EMIT_OP(GT); }
","                                     { EMIT_OP(COMMA); }
":"                                     { EMIT_OP(COLON); }
";"                                     { EMIT_OP(SEMICOLON); }
"("                                     { EMIT_OP(LPARENTHESIS); }
")"                                     { EMIT_OP(RPARENTHESIS); }
"{"                                     { EMIT_OP(LBRACE); }
"}"                                     { EMIT_OP(RBRACE); }
"["                                     { EMIT_OP(LBRACKET); }
"]"                                     { EMIT_OP(RBRACKET); }

"//".*\n                                { ++g_line_number; } 
"/*"                                    { BEGIN(ML_COMMENT); }
<ML_COMMENT>\n                          { ++g_line_number; }
<ML_COMMENT>[^*\n]*                     { ; }
<ML_COMMENT>"*"\n                       { ++g_line_number; }
<ML_COMMENT>"*"[^/]                     { ; }
<ML_COMMENT>"*/"                        { BEGIN(INITIAL); }

\n                                      { ++g_line_number; }
{WS}                                    { ; }
.                                       { emit_error(); }
%%

int yywrap() { return 1; }
void emit_error() {
  fprintf(stderr, "ERROR(%d): Unrecognized symbol \"%s\"\n", 
          g_line_number, yytext);
}

void usage(char *exe) {
  printf("Usage: %s [OPTIONS] [FILENAME]\n", exe);
  printf("Lexically analyze RTLS shader in FILENAME or from standard input.\n\n");
  printf("  -o,--output <file>    write output to <file> instead of stdout \n"
         "  -h,--help             display this help and exit\n\n"
         "If FILENAME is omitted read the shader source from standard input.\n");
  exit(0);
}

void error(char *exe, const char *msg) {
  fprintf(stderr, "%s: %s\n", exe, msg);
  fprintf(stderr, "Try %s -h for more information\n", exe);
  exit(-1);
}

void process_cli_args(int argc, char *argv[]) {
  char *pname = argv[0];
  char *infile = NULL;
  char *outfile = NULL;
  for (int i = 1; i < argc; ++i) {
    if (argv[i][0] != '-') {
      if (infile) {
        error(pname, "Too many arguments");
      }
      infile = argv[i];
      continue;
    }
    if (strcmp("-h", argv[i]) == 0 || strcmp("--help", argv[i]) == 0) {
      usage(pname);
    }
    if (strcmp("-o", argv[i]) == 0 || strcmp("--output", argv[i]) == 0) {
      if (i+1 == argc) {
        error(pname, "Missing output filename");
      }
      outfile = argv[++i];
      continue;
    }
    error(pname, "Invalid option");
  }

  if (infile) {
    yyin = fopen(infile, "r");
    if (!yyin) {
      error(pname, "Cannot open input file");
    }
  }
  if (outfile) {
    yyout = fopen(outfile, "w");
    if (!yyout) {
      error(pname, "Cannot open output file");
    }
  }
}

int main(int argc, char *argv[]) {
  process_cli_args(argc, argv);

  return yylex();
}

