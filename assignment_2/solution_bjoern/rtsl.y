/* Example 2, Simple Calculator Parser */
%{
#include <stdio.h>

// #define YYSTYPE char*



extern int yylex(); // Declared by lexer

extern FILE *yyin;

// Declared later in file
void yyerror(const char *s);
void stringToLower(char *s);
%}

%union {
    char* string;

}

/* declare tokens */
%token KEYWORD

%token CLASS
%token RETURN
%token IF ELSE
%token WHILE FOR

%token QUALIFIER
%token TYPE
%token IDENTIFIER
%token STATE
%token SWIZZLE

%token COMMA COLON SEMICOLON
%token LPARENTHESIS RPARENTHESIS
%token LBRACE RBRACE

%token BOOL INT FLOAT

%token EQUAL NOT_EQUAL LT LE GT GE

%token ASSIGN
%token INCASSIGN DECASSIGN
%token INC DEC

%token PLUS MINUS MUL DIV


%type <string> TYPE BOOL INT FLOAT QUALIFIER STATE KEYWORD IDENTIFIER

%start rtsl

%%

rtsl:
    /* nothing */
    | shaderdef rtsl
    | functiondef rtsl
    | declaration rtsl
    ;

shaderdef:
    CLASS identifier COLON TYPE SEMICOLON {stringToLower($4); printf("SHADER_DEF %s\n", $4);}
    ;

functiondef:
    TYPE identifier LPARENTHESIS parameterlist RPARENTHESIS LBRACE functionbody RBRACE {printf("FUNCTION_DEF\n");}
    ;

parameterlist:
    /* nothing */
    | TYPE identifier
    | TYPE identifier COMMA parameterlist /* TODO this wrongly allows something like "int i," */
    ;

functionbody:
    /* nothing */
    | declaration functionbody
    | statement functionbody
    ;

declaration:
    TYPE identifier SEMICOLON {printf("DECLARATION\n");}
    | TYPE assignment SEMICOLON {printf("DECLARATION\n");}
    | QUALIFIER TYPE identifier SEMICOLON {printf("DECLARATION\n");}
    ;

conditional: /*KEYWORDs should be IF and ELSE*/
    if else {printf("IF - ELSE\n");}
    | if  {printf("IF\n");}/* no else expression */
    ;

if:
    IF LPARENTHESIS expression RPARENTHESIS statement
    ;

else:
    ELSE statement
    ;

loop:
    while
    | for
    ;

while:
    WHILE LPARENTHESIS expression RPARENTHESIS statement
    ;

for:
    FOR LPARENTHESIS assignment SEMICOLON expression SEMICOLON assignment RPARENTHESIS statement
    ;

statementlist:
    /* nothing */
    | statement statementlist
    ;

statement:
    /* nothing */
    | expression SEMICOLON {printf("STATEMENT\n");}
    | conditional {printf("STATEMENT\n");}
    | loop {printf("STATEMENT\n");}
    | LBRACE statementlist RBRACE {printf("STATEMENT\n");}
    | RETURN expression SEMICOLON {printf("STATEMENT\n");}
    | assignment SEMICOLON {printf("STATEMENT\n");}
    | functioncall SEMICOLON {printf("STATEMENT\n");}
    ;

expression:
    value
    | expression compareoperator expression
    | expression binaryoperator expression
    | expression backunaryoperator
    | frontunaryoperator expression
    | LPARENTHESIS expression RPARENTHESIS
    ;

assignment:
    assignable assignoperator assignmentsource
    | assignable backunaryoperator
    | frontunaryoperator assignable
    ;

frontunaryoperator:
    INC
    | DEC
    | MINUS
    ;

backunaryoperator:
    INC
    | DEC
    ;

binaryoperator:
    PLUS
    | MUL
    | MINUS
    | DIV
    ;

assignable:
    identifier
    ;

assignoperator:
    ASSIGN
    | INCASSIGN
    | DECASSIGN
    ;

assignmentsource:
    | expression
    ;

value:
    BOOL
    | INT
    | FLOAT
    | identifier /* not sure if an identifier is the correct solution here */
    | functioncall
    ;

functioncall:
    identifier LPARENTHESIS functioncallparameterlist RPARENTHESIS
    ;

functioncallparameterlist:
    /* nothing */
    | expression
    | expression COMMA functioncallparameterlist /* TODO this wrongly allows something like "i," */

    ;

compareoperator:
    EQUAL
    | NOT_EQUAL
    | LT
    | LE
    | GT
    | GE
    ;

identifier:
    identifierbase
    | identifierbase SWIZZLE
    ;

identifierbase:
    IDENTIFIER
    | KEYWORD // in the right context keywords may also be identifiers
    | TYPE // in the right context types may also be identifiers
    | STATE
    ;

%%
int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yyparse();
}

void yyerror(const char *s)
{
    fprintf(stderr, "error: %s\n", s);
}

void stringToLower(char *s)
{
    int i;
    for(i = 0; s[i]; i++){
        s[i] = tolower(s[i]);
    }
}
