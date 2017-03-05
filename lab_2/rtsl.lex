/**
  Compiler Design Course - TU Berlin
  Winter Term 2016/17

  Assignment 2
  YuAng Chen
  flex is based on Oliver`s assignment
**/
%option noyywrap

DG        [0-9]
HX        [A-Fa-f0-9]
EX        [eE][+-]?{DG}+
US        [uU]
FS        [fF]

ID_START  [a-zA-Z_]
ID_CHAR   {ID_START}|[0-9]
ID        {ID_START}{ID_CHAR}*

WS        [ \t\r\v]



%{
#include <stdio.h>
#include "rtsl.yy.h"

int g_line_number = 1;

%}

%x ML_COMMENT

%%
(true|false)                            { return BOOL_CONSTANT; }
0[xX]{HX}+{US}?                         { return INT_CONSTANT; }
0{DG}+{US}?                             { return INT_CONSTANT; }
{DG}+{US}?                              { return INT_CONSTANT; }
{DG}+{EX}{FS}?                          { return FLOAT_CONSTANT; }
{DG}*"."{DG}+{EX}?{FS}?                 { return FLOAT_CONSTANT; }
{DG}+"."{DG}*{EX}?{FS}?                 { return FLOAT_CONSTANT; }

"=="                                    { return EQ_OP; }
"!="                                    { return NE_OP; }
"<="                                    { return LE_OP; }
">="                                    { return GE_OP; }
"&&"                                    { return AND_OP; }
"||"                                    { return OR_OP; }
"++"                                    { return INC_OP; }
"--"                                    { return DEC_OP; }
"<<"                                    { return LEFT_OP; }
">>"                                    { return RIGHT_OP; }
"+="					                          { return ADD_ASSIGN; }
"-="				                            { return SUB_ASSIGN; }
"*="				                           	{ return MUL_ASSIGN; }
"/="				                          	{ return DIV_ASSIGN; }
"%="				                          	{ return MOD_ASSIGN; }
"&="					                          { return AND_ASSIGN; }
"^="					                          { return XOR_ASSIGN; }
"+"                                     { return '+'; }
"*"                                     { return '*'; }
"-"                                     { return '-'; }
"/"                                     { return '/'; }
"="                                     { return '='; }
"<"                                     { return '<'; }
">"                                     { return '>'; }
","                                     { return ','; }
"."                                     { return '.'; }
":"                                     { return ':'; }
";"                                     { return ';'; }
"("                                     { return '('; }
")"                                     { return ')'; }
"{"                                     { return '{'; }
"}"                                     { return '}'; }
"["                                     { return '['; }
"]"                                     { return ']'; }
"%"                                     { return '%'; }
"|"                                     { return '|'; }
"^"                                     { return '^'; }
"&"                                     { return '%'; }
"~"                                     { return '~'; }
"!"                                     { return '!'; }

"void"                                  { return VOID; }
"int"                                   { return INT; }
"float"                                 { return FLOAT; }
"bool"                                  { return BOOL; }
"vec2"                                  { return VEC2; }
"vec3"                                  { return VEC3; }
"vec4"                                  { return VEC4; }
"ivec2"                                 { return IVEC2; }
"ivec3"                                 { return IVEC3; }
"ivec4"                                 { return IVEC4; }
"bvec2"                                 { return BVEC2; }
"bvec3"                                 { return BVEC3; }

"attribute"                             { return ATTRIBUTE; }
"uniform"                               { return UNIFORM; }
"varying"                               { return VARYING; }
"public"                                { return PUBLIC; }
"private"                               { return PRIVATE; }
"scratch"                               { return SCRATCH; }

"class"                                 { return CLASS; }
"break"                                 { return BREAK; }
"case"                                  { return CASE; }
"const"                                 { return CONST; }
"continue"                              { return CONTINUE; }
"default"                               { return DEFAULT; }
"do"                                    { return DO; }
"double"                                { return DOUBLE; }
"else"                                  { return ELSE; }
"enum"                                  { return ENUM; }
"extern"                                { return EXTERN; }
"for"                                   { return FOR; }
"goto"                                  { return GOTO; }
"if"                                    { return IF; }
"sizeof"                                { return SIZEOF; }
"signed"	                              { return SIGNED; }
"static"                                { return STATIC; }
"struct"                                { return STRUCT; }
"switch"                                { return SWITCH; }
"typedef"                               { return TYPEDEF; }
"union"                                 { return UNION; }
"unsigned"                              { return UNSIGNED; }
"while"                                 { return WHILE; }
"return"                                { return RETURN; }

"rt_Primitive"                          { return PRIMITIVE;}
"rt_Camera"                             { return CAMERA;}
"rt_Material"                           { return MATERIAL;}
"rt_Texture"                            { return TEXTURE;}
"rt_Light"                              { return LIGHT;}
"color"                                 { return COLOR;}

"constructor"                           { return CONSTRUCTOR;}
"generateRay"                           { return GENERATERAY;}
"intersect"                             { return INTERSECT;}
"computeBounds"                         { return COMPUTEBOUNDS;}
"computeNormal"                         { return COMPUTENORMAL;}
"computeTextureCoordinates"             { return COMPUTETEXTURECOORDINATES;}
"computeDerivatives"                    { return COMPUTEDERIVATIVES;}
"generateSample"                        { return GENERATESAMPLE;}
"samplePDF"                             { return SAMPLEPDF;}
"lookup"                                { return LOOKUP;}
"shade"                                 { return SHADE;}
"BSDF"                                  { return BSDF;}
"sampleBSDF"                            { return SAMPLEBSDF;}
"evaluatePDF"                           { return EVALUATEPDF;}
"emission"                              { return EMISSION;}
"illumination"                          { return ILLUMINATION;}

"rt_RayOrigin"                          { return RAYORIGIN;}
"rt_RayDirection"                       { return RAYDIRECTION;}
"rt_InverseRayDirection"                { return INVERSERAYDIRECTION;}
"rt_Epsilon"                            { return EPSILON;}
"rt_HitDistance"                        { return HITDISTANCE;}
"rt_ScreenCoord"                        { return SCREENCOORD;}
"rt_LensCoord"                          { return LENSCOORD;}
"rt_du"                                 { return DU;}
"rt_dv"                                 { return DV;}
"rt_TimeSeed"                           { return TIMESEED;}
"rt_BoundMin"                           { return BOUNDMIN;}
"rt_BoundMax"                           { return BOUNDMAX;}
"rt_GeometricNormal"                    { return GEOMETRICNORMAL;}
"rt_dPdu"                               { return DPDU;}
"rt_dPdv"                               { return DPDV;}
"rt_ShadingNormal"                      { return SHADINGNORMAL;}
"rt_TextureUV"                          { return TEXTUREUV;}
"rt_TextureUVW"                         { return TEXTUREUVW;}
"rt_dsdu"                               { return DSDU;}
"rt_dsdv"                               { return DSDV;}
"rt_PDF"                                { return PDF;}
"rt_TextureColor"                       { return TEXTURECOLOR;}
"rt_FloatTextureValue"                  { return FLOATTEXTUREVALUE;}
"rt_dtdu"                               { return DTDU;}
"rt_dtdv"                               { return DTDV;}
"rt_HitPoint"                           { return HITPOINT;}
"rt_LightDirection"                     { return LIGHTDIRECTION;}
"rt_LightDistance"                      { return LIGHTDISTANCE;}
"rt_LightColor"                         { return LIGHTCOLOR;}
"rt_EmissionColor"                      { return EMISSIONCOLOR;}
"rt_BSDFSeed"                           { return BSDFSEED;}
"rt_SampleColor"                        { return SAMPLECOLOR;}
"rt_BSDFValue"                          { return BSDFVALUE;}



{ID}                                    { return IDENTIFIER; }

"//".*\n                                { ++g_line_number; }
"/*"                                    { BEGIN(ML_COMMENT); }

<ML_COMMENT>\n                          { ++g_line_number; }
<ML_COMMENT>[^*\n]*                     { ; }
<ML_COMMENT>"*"\n                       { ++g_line_number; }
<ML_COMMENT>"*"[^/]                     { ; }
<ML_COMMENT>"*/"                        { BEGIN(INITIAL); }

\n                                      { ++g_line_number; }
{WS}                                    { ; }
.                                       {  }
%%
