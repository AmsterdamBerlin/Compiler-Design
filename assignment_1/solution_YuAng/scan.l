%{
   /*definetions of RTSL*/
%}


%option noyywrap
%x MULTI_COMMENT

%{
int line_count = 1;
%}





DIGITAL [0-9] 
LETTER [a-zA-Z]
SIGN [+|-]
INTEGER {SIGN}?{DIGITAL}+
FLOAT {SIGN}?{DIGITAL}*"."{DIGITAL}*
EXP {SIGN}?{FLOAT|INTEGER}[E|e]{SIGN}?{}
IDENTIFIER {LETTER}({LETTER}|{DIGITAL}|"_")*
TYPE "void"|"int"|"float"|"bool"|"vec2"|"vec3"|"vec4"|"ivec2"|"ivec3"|"ivec4"|"bvec2"|"bvec3"|"bvec4"|"rt_Primitive"|"rt_Camera"|"rt_Material"|"rt_Texture"|"rt_Light"
STATE "rt_ScreenCoord"|"rt_LensCoord"|"rt_Epsilon"|"rt_HitDistance"|"rt_BoundMin"|"rt_BoundMax"|"rt_TextureUV"|"rt_TextureUVW"|"rt_TextureColor"|"rt_FloatTextureValue"|"rt_dsdu"|"rt_dtdu"|"rt_dsdv"|"rt_dtdv"|"rt_RayOrigin"|"rt_RayDirection"|"rt_InverseRayDirection"|"rt_dPdu"|"rt_dPdv"|"rt_LightDistance"|"rt_LightColor"|"rt_EmissionColor"|"rt_BSDFSeed"|"rt_PDF"|"rt_SampleColor"|"rt_BSDFValue"|"rt_du"|"rt_dv"|"rt_HitPoint"|"rt_GeometricNormal"|"rt_ShadingNormal"|"rt_LightDirection"|"rt_TimeSeed"
QUALIFIER "attribute"|"uniform"|"varying"|"const"|"public"|"private"|"scratch"
KEYWORD "sqrt"|"dot"|"class"|"inverse"|"inside"|"perpendicular"|"dominantAxis"|"trace"|"hit"|"luminance"|"rand"|"pow"|"min"|"max"|"illuminance"|"ambient"|"break"|"case"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"for"|"goto"|"if"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"while"


%%

"/*" {BEGIN(MULTI_COMMENT);}
<MULTI_COMMENT>"*/" {BEGIN(INITIAL);}
<MULTI_COMMENT>\n {line_count++;}
<MULTI_COMMENT>. { }

"//".*"\n" {line_count++;}			
"\n" {line_count++;}

{TYPE} {printf("TYPE %s\n",yytext);}
{STATE} {printf("STATE %s\n",yytext);}
{QUALIFIER} {printf("QUALIFIER %s\n",yytext);}
{KEYWORD} {printf("KEYWORD %s\n",yytext);}
{INTEGER} {printf("INTEGER %s\n",yytext);}
{FLOAT} {printf("FLOAT %s\n",yytext);}

" "* { }
":" {printf("COLON\n");}
";" {printf("SEMICOLON\n");}
"+" {printf("PLUS\n");}
"*" {printf("MUL\n");}
"-" {printf("MINUS\n");}
"/" {printf("DIV\n");}
"%" {printf("MODULO_DIV\n");}
"=" {printf("ASSIGN\n");}
"==" {printf("EQUAL\n");}
"!=" {printf("NOT_EQUAL\n");}
"<" {printf("LT\n");}
"<=" {printf("LE\n");}
">" {printf("GT\n");}
">=" {printf("GE\n");}
"," {printf("COMMA\n");}
"(" {printf("LPARENTHESIS\n");}
")" {printf("RPARENTHESIS\n");}
"[" {printf("LBRACKET\n");}
"]" {printf("RBRACKET\n");}
"{" {printf("LBRACE\n");}
"}" {printf("RBRACE\n");}
"&&" {printf("AND\n");}
"||" {printf("OR\n");}
"++" {printf("INC\n");}
"--" {printf("DEC\n");}
 
{IDENTIFIER} {printf("IDENTIFIER %s\n",yytext);}
"."{IDENTIFIER} {printf("SWIZZLE %s\n",yytext);}
. {printf("ERROR(%d): Unregconized symbol \"%s\"\n",line_count,yytext);}
%%


int main() {
  yylex();
    return 0;
}
