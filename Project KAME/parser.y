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
%token VAR BREAK RETURN CONTINUE INPUT OUTPUT FUNCTION PROC WHILE FOR TYPEDEF TRUE FALSE BEGIN_BLOCK END_BLOCK IF ELSE ASSIGN MAIN_BLOCK

%start prog

%%
prog : declaration_seq  subprograms main_seq;


declaration_seq : declaration ';' declaration_seq		{}
				| ;

declaration : VAR id_list ':' TYPE					{};
id_list : ID										{}
		| ID ',' id_list							{};


subprograms : subprogram ';' subprograms			{}
			| ;
subprogram : function								{} 
			| proc 									{};


function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK commands END_BLOCK	{};
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK commands END_BLOCK						{};
paramsdef : ID ':' TYPE																{}
			| ID ':' TYPE ',' paramsdef												{}
			| ;


commands : command ';' commands		{}
			| ;
command : declaration				{}
		| assign					{}
		| control_block				{}
		| loop_block				{}
		| BREAK						{}
		| RETURN					{}
		| CONTINUE					{}
		| INPUT						{}
		| OUTPUT					{};


assign : OPC ID												{}
		| ID OPC											{};
control_block : IF '(' ')' BEGIN_BLOCK END_BLOCK			{}
				| IF '(' ')' BEGIN_BLOCK END_BLOCK	
					ELSE BEGIN_BLOCK END_BLOCK				{}
				| WHILE '(' ')' BEGIN_BLOCK END_BLOCK		{};
loop_block : FOR '(' ';' ';' ')' BEGIN_BLOCK END_BLOCK		{};


main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK END_BLOCK ';'			{}
		| ;
%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}