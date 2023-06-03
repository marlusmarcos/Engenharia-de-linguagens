%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

%}

%union {
	int		iValue;		/* integer value */
	float	fValue;		/* float value */	 
	char 	cValue; 	/* char value */
	char 	*sValue;  	/* string value */
};

%token <sValue> ID
%token <sValue> TYPE
%token <iValue> NUMBER
%token <fValue> REAL
%token <sValue> STR_LITERAL
%token <sValue> BOOL_OP
%token <sValue> OPA
%token <sValue> OPC
%token <sValue> WEAK_OP
%token <sValue> STRONG_OP
%token <sValue> RELATION
%token <sValue> COMMENT
%token VAR BREAK RETURN CONTINUE INPUT OUTPUT FUNCTION WHILE FOR TYPEDEF TRUE FALSE BEGIN_BLOCK END_BLOCK IF ELSE ASSIGN

%start prog

%%
prog : declaration_seq 				{} 
	 ;

declaration_seq : declaration ';' declaration_seq		{}
				| ;

declaration : VAR ID ':' TYPE		{};
%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}