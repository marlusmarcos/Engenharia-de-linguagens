%{
  #include <stdio.h>  
%}

%%

[ \t\n]                       ;
[0-9]+                        {printf("NUMBER(%s)\n",yytext);}
([0-9]+\.[0-9]*)|(\.[0-9]+)    {printf("REAL(%s)\n",yytext);}

"int"									{printf("TYPE(%s)\n",yytext);}
"float"								{printf("TYPE(%s)\n",yytext);}
"boolean"							{printf("TYPE(%s)\n",yytext);}
"char"								{printf("TYPE(%s)\n",yytext);}
"string"						  {printf("TYPE(%s)\n",yytext);}
"void"						    {printf("TYPE(%s)\n",yytext);}
"enum"								{printf("TYPE(%s)\n",yytext);}
"struct"						  {printf("TYPE(%s)\n",yytext);}

"var"                 {printf("VAR\n");}
"break" 							{printf("BREAK\n");}
"return" 							{printf("RETURN\n");}
"continue" 						{printf("CONTINUE\n");}
"input" 							{printf("input\n");}
"OUTPUT" 							{printf("OUTPUT\n");}
"function"						{printf("FUNCTION\n");}
"while"              	{printf("WHILE\n");}
"for" 						    {printf("FOR\n");}
"typedef" 					  {printf("TYPEDEF\n");}
"true" 					      {printf("TRUE\n");}
"false" 					    {printf("FALSE\n");}

"{"              			{printf("BEGIN\n");}
"}"                 	{printf("END\n");}
"if"                  {printf("IF\n");}
"else"                {printf("ELSE\n");}
":"                   {printf("COLON\n");}
";"                   {printf("SEMICOLON\n");}
","                   {printf("COMMA\n");}
"."                   {printf("DOT\n");}
"="                   {printf("ASSIGNMENT\n");}
"["              			{printf("AC\n");}
"]"                 	{printf("FC\n");}
"("              			{printf("AP\n");}
")"                 	{printf("FP\n");}

"or" 					        {printf("OP(%s)\n",yytext);}
"and" 					      {printf("OP(%s)\n",yytext);}
"not" 					      {printf("OP(%s)\n",yytext);}
"++" 					        {printf("OP(%s)\n",yytext);}
"--" 					        {printf("OP(%s)\n",yytext);}
"+=" 					        {printf("OP(%s)\n",yytext);}
"-=" 					        {printf("OP(%s)\n",yytext);}
"*=" 					        {printf("OP(%s)\n",yytext);}
"/=" 					        {printf("OP(%s)\n",yytext);}
"+" 					        {printf("OP(%s)\n",yytext);}
"-" 					        {printf("OP(%s)\n",yytext);}
"*" 					        {printf("OP(%s)\n",yytext);}
"/" 					        {printf("OP(%s)\n",yytext);}
"%" 					        {printf("OP(%s)\n",yytext);}

"<" 					        {printf("RELATION(%s)\n",yytext);}
"<=" 					        {printf("RELATION(%s)\n",yytext);}
">=" 					        {printf("RELATION(%s)\n",yytext);}
">" 					        {printf("RELATION(%s)\n",yytext);}
"==" 					        {printf("RELATION(%s)\n",yytext);}
"!=" 					        {printf("RELATION(%s)\n",yytext);}

(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*) {printf("Comment: %s.\n", yytext);}

(\"[a-zA-Z0-9]*\")	  {printf("LITERAL(%s)\n",yytext);}
(\'[a-zA-Z0-9]*\')	  {printf("LITERAL(%s)\n",yytext);}
[a-zA-Z][a-zA-Z0-9]*	{printf("ID(%s)\n",yytext);}
.                     {printf("Invalid character.\n");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif

int main(void)
{
  yylex();  
  return 0;
}