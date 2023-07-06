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
void insertFunctionParam(char *, char *, char *);
int countFuncCallParams;

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
%type <rec> user_def type_def array_dim function proc paramsdef params func_proc_call assign control_block loop_block enum_init else_block varDef
%start prog

%%
prog : {pushS(scopeStack, "global", "");} declaration_seq subprograms main_seq
{
	popS(scopeStack);
	fprintf(yyout, "#include <stdio.h>\n%s\n%s\n%s", $2->code, $3->code, $4->code); //$1 virou $2 e incrementou 1 em todos.
	freeRecord($2);
	freeRecord($3);
	freeRecord($4);
};


declaration_seq : declaration ';' declaration_seq	{ dec_seq1(&$$, &$1, &$3); }
				|									{ dec_seq2(&$$);};


declaration : VAR id_list ':' TYPE					
{
	// Separando o id da variável dos []
	char strToSlice[100];
	strcpy(strToSlice, $2->code);
	char* tokenSliced = strtok(strToSlice, "[");

	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp,"#",tokenSliced,"",""), tokenSliced, $4);
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


function : FUNCTION ID {pushS(scopeStack, $2, "");} '(' paramsdef ')' ':' TYPE BEGIN_BLOCK commands END_BLOCK
{ 
	vatt *tmp = peekS(scopeStack);
	insert(functionsTable, cat(tmp->subp, "#r","","",""), "return", $8);
	func1(&$$, &$2, &$5, &$8, &$10);  //Prestar atençaõ aqui, o $9 virou $10, 4->5, 7, 8;
	popS(scopeStack);
};
proc : PROC ID {pushS(scopeStack, $2, "");} '(' paramsdef ')' BEGIN_BLOCK commands END_BLOCK
{ 
	proc1(&$$, &$2, &$5, &$8); //Prestar atençaõ aqui, $4->$5 o $7 virou $8;
	popS(scopeStack);
}; 
paramsdef : varDef ':' TYPE							
{
	char strToSlice[100];
	strcpy(strToSlice, $1->code);
	char* tokenSliced = strtok(strToSlice, "[");

	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", tokenSliced,"",""), tokenSliced, $3);
	insertFunctionParam(tmp->subp, tokenSliced, $3);
	pard1(&$$, &$1, &$3); 
}
			| varDef ':' TYPE ',' paramsdef			
{
	char strToSlice[100];
	strcpy(strToSlice, $1->code);
	char* tokenSliced = strtok(strToSlice, "[");

	vatt *tmp = peekS(scopeStack);
	insert(variablesTable, cat(tmp->subp, "#", tokenSliced,"",""), tokenSliced, $3);
	insertFunctionParam(tmp->subp, tokenSliced, $3);
	pard2(&$$, &$1, &$3, &$5);
}
			| 										{ pard3(&$$); };

params : exp							
			{
				char strP[30];
				sprintf(strP, "%d", countFuncCallParams);
				vatt *tmp = peekS(scopeStack);
				SymbolInfos *declaredFunParam = lookup(functionsTable, cat(tmp->subp,"#p",strP,"",""));
				
				int intfloat = !(strcmp(declaredFunParam->type, "int") || strcmp($1->opt1, "float"));
				int floatint = !(strcmp(declaredFunParam->type, "float") || strcmp($1->opt1, "int"));

				if((0 == strcmp(declaredFunParam->type, $1->opt1)) || intfloat || floatint){
					par1(&$$, &$1);
				} else {
					yyerror(cat("Expected type ", declaredFunParam->type, " and actual ", $1->opt1, " are incompatible!"));
				}

				countFuncCallParams++;
			}
		| exp ',' params				
			{ 
				char strP[30];
				sprintf(strP, "%d", countFuncCallParams);
				vatt *tmp = peekS(scopeStack);
				SymbolInfos *declaredFunParam = lookup(functionsTable, cat(tmp->subp,"#p",strP,"",""));
				
				int intfloat = !(strcmp(declaredFunParam->type, "int") || strcmp($1->opt1, "float"));
				int floatint = !(strcmp(declaredFunParam->type, "float") || strcmp($1->opt1, "int"));

				if((0 == strcmp(declaredFunParam->type, $1->opt1)) || intfloat || floatint){
					par2(&$$, &$1, &$3);
				} else {
					yyerror(cat("Expected type ", declaredFunParam->type, " and actual ", $1->opt1, " are incompatible!"));
				}

				countFuncCallParams++;
			}
		| 								{ par3(&$$); };

func_proc_call : ID {pushS(scopeStack, $1, "");} '(' params ')'		
					{
						vatt *tmp = peekS(scopeStack);
						f_proc_c1(&$$, &$1, &$4);
						popS(scopeStack);
						countFuncCallParams = 0;
					};


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
		| INPUT	'(' STR_LITERAL ',' exp ')'			{ comd11(&$$, &$3, &$5); }
		| OUTPUT '(' STR_LITERAL ',' exp ')'		{ comd12(&$$, &$3, &$5); };


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

		
control_block : IF '(' exp ')' BEGIN_BLOCK {pushS(scopeStack, cat("IF#",getBlockID(),"","",""), ""); incBlockID();} commands END_BLOCK else_block //Aqui talvez precise mudar e guardar o id do if.
{
	popS(scopeStack);
	ctrl_b1(&$$, &$3, &$7, &$9, cat("ELSE_",getBlockID(),"","","")); incBlockID(); //nessa parte, irei passar o id do if como parametro para a tradução.
};
				

else_block : 
{ 
	empty_else(&$$, cat("ELSE_",getBlockID(),"","","")); incBlockID();
}
			| ELSE BEGIN_BLOCK {pushS(scopeStack, cat("ELSE#",getBlockID(),"","",""), ""); incBlockID();} commands END_BLOCK
{
	popS(scopeStack);
	else_b(&$$, &$4, cat("ELSE",getBlockID(),"","","")); incBlockID();

};


loop_block : FOR '(' initialization ';' exp ';' assign ')'
				BEGIN_BLOCK {pushS(scopeStack, cat("FORINIT_",getBlockID(),"","",""), ""); incBlockID();} commands END_BLOCK {popS(scopeStack);}			
{
	fr1(&$$, &$3, &$5, &$7, &$11, cat("FORINIT_",getBlockID(),"","","")); //$10 virou $11
}
			| FOR '(' assign ';' exp ';' assign ')'
				BEGIN_BLOCK {pushS(scopeStack, cat("FORASSING_",getBlockID(),"","",""), ""); incBlockID();} commands END_BLOCK {popS(scopeStack);}
{ 
	fr2(&$$, &$3, &$5, &$7, &$11, cat("FORINIT_",getBlockID(),"","","")); //$10 virou $11
}
			| WHILE '(' exp ')' BEGIN_BLOCK {pushS(scopeStack, cat("WHILE_",getBlockID(),"","",""), ""); incBlockID();} commands END_BLOCK {popS(scopeStack);}
{ 
	ctrl_b3(&$$, &$3, &$7, cat("WHILE_",getBlockID(),"","","")); //$6 virou $7
}; 


exp : term							{ ex1(&$$, &$1); }
	| exp WEAK_OP term				
		{ 
			int intfloat = !(strcmp($1->opt1, "int") || strcmp($3->opt1, "float"));
			int floatint = !(strcmp($1->opt1, "float") || strcmp($3->opt1, "int"));

			if((0 == strcmp($1->opt1, $3->opt1)) || intfloat || floatint){
				char inType[100];
				strcpy(inType, $3->opt1);
				ex2(&$$, &$1, &$2, &$3, inType);
			} else {
				yyerror(cat("Types ", $1->opt1, " and ", $3->opt1, " are incompatible!"));
			}
		};


term : factor						{ te1(&$$, &$1); }
		| term STRONG_OP factor		
			{
				int intfloat = !(strcmp($1->opt1, "int") || strcmp($3->opt1, "float"));
				int floatint = !(strcmp($1->opt1, "float") || strcmp($3->opt1, "int"));

				if((0 == strcmp($1->opt1, $3->opt1)) || intfloat || floatint){
					char inType[100];
					strcpy(inType, $3->opt1);
					te2(&$$, &$1, &$2, &$3, inType);
				} else {
					yyerror(cat("Types ", $1->opt1, " and ", $3->opt1, " are incompatible!"));
				}
			};


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

var : ID								
		{
			int stop = 0;
			int top = scopeStack->top;
			vatt *stmp = peekS(scopeStack);
			while(!stop){
				if(lookup(variablesTable, cat(stmp->subp,"#",$1,"",""))){
					stop = 1;
				} else{
					if(top>0){
						top--;
						stmp = stmp->next;
					} else {
						yyerror(cat($1," undefined variable","","",""));
						stop = 1;
					}
				}
			};

			SymbolInfos *foundVar = lookup(variablesTable, cat(stmp->subp,"#",$1,"",""));
			v1(&$$, &$1, &foundVar->type);
			/*printf("TYPE UP %s %s\n", foundVar->name, foundVar->type);*/
		}
	| ID array_dim						
		{ 
			int stop = 0;
			int top = scopeStack->top;
			vatt *stmp = peekS(scopeStack);
			while(!stop){
				if(lookup(variablesTable, cat(stmp->subp,"#",$1,"",""))){
					stop = 1;
				} else{
					if(top>0){
						top--;
						stmp = stmp->next;
					} else {
						yyerror(cat($1," undefined variable","","",""));
						stop = 1;
					}
				}
			};

			SymbolInfos *foundVar = lookup(variablesTable, cat(stmp->subp,"#",$1,"",""));
			v2(&$$, &$1, &$2, &foundVar->type);
		}
	| ID '.' var						
		{
			int stop = 0;
			int top = scopeStack->top;
			vatt *stmp = peekS(scopeStack);
			while(!stop){
				if(lookup(variablesTable, cat(stmp->subp,"#",$1,"",""))){
					stop = 1;
				} else{
					if(top>0){
						top--;
						stmp = stmp->next;
					} else {
						yyerror(cat($1," undefined variable","","",""));
						stop = 1;
					}
				}
			};

			v3(&$$, &$1, &$3);
		};
	| ID '-''>' var					
		{
			int stop = 0;
			int top = scopeStack->top;
			vatt *stmp = peekS(scopeStack);
			while(!stop){
				if(lookup(variablesTable, cat(stmp->subp,"#",$1,"",""))){
					stop = 1;
				} else{
					if(top>0){
						top--;
						stmp = stmp->next;
					} else {
						yyerror(cat($1," undefined variable","","",""));
						stop = 1;
					}
				}
			};
			v4(&$$, &$1, &$4); 
		}
	| STRONG_OP var						{ v5(&$$, &$2); }
	| '&' var						{ v6(&$$, &$2); };
varDef : ID								{ vd1(&$$, &$1); }
	| ID array_dim						{ vd2(&$$, &$1, &$2); }
	| ID '.' varDef						{ vd3(&$$, &$1, &$3); }
	| ID '-''>' varDef					{ vd4(&$$, &$1, &$4); }
	| STRONG_OP varDef					{ vd5(&$$, &$2); }
	| '&' varDef						{ vd6(&$$, &$2); };
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
	countFuncCallParams = 0;

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

void insertFunctionParam(char *functionId, char *paramName, char *paramType){
	int paramId = 0; 
	char strNum[30];

	do {
		sprintf(strNum, "%d", paramId);
		paramId++;
	} while(lookup(functionsTable, cat(functionId,"#p",strNum,"","")));

	insert(functionsTable, cat(functionId,"#p",strNum,"",""), paramName, paramType);
}