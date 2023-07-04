%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./lib/record.h"
#include "./lib/traducao_aux.h"
#include "./lib/semantics.h"
#include "./lib/symbol_table.h"
#include "./lib/stack.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;

SymbolTable *variablesTable;
SymbolTable *functionsTable;
stack *scopeStack;

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
%type <rec> user_def type_def array_dim function proc paramsdef params func_proc_call assign control_block loop_block enum_init else_block
%start prog

%%
prog : {pushS(scopeStack, "global", "");} declaration_seq subprograms main_seq
{
	popS(scopeStack);
	fprintf(yyout, "%s\n%s\n%s", $2->code, $3->code, $4->code); //$1 virou $2 e incrementou 1 em todos.
	freeRecord($2);
	freeRecord($3);
	freeRecord($4);
};


declaration_seq : declaration ';' declaration_seq	{ dec_seq1(&$$, &$1, &$3); }
				|									{ dec_seq2(&$$);};


declaration : VAR id_list ':' TYPE					
{
	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", $2->code,"",""), $2->code, $4);
	dec1(&$$, &$2, &$4);
}
			| user_def								{ dec2(&$$, &$1); }
			| type_def								{ dec3(&$$, &$1); };


id_list : ID										{ id_l1(&$$, &$1); }
		| ID array_dim								{ id_l2(&$$, &$1, &$2); }
		| ID ',' id_list							{ id_l3(&$$, &$1, &$3); }
		| ID array_dim ',' id_list					{ id_l4(&$$, &$1, &$2, &$4); }


initialization : VAR id_list ':' TYPE ASSIGN exp	
{
	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", $2->code,"",""), $2->code, $4);
	init1(&$$, &$2, &$4, &$6);
};


subprograms : subprogram ';' subprograms			{ subprogs1(&$$, &$1, &$3); }
		| 											{ subprogs2(&$$); };


subprogram : function								{ subprog1(&$$, &$1); } 
			| proc 									{ subprog1(&$$, &$1); };


function : FUNCTION ID {pushS(scopeStack, $2, "");} '(' paramsdef ')' ':' TYPE BEGIN_BLOCK commands END_BLOCK {popS(scopeStack);}
{ 
	func1(&$$, &$2, &$5, &$8, &$10);  //Prestar atençaõ aqui, o $9 virou $10, 4->5, 7, 8;
};
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK {pushS(scopeStack, $2, "");} commands END_BLOCK	{popS(scopeStack);}
{ 
	proc1(&$$, &$2, &$4, &$8); //Prestar atençaõ aqui, o $7 virou $8;
}; 
paramsdef : var ':' TYPE							
{ 
	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", $1->code,"",""), $1->code, $3);
	pard1(&$$, &$1, &$3); 
}
			| var ':' TYPE ',' paramsdef			
{
	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", $1->code,"",""), $1->code, $3);
	pard2(&$$, &$1, &$3, &$5);
}
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

		
control_block : IF '(' exp ')' BEGIN_BLOCK {pushS(scopeStack, "IF", "");} commands END_BLOCK else_block {popS(scopeStack);} //Aqui talvez precise mudar e guardar o id do if.
{
	ctrl_b1(&$$, &$3, &$7, &$9, "EXIT_IDIF"); //nessa parte, irei passar o id do if como parametro para a tradução.
};
				

else_block : 
{ 
	empty_else(&$$, "EXIT_IDIF");
}
			| ELSE BEGIN_BLOCK {pushS(scopeStack, "ELSE", "");} commands END_BLOCK {popS(scopeStack);} 
{
	else_b(&$$, &$4, "EXIT_IDIF");

};


loop_block : FOR '(' initialization ';' exp ';' assign ')'
				BEGIN_BLOCK {pushS(scopeStack, "FORINIT", "");} commands END_BLOCK {popS(scopeStack);}			
{
	fr1(&$$, &$3, &$5, &$7, &$11); //$10 virou $11
}
			| FOR '(' assign ';' exp ';' assign ')'
				BEGIN_BLOCK {pushS(scopeStack, "FORASSING", "");} commands END_BLOCK {popS(scopeStack);}
{ 
	fr2(&$$, &$3, &$5, &$7, &$11); //$10 virou $11
}
			| WHILE '(' exp ')' BEGIN_BLOCK {pushS(scopeStack, "WHILE", "");} commands END_BLOCK {popS(scopeStack);}
{ 
	ctrl_b3(&$$, &$3, &$7); //$6 virou $7
}; 


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


main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK {pushS(scopeStack, "main", "");} commands END_BLOCK {popS(scopeStack);} ';'	
{ 
	m1(&$$, &$6); //$5 virou $6 
}
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

	variablesTable = createSymbolTable(TABLE_SIZE);
	functionsTable = createSymbolTable(TABLE_SIZE);
	scopeStack = newStack();

    codigo = yyparse();

    fclose(yyin);
    fclose(yyout);

	//Mostrar a tabela dde simbolos ao final, apenas para testes:
	/*
	printf("*******************************\n");
	printf("Mostrando tabela de variaveis: \n");
	printTable(variablesTable);
	printf("*******************************\n");
	printf("Mostrando tabela de funcoes: \n");
	printTable(functionsTable);
	printf("*******************************\n");
	*/

	return codigo;
}

int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}
