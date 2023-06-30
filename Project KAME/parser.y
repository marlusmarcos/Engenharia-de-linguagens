%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./lib/record.h"
#include "./lib/traducao_aux.h"
#include "./lib/semantics.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;

%}

%union {
	int		iValue;		/* integer value */
	float	fValue;		/* float value */	 
	char 	cValue; 	/* char value */
	char 	*sValue;  	/* string value */
	struct record * rec;
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

%type <rec> main_seq command commands id_list declaration_seq subprograms declaration subprogram initialization exp term factor var
%type <rec> user_def type_def array_dim function proc paramsdef params func_proc_call assign control_block loop_block enum_init
%start prog

%%
prog : declaration_seq subprograms main_seq
{
	fprintf(yyout, "%s\n%s\n%s", $1->code, $2->code, $3->code);
	freeRecord($1);
	freeRecord($2);
	freeRecord($3);
};


declaration_seq : declaration ';' declaration_seq	{ dec_seq1(&$$, &$1, &$3); }
				|									{ dec_seq2(&$$);};


declaration : VAR id_list ':' TYPE					{ dec1(&$$, &$2, &$4); }
			| user_def								{ dec2(&$$, &$1); }
			| type_def								{ dec3(&$$, &$1); };


id_list : ID										{ id_l1(&$$, &$1); }
		| ID array_dim								{ id_l2(&$$, &$1, &$2); }
		| ID ',' id_list							{ id_l3(&$$, &$1, &$3); }
		| ID array_dim ',' id_list					{ id_l4(&$$, &$1, &$2, &$4); }


initialization : VAR id_list ':' TYPE ASSIGN exp	{ init1(&$$, &$2, &$4, &$6); };


subprograms : subprogram ';' subprograms			{ subprogs1(&$$, &$1, &$3); }
		| 											{ subprogs2(&$$); };


subprogram : function								{ subprog1(&$$, &$1); } 
			| proc 									{ subprog1(&$$, &$1); };


function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/
													{ func1(&$$, &$2, &$4, &$7, &$9); };
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/
													{ proc1(&$$, &$2, &$4, &$7); };
paramsdef : var ':' TYPE							{ pard1(&$$, &$1, &$3); }
			| var ':' TYPE ',' paramsdef			{ pard2(&$$, &$1, &$3, &$5); }
			| 										{ pard3(&$$); };

params : exp							{ par1(&$$, &$1); }
		| exp ',' params				{ par2(&$$, &$1, &$3); }
		| 								{ par3(&$$); };

func_proc_call : ID '(' params ')'		{ f_proc_c1(&$$, &$1, &$3); };


commands : command ';' commands			{ comds1(&$$, &$1, &$3); }
		| 								{ comds2(&$$); };


command : declaration				{ comd1(&$$, &$1); }
		| assign					{ comd2(&$$, &$1); }
		| initialization			{ comd3(&$$, &$1); }
		| control_block				{ comd4(&$$, &$1); }
		| loop_block				{ comd5(&$$, &$1); }
		| func_proc_call			{ comd6(&$$, &$1); }
		| BREAK						{ comd7(&$$); }
		| RETURN					{ comd8(&$$); }
		| RETURN exp				{ comd9(&$$, &$2); }
		| CONTINUE					{ comd10(&$$); }
		| INPUT	'(' ')'				{ comd11(&$$); }
		| OUTPUT '(' exp ')'		{ comd12(&$$, &$3); };


user_def : STRUCT ID BEGIN_BLOCK declaration_seq END_BLOCK		{ u_d1(&$$, &$2, &$4); }
		| ENUM ID BEGIN_BLOCK enum_init END_BLOCK				{ u_d2(&$$, &$2, &$4); };
enum_init :	ID													{ enum_i1(&$$, &$1); }
			| ID ',' enum_init									{ enum_i2(&$$, &$1, &$3); }
			| ID ASSIGN NUMBER									{ enum_i3(&$$, &$1, &$3); }
			| ID ASSIGN NUMBER ',' enum_init					{ enum_i4(&$$, &$1, &$3, &$5); };
type_def : TYPEDEF ID ASSIGN user_def							{ ty_d1(&$$, &$2, &$4); };

assign : OPC ID							{ asg1(&$$, &$1, &$2); }
		| ID OPC						{ asg2(&$$, &$1, &$2); }
		| var ASSIGN exp				{ asg3(&$$, &$1, &$3); }
		| var OPA exp					{ asg4(&$$, &$1, &$2, &$3); };

		
control_block : IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK			{ ctrl_b1(&$$, &$3, &$6); }
				| IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK	
					ELSE BEGIN_BLOCK commands END_BLOCK					{ ctrl_b2(&$$, &$3, &$6, &$10); }
				| WHILE '(' exp ')' BEGIN_BLOCK commands END_BLOCK		{ ctrl_b3(&$$, &$3, &$6); };


loop_block : FOR '(' initialization ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK							{ fr1(&$$, &$3, &$5, &$7, &$10); }
			| FOR '(' assign ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK							{ fr2(&$$, &$3, &$5, &$7, &$10); };


exp : term							{ ex1(&$$, &$1); }
	| exp WEAK_OP term				{ ex2(&$$, &$1, &$2, &$3); };


term : factor						{ te1(&$$, &$1); }
		| term STRONG_OP factor		{ te2(&$$, &$1, &$2, &$3); };


factor : var							{ fac1(&$$, &$1); }
		| STR_LITERAL					{ fac2(&$$, &$1); }
		| NUMBER						{ fac3(&$$, &$1); }
		| REAL							{ fac4(&$$, &$1); }
		| func_proc_call				{ fac5(&$$, &$1); }
		| '(' exp ')'					{ fac6(&$$, &$2); }
		| WEAK_OP factor				{ fac7(&$$, &$1, &$2); }
		| TRUE							{ fac8(&$$); }
		| FALSE							{ fac9(&$$); }
		| NOT factor					{ fac10(&$$, &$2); }
		| LENGTH '(' factor ')'			{ fac11(&$$, &$3); };

var : ID								{ v1(&$$, &$1); }
	| ID array_dim						{ v2(&$$, &$1, &$2); }
	| ID '.' var						{ v3(&$$, &$1, &$3); };
array_dim : '[' ']'						{ arrd1(&$$); }
			| '[' ']' array_dim			{ arrd2(&$$, &$3); }
			| '[' exp ']'				{ arrd3(&$$, &$2); }
			| '[' exp ']' array_dim		{ arrd4(&$$, &$2, &$4); };


main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK commands END_BLOCK ';'	{ m1(&$$, &$5); }
		| 															{ m2(&$$); };
%%


int main (int argc, char ** argv) {
 	int codigo;

    if (argc != 3) {
       printf("Usage: $./compiler input.txt output.txt\nClosing application...\n");
       exit(0);
    }
    
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    codigo = yyparse();

    fclose(yyin);
    fclose(yyout);

	return codigo;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}
