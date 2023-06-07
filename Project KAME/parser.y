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
%token <sValue> OPA
%token <sValue> OPC
%token <sValue> WEAK_OP
%token <sValue> STRONG_OP
%token <sValue> COMMENT
%token ENUM STRUCT VAR BREAK RETURN CONTINUE INPUT OUTPUT FUNCTION PROC WHILE FOR TYPEDEF TRUE FALSE BEGIN_BLOCK END_BLOCK IF ELSE ASSIGN MAIN_BLOCK NOT LENGTH

%start prog

%%
prog : declaration_seq  subprograms main_seq;


declaration_seq : declaration ';' declaration_seq		{}
				| ;

declaration : VAR id_list ':' TYPE					{}
			| user_def								{};
id_list : ID										{}
		| ID array_dim								{}
		| ID ',' id_list							{}
		| ID array_dim ',' id_list					{};
initialization : VAR id_list ':' TYPE ASSIGN exp	{};


subprograms : subprogram ';' subprograms			{}
			| ;
subprogram : function								{} 
			| proc 									{};


function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK commands END_BLOCK	{};
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK commands END_BLOCK						{};
paramsdef : var ':' TYPE															{}
			| var ':' TYPE ',' paramsdef											{}
			| ;
params : exp							{}
		| exp ',' params				{}
		| ;
func_proc_call : ID '(' params ')'		{};


commands : command ';' commands		{}
			| ;
command : declaration				{}
		| assign					{}
		| initialization			{}
		| control_block				{}
		| loop_block				{}
		| func_proc_call			{}
		| BREAK						{}
		| RETURN					{}
		| RETURN exp				{}
		| CONTINUE					{}
		| INPUT	'(' ')'				{}
		| OUTPUT '(' exp ')'		{};


user_def : STRUCT ID BEGIN_BLOCK declaration_seq END_BLOCK		{}
		| ENUM ID BEGIN_BLOCK id_list END_BLOCK					{};

assign : OPC ID												{}
		| ID OPC											{}
		| var ASSIGN exp									{}
		| var OPA exp										{};

		
control_block : IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK				{}
				| IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK	
					ELSE BEGIN_BLOCK commands END_BLOCK						{}
				| WHILE '(' exp ')' BEGIN_BLOCK commands END_BLOCK			{};
loop_block : FOR '(' initialization ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK								{}
			| FOR '(' assign ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK								{};


exp : term								{}
	| exp WEAK_OP term					{};
term : factor							{}
		| term STRONG_OP factor			{};
factor : var							{}
		| STR_LITERAL					{}
		| NUMBER						{}
		| REAL							{}
		| func_proc_call				{}
		| '(' exp ')'					{}
		| WEAK_OP factor				{}
		| TRUE							{}
		| FALSE							{}
		| NOT factor					{}
		| LENGTH '(' factor ')'			{};

var : ID								{}
	| ID array_dim						{}
	| ID '.' var						{};
array_dim : '[' ']'						{}
			| '[' ']' array_dim			{}
			| '[' exp ']'				{}
			| '[' exp ']' array_dim		{};

main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK commands END_BLOCK ';'		{}
		| ;
%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}