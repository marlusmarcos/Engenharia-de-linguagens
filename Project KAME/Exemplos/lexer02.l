%{
  #include <stdio.h>
  #include "y.tab.h"
  
  extern int yyerror (char *msg);  
%}

%%

[ \t\n]               ;
[0-9]+           		  {yylval.iValue = atoi(yytext); 
                       return NUMBER;}
"while"      			    {return(WHILE);}
"begin"      			    {return(BLOCK_BEGIN);}
"end"      				    {return(BLOCK_END);}
"do"      				    {return(DO);}
"if"      				    {return(IF);}
"then"      			    {return(THEN);}
"else"      			    {return(ELSE);}
";"      				      {return(SEMI);}
":="					        {return ASSIGN;}
[a-zA-Z][a-zA-Z0-9]*	{yylval.sValue = strdup(yytext); 
                       return ID;}
.                     {yyerror("invalid character");}

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif