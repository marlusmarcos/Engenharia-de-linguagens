%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./lib/record.h"
#include "./lib/traducao_aux.h"

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


declaration_seq : declaration ';' declaration_seq 
{
	char *s = cat($1->code, ";\n", $3->code, "","");
	freeRecord($1);
	freeRecord($3);
	$$ = createRecord(s, "");
	free(s);
}
				|                                       
{
	$$ = createRecord("", "");
};


declaration : VAR id_list ':' TYPE					
{
	char *s = cat($4, " ", $2->code, "", "");
	free($4);
	freeRecord($2);
	$$ = createRecord(s, "");
	free(s);
}
			| user_def								{$$ = $1;}
			| type_def								{$$ = $1;};


id_list : ID										
{
	$$ = createRecord($1, "");
    free($1);
}
		| ID array_dim								
{
	char *s = cat($1, $2->code, "", "", "");
	free($1);
	freeRecord($2);
	$$ = createRecord(s, "");
	free(s);
}
		| ID ',' id_list							
{
	char *s = cat($1, ", ", $3->code, "","");
	free($1);
	freeRecord($3);
	$$ = createRecord(s, "");
	free(s);
}
		| ID array_dim ',' id_list					
{
	char *s = cat($1, $2->code, ", ", $4->code, "");
	$$ = createRecord(s, "");
	free($1);
	freeRecord($2);
	freeRecord($4);
	free(s);
};


initialization : VAR id_list ':' TYPE ASSIGN exp	
{
	char *s = cat($4, " ", $2->code, " = ", $6->code);
	$$ = createRecord(s, "");
	freeRecord($2);
	freeRecord($6);
	free($4);
	free(s);
};


subprograms : subprogram ';' subprograms			
{
	char *s = cat($1->code, "\n", $3->code, "","");
	$$ = createRecord(s, "");
	freeRecord($1);
	freeRecord($3);
	free(s);
}
		| 										
{
	$$ = createRecord("", "");
};


subprogram : function								{$$ = $1;} 
			| proc 									{$$ = $1;};


function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/
{
	char *s1 = cat($7, " ", $2, "(", $4->code);
	char *s2 = cat(s1, "){\n", $9->code, "}\n", "");
	$$ = createRecord(s2, "");
	freeRecord($4);
	freeRecord($9);
	free($2);
	free(s1);
	free(s2);
};
proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK /*{pilhaEscopo.push($2)}*/ commands END_BLOCK	/*{pilhaEscopo.pop()}*/					{
	char *s1 = cat("void ", $2, "(", $4->code, "");
	char *s2 = cat(s1, "){\n", $7->code, "}\n", "");
	$$ = createRecord(s2, "");
	freeRecord($4);
	freeRecord($7);
	free($2);
	free(s1);
	free(s2);
};
paramsdef : var ':' TYPE															
{
	char *s = cat($3, " ", $1->code, "", "");
	$$ = createRecord(s, "");
	freeRecord($1);
	free($3);
	free(s);
}
			| var ':' TYPE ',' paramsdef											
{
	char *s = cat($3, " ", $1->code, ", ", $5->code);
	$$ = createRecord(s, "");
	freeRecord($1);
	freeRecord($5);
	free($3);
	free(s);
}
			| 
{
	$$ = createRecord("","");
};

params : exp							{$$ = $1;}
		| exp ',' params				
{
	char *s = cat($1->code, ", ", $3->code, "", "");
	$$ = createRecord(s, "");
	freeRecord($1);
	freeRecord($3);
	free(s);
}
		| 
{
	$$ = createRecord("","");
};

func_proc_call : ID '(' params ')'		
{
	char *s = cat($1, "(", $3->code, ")", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free($1);
	free(s);
};


commands : command ';' commands		
{
	char *s = cat($1->code, ";\n", $3->code, "", "");
	freeRecord($1);
	freeRecord($3);
	$$ = createRecord(s, "");
	free(s);
}
		| 						
{
	$$ = createRecord("", "");
};


command : declaration				{$$ = createRecord($1->code, ""); freeRecord($1);}
		| assign					{$$ = createRecord($1->code, ""); freeRecord($1);}
		| initialization			{$$ = createRecord($1->code, ""); freeRecord($1);}
		| control_block				{$$ = createRecord($1->code, ""); freeRecord($1);}
		| loop_block				{$$ = createRecord($1->code, ""); freeRecord($1);}
		| func_proc_call			{$$ = createRecord($1->code, ""); freeRecord($1);}
		| BREAK						{$$ = createRecord("break", "");}
		| RETURN					{$$ = createRecord("return", "");}
		| RETURN exp				
{
	char *s = cat("return ", $2->code, "", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free(s);
}
		| CONTINUE					{$$ = createRecord("continue", "");}
		| INPUT	'(' ')'				{$$ = createRecord("scanf()", "");}
		| OUTPUT '(' exp ')'		
{
	char *s = cat("printf(", $3->code, ");", "", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free(s);
};


user_def : STRUCT ID BEGIN_BLOCK declaration_seq END_BLOCK		
{
	char *s = cat("struct", $2, "{\n", $4->code, "}");
	$$ = createRecord(s, "");
	freeRecord($4);
	free($2);
	free(s);
}
		| ENUM ID BEGIN_BLOCK enum_init END_BLOCK				
{
	char *s = cat("enum", $2, "{\n", $4->code, "}");
	$$ = createRecord(s, "");
	freeRecord($4);
	free($2);
	free(s);
};
enum_init :	ID													{$$ = createRecord($1, ""); free($1);}
			| ID ',' enum_init									
{
	char *s = cat($1, ", ", $3->code, "", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free($1);
	free(s);
}
			| ID ASSIGN NUMBER									
{
	char strNum[30];
	sprintf(strNum, "%d", $1);

	char *s = cat($1, " = ", strNum, "", "");
	$$ = createRecord(s, "");
	free($1);
	free(s);
}
			| ID ASSIGN NUMBER ',' enum_init					
{
	char strNum[30];
	sprintf(strNum, "%d", $1);

	char *s = cat($1, " = ", strNum, ", ", $5->code);
	$$ = createRecord(s, "");
	freeRecord($5);
	free($1);
	free(s);
};
type_def : TYPEDEF ID ASSIGN user_def							{
	char *s = cat("typedef", " ", $4->code, " ", $2);
	$$ = createRecord(s, "");
	freeRecord($4);
	free($2);
	free(s);
};

assign : OPC ID												
{
	char *s = cat($1, $2, "", "", "");
	$$ = createRecord(s, "");
	free($1);
	free($2);
	free(s);
}
		| ID OPC											
{
	char *s = cat($1, $2, "", "", "");
	$$ = createRecord(s, "");
	free($1);
	free($2);
	free(s);
}
		| var ASSIGN exp									
{
	char *s = cat($1->code, " = ", $3->code, "", "");
	$$ = createRecord(s, "");
	freeRecord($1);
	freeRecord($3);
	free(s);
}
		| var OPA exp										
{
	char *s = cat($1->code, " ", $2, " ", $3->code);
	$$ = createRecord(s, "");
	freeRecord($1);
	freeRecord($3);
	free($2);
	free(s);
};

		
control_block : IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK				
{
	char *s1 = cat("if (", $3->code, "){\n", $6->code, "}\n");
	$$ = createRecord(s1, "");
	freeRecord($3);
	freeRecord($6);
	free(s1);
}
				| IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK	
					ELSE BEGIN_BLOCK commands END_BLOCK			
{
	char *s1 = cat("if (", $3->code, "){\n", $6->code, "} ");
	char *s2 = cat(s1, "else", "{\n", $10->code, "}\n");
	$$ = createRecord(s2, "");
	freeRecord($3);
	freeRecord($6);
	freeRecord($10);
	free(s1);
	free(s2);
}
				| WHILE '(' exp ')' BEGIN_BLOCK commands END_BLOCK			
{
	char *s1 = cat("while (", $3->code, ") {\n", $6->code, "}\n");
	$$ = createRecord(s1, "");
	freeRecord($3);
	freeRecord($6);
	free(s1);
};


loop_block : FOR '(' initialization ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK	
{
	/*
	char *s1 = cat("for (", $3->code, "; ", $5->code, "; ");
	char *s2 = cat(s1, $7->code, ") {\n", $10->code, "}");
	$$ = createRecord(s2, "");
	freeRecord($3);
	freeRecord($5);
	freeRecord($7);
	freeRecord($10);
	free(s1);
	free(s2);
	*/
	char *s = forToGoTo($3->code, $5->code, $7->code, $10->code);
	$$ = createRecord(s, "");
	freeRecord($3);
	freeRecord($5);
	freeRecord($7);
	freeRecord($10);
	free(s);

}
			| FOR '(' assign ';' exp ';' assign ')'
				BEGIN_BLOCK commands END_BLOCK	
{
	char *s1 = cat("for (", $3->code, "; ", $5->code, "; ");
	char *s2 = cat(s1, $7->code, ") {\n", $10->code, "}");
	$$ = createRecord(s2, "");
	freeRecord($3);
	freeRecord($5);
	freeRecord($7);
	freeRecord($10);
	free(s1);
	free(s2);
};


exp : term								
{
	$$ = createRecord($1->code, "");
	free($1);
}
	| exp WEAK_OP term					
{
	char *s = cat($1->code, $2, $3->code, "", "");
	freeRecord($1);
	freeRecord($3);
	free($2);
	$$ = createRecord(s, "");
	free(s);
};


term : factor							
{
	$$ = createRecord($1->code, "");
	free($1);
}
		| term STRONG_OP factor			
{
	char *s = cat($1->code, $2, $3->code, "", "");
	freeRecord($1);
	freeRecord($3);
	free($2);
	$$ = createRecord(s, "");
	free(s);
};


factor : var							{$$ = $1;}
		| STR_LITERAL					{$$ = createRecord($1, ""); free($1);}
		| NUMBER						
{
	char strNum[30];
	sprintf(strNum, "%d", $1);

	$$ = createRecord(strNum, "");
}
		| REAL							
{
	char strNum[30];
	sprintf(strNum, "%f", $1);

	$$ = createRecord(strNum, "");
}
		| func_proc_call				{$$ = createRecord($1->code, ""); freeRecord($1);}
		| '(' exp ')'					
{
	char *s = cat("(", $2->code, ")", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free(s);
}
		| WEAK_OP factor				
{
	char *s = cat($1, $2->code, "", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free($1);
	free(s);
}
		| TRUE							{$$ = createRecord("true", "");}
		| FALSE							{$$ = createRecord("false", "");}
		| NOT factor					
{
	char *s = cat("!", $2->code, "", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free(s);
}
		| LENGTH '(' factor ')'			
{
	char *s = cat("auxLength(", $3->code, ")", "", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free(s);
};

var : ID								{$$ = createRecord($1, ""); free($1);}
	| ID array_dim						
{
	char *s = cat($1, $2->code, "", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free($1);
	free(s);
}
	| ID '.' var						
{
	char *s = cat($1, ".", $3->code, "", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free($1);
	free(s);
};
array_dim : '[' ']'						{$$ = createRecord("[]", "");}
			| '[' ']' array_dim			
{
	char *s = cat("[]", $3->code, "", "", "");
	$$ = createRecord(s, "");
	freeRecord($3);
	free(s);
}
			| '[' exp ']'				
{
	char *s = cat("[", $2->code, "]", "", "");
	$$ = createRecord(s, "");
	freeRecord($2);
	free(s);
}
			| '[' exp ']' array_dim		
{
	char *s = cat("[", $2->code, "]", $4->code, "");
	$$ = createRecord(s, "");
	freeRecord($2);
	freeRecord($4);
	free(s);
};


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
