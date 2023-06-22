%{
#include <stdio.h>
#include "./lib/record.h"

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;
extern FILE * yyin, * yyout;

char * cat(char *, char *, char *, char *, char *);

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

%type <rec> main_seq command commands id_list declaration_seq subprograms declaration subprogram

%start prog

%%
prog : declaration_seq subprograms main_seq {
												fprintf(yyout, "%s\n%s\n%s", $1->code, $2->code, $3->code);
												freeRecord($1);
												freeRecord($2);
												freeRecord($3);
											}
	 ;


declaration_seq : declaration ';' declaration_seq		{
															char *s = cat($1, ", ", $3->code, "","");
															free($1);
															freeRecord($3);
															$$ = createRecord(s, "");
															free(s);
														}
				|                                       {
															$$ = createRecord("", "");
														}
				;

declaration : VAR id_list ':' TYPE					{}
			| user_def								{}
			| type_def								{};

id_list : ID										{
														$$ = createRecord($1, "");
														free($1);
													}
		| ID array_dim								{}
		| ID ',' id_list							{
														char *s = cat($1, ", ", $3->code, "","");
														free($1);
														freeRecord($3);
														$$ = createRecord(s, "");
														free(s);
													}
		| ID array_dim ',' id_list					{};
initialization : VAR id_list ':' TYPE ASSIGN exp	{};


subprograms : subprogram ';' subprograms			{
														char *s = cat($1->code, "\n", $3->code, "","");
														freeRecord($1);
														freeRecord($3);
														$$ = createRecord(s, "");
														free(s);
													}
			| 										{
														$$ = createRecord("", "");
													}
			;
subprogram : function								{} 
			| proc 									{};


function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/{};
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/					{};
paramsdef : var ':' TYPE															{}
			| var ':' TYPE ',' paramsdef											{}
			| ;
params : exp							{}
		| exp ',' params				{}
		| ;
func_proc_call : ID '(' params ')'		{};


commands : command ';' commands		{
										char *s = cat($1->code, "\n", $3->code, "", "");
										freeRecord($1);
										freeRecord($3);
										$$ = createRecord(s, "");
										free(s);
									}
			| 						{
										$$ = createRecord("", "");
									};
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
		| ENUM ID BEGIN_BLOCK enum_init END_BLOCK				{};
enum_init :	ID													{}
			| ID ',' enum_init									{}
			| ID id_list ASSIGN NUMBER							{}
			| ID id_list ASSIGN NUMBER ',' enum_init			{};
type_def : TYPEDEF ID ASSIGN user_def							{};

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

main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK commands END_BLOCK ';'		{
																			char *s = cat("int main() {\n", $5->code, "}", "", "");
																			freeRecord($5);
																			$$ = createRecord(s, "");
																			free(s);
																		}
		| {
			$$ = createRecord("", "");
		  };
%%

/*
int main (void) {
	return yyparse ( );
}
*/

/*
int yyerror (char *msg) {
	fprintf (stderr, "%d: %s at '%s'\n", yylineno, msg, yytext);
	return 0;
}
*/


/*Funções Auxiliares*/

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

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5){
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}
