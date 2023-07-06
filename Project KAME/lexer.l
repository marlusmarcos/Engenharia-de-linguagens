%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  
  extern int yyerror (char *msg);  
%}
%option yylineno

%%

[ \t\n]                       	;
[0-9]+							{yylval.iValue = atoi(yytext);
									return NUMBER;}
([0-9]+\.[0-9]*)|(\.[0-9]+)		{yylval.fValue = atof(yytext);
									return REAL;}

"int"					{yylval.sValue = strdup(yytext);
							return TYPE;}
"float"					{yylval.sValue = strdup(yytext);
							return TYPE;}
"boolean"				{yylval.sValue = strdup(yytext);
							return TYPE;}
"char"					{yylval.sValue = strdup(yytext);
							return TYPE;}
"string"				{yylval.sValue = strdup(yytext);
							return TYPE;}
"void"					{yylval.sValue = strdup(yytext);
							return TYPE;}
"enum"					{return(ENUM);}
"struct"				{return(STRUCT);}

"var"					{return(VAR);}
"break"					{return(BREAK);}
"return"				{return(RETURN);}
"continue"				{return(CONTINUE);}
"input"					{return(INPUT);}
"output"				{return(OUTPUT);}
"function"				{return(FUNCTION);}
"procedure"				{return(PROC);}
"while"					{return(WHILE);}
"for"					{return(FOR);}
"typedef"				{return(TYPEDEF);}
"true"					{return(TRUE);}
"false"					{return(FALSE);}
"main"					{return(MAIN_BLOCK);}
"length"				{return(LENGTH);}

"{"              		{return(BEGIN_BLOCK);}
"}"						{return(END_BLOCK);}
"if"					{return(IF);}
"else"                	{return(ELSE);}
":"                   	{return(yytext[0]);}
";"                   	{return(yytext[0]);}
","                   	{return(yytext[0]);}
"."                   	{return(yytext[0]);}
"&"                   	{return(yytext[0]);}
"="                   	{return(ASSIGN);}
"["						{return(yytext[0]);}
"]"                 	{return(yytext[0]);}
"("						{return(yytext[0]);}
")"                 	{return(yytext[0]);}

"||"						{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"$$" 					   	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"not" 						{return(NOT);}
"++" 					   	{yylval.sValue = strdup(yytext);
								return OPC;}
"--" 					    {yylval.sValue = strdup(yytext);
								return OPC;}
"+=" 					   	{yylval.sValue = strdup(yytext);
								return OPA;}
"-="						{yylval.sValue = strdup(yytext);
								return OPA;}
"*=" 					 	{yylval.sValue = strdup(yytext);
								return OPA;}
"/=" 					  	{yylval.sValue = strdup(yytext);
								return OPA;}
"+" 					 	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"-" 					   	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"*" 					  	{yylval.sValue = strdup(yytext);
								return STRONG_OP;}
"/" 					  	{yylval.sValue = strdup(yytext);
								return STRONG_OP;}
"%" 					  	{yylval.sValue = strdup(yytext);
								return STRONG_OP;}

"<" 					  	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"<=" 					  	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
">=" 					   	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
">" 					  	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"==" 					   	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}
"!=" 					   	{yylval.sValue = strdup(yytext);
								return WEAK_OP;}

(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)		;

(\"[a-zA-Z0-9\%_ ]*\")	  		{yylval.sValue = strdup(yytext);
								return STR_LITERAL;}
(\'[a-zA-Z0-9\%_ ]*\')	  		{yylval.sValue = strdup(yytext);
								return STR_LITERAL;}
[a-zA-Z][a-zA-Z0-9]*		{yylval.sValue = strdup(yytext); 
                      			return ID;}
.                     		{yyerror("invalid character");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif
