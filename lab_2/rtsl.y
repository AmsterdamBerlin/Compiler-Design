%{
#include <stdio.h>
#include <stdbool.h>
extern int yylex(); // Declared by lexer
void yyerror(const char *s); // Declared later in file

typedef enum {
  primitive,
  camera,
  material,
  texture,
  light,
} ShaderClass;

const char* SHADERCLASS[] = {"primitive", "camera", "material", "texture", "light"};

typedef enum {
  constructor,
  generateray,
  intersect,
  computebounds,
  computenormal,
  computetexturecoordinates,
  computederivatives,
  generatesample,
  samplepdf,
  lookup,
  shade,
  bsdf,
  samplebsdf,
  evaluatepdf,
  emission,
  illumination,
} Interface;

typedef enum {
   rayorigin,
   raydirection,
   inverseraydirection,
   epsilon,
   hitdistance,
   screencoord,
   lenscoord,
   du,
   dv,
   timeseed,
   boundmin,
   boundmax,
   geometricnormal,
   dpdu,
   dpdv,
   shadingnormal,
   textureuv,
   textureuvw,
   dsdu,
   dsdv,
   pdf,
   texturecolor,
   floattexturevalue,
   dtdu,
   dtdv,
   hitpoint,
   lightdirection,
   lightdistance,
   lightcolor,
   emissioncolor,
   bsdfseed,
   samplecolor,
   bsdfvalue,
} StateVariable;

ShaderClass shader_class;
Interface interface;
StateVariable state_variable;

void ShaderInterfaceCheck(ShaderClass shader_class, Interface interface);
void ShaderStatecheck(ShaderClass shader_class, StateVariable state_variable);
%}

%define parse.error verbose
%define parse.lac full
/* declare tokens */
%token  IDENTIFIER  INT_CONSTANT FLOAT_CONSTANT BOOL_CONSTANT
%token  TYPE QUALIFIER
%token  EQ_OP NE_OP LE_OP GE_OP AND_OP OR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP
%token  ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN XOR_ASSIGN
%token  VOID INT FLOAT BOOL VEC2 VEC3 VEC4 IVEC2 IVEC3 IVEC4 BVEC2 BVEC3 COLOR HIT
%token  ATTRIBUTE UNIFORM VARYING PUBLIC PRIVATE SCRATCH
%token  CAMERA PRIMITIVE TEXTURE MATERIAL LIGHT
%token  CLASS BREAK CASE CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FOR GOTO IF SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED WHILE RETURN

%token  RAYORIGIN RAYDIRECTION INVERSERAYDIRECTION EPSILON HITDISTANCE SCREENCOORD LENSCOORD DU DV TIMESEED
%token  BOUNDMIN BOUNDMAX GEOMETRICNORMAL DPDU DPDV SHADINGNORMAL TEXTUREUV TEXTUREUVW DSDU DSDV PDF
%token  TEXTURECOLOR FLOATTEXTUREVALUE DTDU DTDV
%token  HITPOINT LIGHTDIRECTION LIGHTDISTANCE LIGHTCOLOR EMISSIONCOLOR BSDFSEED SAMPLECOLOR BSDFVALUE

%token CONSTRUCTOR GENERATERAY INTERSECT COMPUTEBOUNDS COMPUTENORMAL COMPUTETEXTURECOORDINATES COMPUTEDERIVATIVES GENERATESAMPLE SAMPLEPDF LOOKUP SHADE BSDF SAMPLEBSDF EVALUATEPDF EMISSION ILLUMINATION


%start root_node
%%
/*************************** rule ***************/
root_node
    : external_declaration
	  | root_node external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    | shader_definition
    ;

function_definition
    : declaration_specifier declarator compound_statement { printf("FUNCTION_DEF\n"); }    /* e.g. void constructor {...}*/
    ;

declaration
    : declaration_specifier init_declarator_list ';' { printf("DECLARATION\n");}     /*int f;  or int f = 1 */
    ;


shader_definition
    : CLASS IDENTIFIER ':' shader_classifier  ';'
    ;

shader_classifier
    : MATERIAL     {printf("SHADER_DEF material\n"); shader_class = material;}
    | TEXTURE      {printf("SHADER_DEF texture\n"); shader_class = texture;}
    | PRIMITIVE    {printf("SHADER_DEF primitive\n"); shader_class = primitive;}
    | CAMERA       {printf("SHADER_DEF camera\n"); shader_class = camera;}
    | LIGHT        {printf("SHADER_DEF light\n"); shader_class = light;}
    ;


parameter_declaration
    : declaration_specifier declarator   /* int i, float j*/
    | declaration_specifier
    ;


declaration_specifier      /* STATIC int */
    : storage_class_specifier declaration_specifier
    | storage_class_specifier
    | type_specifier declaration_specifier
    | type_specifier
    | type_qualifier declaration_specifier
    | type_qualifier
    ;

init_declarator_list       /* berlin = cool, amsterdam = damncool*/
    : init_declarator
    | init_declarator_list ',' init_declarator
    ;

init_declarator
    : declarator '=' initializer
    | declarator
    ;

storage_class_specifier
    : TYPEDEF    /* identifiers must be flagged as TYPEDEF_NAME */
    | EXTERN
    | STATIC
    ;

type_specifier
    : VOID
    | BOOL
    | INT
    | FLOAT
    | VEC2
    | VEC3
    | VEC4
    | IVEC2
    | IVEC3
    | IVEC4
    | BVEC2
    | BVEC3
    | COLOR
    ;

declarator
    : IDENTIFIER     /* berlin[12][12]*/
    | interface_method      { ShaderInterfaceCheck(shader_class, interface); }
    | '(' declarator ')'
    | declarator '[' ']'
    | declarator '[' '*' ']'
    | declarator '[' assignment_expression ']'
    | declarator '(' parameter_list ')'
    | declarator '(' ')'
    | declarator '(' identifier_list ')'
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

primary_expression
    : IDENTIFIER
    | state     { ShaderStatecheck(shader_class, state_variable); }
    | constant
    | '(' expression ')'
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;
logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

equality_expression
    : relation_expression
    | equality_expression EQ_OP relation_expression
    | equality_expression NE_OP relation_expression
    ;

relation_expression
    : shift_expression
    | relation_expression '<' shift_expression
    | relation_expression '>' shift_expression
    | relation_expression LE_OP shift_expression
    | relation_expression GE_OP shift_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression
    | multiplicative_expression '/' cast_expression
    | multiplicative_expression '%' cast_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator cast_expression
    | SIZEOF unary_expression
    | SIZEOF '(' type_name ')'
    | COLOR '(' unary_expression ')'
    | VEC3 '(' unary_expression ')'
    ;

postfix_expression    /* num++ */
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' ')'
    | postfix_expression '(' argument_expression_list ')'
    | postfix_expression '.' IDENTIFIER
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    | '(' type_name ')' '{' initializer_list '}'
    | '(' type_name ')' '{' initializer_list ',' '}'
    ;

cast_expression
    : unary_expression
    | '(' type_name ')' cast_expression
    ;

constant_expression
    : conditional_expression
    ;

statement
    : labeled_statement      { printf("STATEMENT\n");}
    | compound_statement     { printf("STATEMENT\n");}
    | expression_statement   { printf("STATEMENT\n");}
    | selection_statement    { printf("STATEMENT\n");}
    | iteration_statement    { printf("STATEMENT\n");}
    | jump_statement         { printf("STATEMENT\n");}
    ;

labeled_statement
    : IDENTIFIER ':' statement
    | CASE constant_expression ':' statement
    | DEFAULT ':' statement
    ;

compound_statement
    : '{' '}'
    | '{' block_item_list '}'
    ;


expression_statement
    : ';'
    | expression ';'
    ;

selection_statement
    : IF '(' expression ')' statement ELSE statement   { printf("IF - ELSE\n");}
    | IF '(' expression ')' statement  { printf("IF\n");}
    | SWITCH '(' expression ')' statement
    ;

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')'
    | FOR '(' expression_statement expression_statement expression')' statement
    | FOR '(' expression_statement expression_statement ')' statement
    | FOR '(' declaration expression_statement expression ')' statement
    | FOR '(' declaration expression_statement ')' statement
    ;

jump_statement
    : RETURN ';'
    | RETURN expression ';'
    | CONTINUE ';'
    | BREAK ';'
    | GOTO IDENTIFIER ';'
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
    | type_specifier
    | type_qualifier specifier_qualifier_list
    | type_qualifier
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

initializer_list
    : designation initializer
    | initializer
    | initializer_list ',' designation initializer
    | initializer_list ',' initializer
    ;

block_item_list
    : block_item
    | block_item_list block_item
    ;


block_item
    : declaration
    | statement
    ;

type_name
    : specifier_qualifier_list
    ;

initializer
    : '{' initializer_list '}'
    | '{' initializer_list ',' '}'
    | assignment_expression
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    | '.' IDENTIFIER    /* ??? */
    ;

constant
    : FLOAT_CONSTANT
    | INT_CONSTANT
    | BOOL_CONSTANT
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

type_qualifier
    : ATTRIBUTE
    | UNIFORM
    | VARYING
    | PUBLIC
    | PRIVATE
    | SCRATCH
    ;

interface_method
    : CONSTRUCTOR                 {interface = constructor;}
    | GENERATERAY                 {interface = generateray;}
    | INTERSECT                   {interface = intersect;}
    | COMPUTEBOUNDS               {interface = computebounds;}
    | COMPUTENORMAL               {interface = computenormal;}
    | COMPUTETEXTURECOORDINATES   {interface = computetexturecoordinates;}
    | COMPUTEDERIVATIVES          {interface = computederivatives;}
    | GENERATESAMPLE              {interface = generatesample;}
    | SAMPLEPDF                   {interface = computetexturecoordinates;}
    | LOOKUP                      {interface = LOOKUP;}
    | SHADE                       {interface = shade;}
    | BSDF                        {interface = bsdf;}
    | SAMPLEBSDF                  {interface = samplepdf;}
    | EVALUATEPDF                 {interface = evaluatepdf;}
    | EMISSION                    {interface = emission;}
    | ILLUMINATION                {interface = illumination;}
    ;

state
    : RAYORIGIN                   {state_variable = rayorigin;}
    | RAYDIRECTION                {state_variable = raydirection;}
    | INVERSERAYDIRECTION         {state_variable = inverseraydirection;}
    | EPSILON                     {state_variable = epsilon;}
    | HITDISTANCE                 {state_variable = hitdistance;}
    | SCREENCOORD                 {state_variable = screencoord;}
    | LENSCOORD                   {state_variable = lenscoord;}
    | DU                          {state_variable = du;}
    | DV                          {state_variable = dv;}
    | TIMESEED                    {state_variable = timeseed;}
    | BOUNDMIN                    {state_variable = boundmin;}
    | BOUNDMAX                    {state_variable = boundmax;}
    | GEOMETRICNORMAL             {state_variable = geometricnormal;}
    | DPDU                        {state_variable = dpdu;}
    | DPDV                        {state_variable = dpdv;}
    | SHADINGNORMAL               {state_variable = shadingnormal;}
    | TEXTUREUV                   {state_variable = textureuv;}
    | TEXTUREUVW                  {state_variable = textureuvw;}
    | DSDU                        {state_variable = dsdu;}
    | DSDV                        {state_variable = dsdv;}
    | PDF                         {state_variable = pdf;}
    | TEXTURECOLOR                {state_variable = texturecolor;}
    | FLOATTEXTUREVALUE           {state_variable = floattexturevalue;}
    | DTDU                        {state_variable = dtdu;}
    | DTDV                        {state_variable = dtdv;}
    | HITPOINT                    {state_variable = hitpoint;}
    | LIGHTDIRECTION              {state_variable = lightdirection;}
    | LIGHTDISTANCE               {state_variable = lightdistance;}
    | LIGHTCOLOR                  {state_variable = lightcolor;}
    | EMISSIONCOLOR               {state_variable = emissioncolor;}
    | BSDFSEED                    {state_variable = bsdfseed;}
    | SAMPLECOLOR                 {state_variable = samplecolor;}
    | BSDFVALUE                   {state_variable = bsdfvalue;}
    ;

%%

int main( int argc, char **argv )
{
  ++argv, --argc;
  if ( argc > 0 )
  stdin = fopen( argv[0], "r" );
  yyparse();

  return 0;
}

void ShaderInterfaceCheck(ShaderClass shader_class, Interface interface){
  ShaderClass sc;
  switch(interface){
    case generateray:
      sc = camera;
      break;
    case computenormal:
    case computebounds:
    case computederivatives:
    case computetexturecoordinates:
    case generatesample:
    case samplepdf:
      sc = primitive;
      break;
    case lookup:
      sc = texture;
      break;
    case shade:
    case bsdf:
    case samplebsdf:
    case evaluatepdf:
    case emission:
      sc = material;
      break;
    case illumination:
      sc = light;
      break;
    default: // CONSTRUCTOR
      sc = shader_class;
      break;
    }
  if(sc != shader_class){
    fprintf(stderr, "Error: %s cannot have an interface method of %s\n", SHADERCLASS[shader_class], SHADERCLASS[sc]);
  }
}

void ShaderStatecheck(ShaderClass shader_class, StateVariable state_variable){
  ShaderClass sc = shader_class;
  bool state_comfirmed = false;
  while(state_comfirmed == false){
    if (sc == camera){
      switch(state_variable){
        case rayorigin:
        case raydirection:
        case inverseraydirection:
        case epsilon:
        case hitdistance:
        case screencoord:
        case lenscoord:
        case du:
        case dv:
        case timeseed:
          state_comfirmed = true;
          break;
        default:
          sc = texture;
          break;
        }
      }

    if (sc == primitive){
      switch(state_variable){
        case rayorigin:
        case raydirection:
        case inverseraydirection:
        case epsilon:
        case hitdistance:
        case boundmin:
        case boundmax:
        case geometricnormal:
        case shadingnormal:
        case dpdu:
        case dpdv:
        case textureuv:
        case textureuvw:
        case dsdu:
        case dsdv:
        case pdf:
        case timeseed:
          state_comfirmed = true;
          break;
        default:
          sc = material;
          break;
        }
      }

    if (sc == texture){
      switch(state_variable){
        case textureuv:
        case textureuvw:
        case texturecolor:
        case floattexturevalue:
        case du:
        case dv:
        case dtdu:
        case dsdv:
        case dsdu:
        case dtdv:
        case dpdu:
        case dpdv:
        case timeseed:
          state_comfirmed = true;
          break;
        default:
          sc = primitive;
          break;
        }
      }

    if (sc == material){
      switch(state_variable){
        case rayorigin:
        case raydirection:
        case inverseraydirection:
        case hitpoint:
        case dpdu:
        case dpdv:
        case lightdirection:
        case lightdistance:
        case lightcolor:
        case emissioncolor:
        case bsdfseed:
        case timeseed:
        case pdf:
        case samplecolor:
        case du:
        case dv:
          state_comfirmed = true;
          break;
        default:
          sc = light;
          break;
        }
      }

    if (sc == light){
      switch(state_variable){
        case hitpoint:
        case geometricnormal:
        case shadingnormal:
        case lightdirection:
        case timeseed:
          state_comfirmed = true;
          break;
        default:
          sc = camera;
          break;
        }
      }
    }


  if(sc != shader_class){
    fprintf(stderr,"Error: %s cannot access to a state of %s\n", SHADERCLASS[shader_class], SHADERCLASS[sc]);
  }
}

void yyerror(const char *s)
{
  fprintf(stderr, "error: %s\n", s);
}
