#include "semantics.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "record.h"
#include "traducao_aux.h"

/*prog : declaration_seq subprograms main_seq
void prog1(FILE *yyout, record *ss, record *s1, record *s2, record *s3) {
	fprintf(yyout, "%s\n%s\n%s", $1->code, $2->code, $3->code);
	freeRecord($1);
	freeRecord($2);
	freeRecord($3);
};*/


//declaration_seq : declaration ';' declaration_seq
void dec_seq1(record **ss, record **s1, record **s3) {
	char *str = cat((*s1)->code, ";\n", (*s3)->code, "","");
	freeRecord(*s1);
	freeRecord(*s3);
	*ss = createRecord(str, "");
	free(str);
}

// | empty rule                                       
void dec_seq2(record **ss){
	*ss = createRecord("", "");
};


//declaration : VAR id_list ':' TYPE				
void dec1(record **ss, record **s2, char **s4) {
	char *str;

	if(0 == strcmp(*s4, "string")){
		str = cat("char *", " ", (*s2)->code, "", "");
	} else if (0 == strcmp(*s4, "boolean")){
		str = cat("int", " ", (*s2)->code, "", "");
	} else {
		str = cat(*s4, " ", (*s2)->code, "", "");
	}
	*ss = createRecord(str, *s4);
	free(*s4);
	freeRecord(*s2);
	free(str);
}
// | user_def
void dec2(record **ss, record **s1){
    *ss = *s1;
	free(*s1);
	free(s1);
}
// | type_def
void dec3(record **ss, record **s1){
    *ss = *s1;
};


//id_list : ID
void id_l1(record **ss, char **s1){
	*ss = createRecord(*s1, "");
    free(*s1);
}
// | ID array_dim
void id_l2(record **ss, char **s1, record **s2) {
	char *str = cat(*s1, (*s2)->code, "", "", "");
	free(*s1);
	freeRecord(*s2);
	*ss = createRecord(str, "");
	free(str);
}
// | ID ',' id_list
void id_l3(record **ss, char **s1, record **s3) {
	char *str = cat(*s1, ", ", (*s3)->code, "","");
	free(*s1);
	freeRecord(*s3);
	*ss = createRecord(str, "");
	free(str);
}
// | ID array_dim ',' id_list
void id_l4(record **ss, char **s1, record **s2, record **s4) {
	char *str = cat(*s1, (*s2)->code, ", ", (*s4)->code, "");
	*ss = createRecord(str, "");
	free(*s1);
	freeRecord(*s2);
	freeRecord(*s4);
	free(str);
};

//initialization : VAR id_list ':' TYPE ASSIGN exp
void init1(record **ss, record **s2, char **s4, record **s6) {
	char *str;

	if(0 == strcmp(*s4, "string")){
		str = cat("char *", " ", (*s2)->code, " = ", (*s6)->code);
	} else if (0 == strcmp(*s4, "boolean")){
		str = cat("int", " ", (*s2)->code, " = ", (*s6)->code);
	} else {
		str = cat(*s4, " ", (*s2)->code, " = ", (*s6)->code);
	}
	*ss = createRecord(str, *s4);
	freeRecord(*s2);
	freeRecord(*s6);
	free(*s4);
	free(str);
};


//subprograms : subprogram ';' subprograms
void subprogs1(record **ss, record **s1, record **s3) {
	char *str = cat((*s1)->code, ";\n", (*s3)->code, "","");
	*ss = createRecord(str, "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(str);
}
// | empty rule
void subprogs2(record **ss) {
	*ss = createRecord("", "");
};


//subprogram : function
void subprog1(record **ss, record **s1) {
    *ss = *s1;
}
// | proc
void subprog2(record **ss, record **s1) {
    *ss = *s1;
};


//function : FUNCTION ID '(' paramsdef ')' ':' TYPE BEGIN_BLOCK /{pilhaEscopo.push(s2)}/ commands END_BLOCK	/{pilhaEscopo.pop()}/
void func1(record **ss, char **s2, record **s4, char **s7, record **s9) {
	char *str1;

	if(0 == strcmp(*s7, "string")){
		str1 = cat("char *", " ", *s2, "(", (*s4)->code);
	} else if (0 == strcmp(*s7, "boolean")){
		str1 = cat("int", " ", *s2, "(", (*s4)->code);
	} else {
		str1 = cat(*s7, " ", *s2, "(", (*s4)->code);
	}
	char *str2 = cat(str1, "){\n", (*s9)->code, "}", "");
	*ss = createRecord(str2, "");
	freeRecord(*s4);
	freeRecord(*s9);
	//free(*s2);
    free(*s7);
	free(str1);
	free(str2);
};

//proc : PROC ID '(' paramsdef ')' BEGIN_BLOCK /{pilhaEscopo.push(s2)}/ commands END_BLOCK	/{pilhaEscopo.pop()}/
void proc1(record **ss, char **s2, record **s4, record **s7) {
	char *str1 = cat("void ", *s2, "(", (*s4)->code, "");
	char *str2 = cat(str2, "){\n", (*s7)->code, "}", "");
	*ss = createRecord(str2, "");
	freeRecord(*s4);
	freeRecord(*s7);
	//free(*s2);
	free(str1);
	free(str2);
};
//paramsdef : var ':' TYPE
void pard1(record **ss, record **s1, char **s3) {
	char *str;

	if(0 == strcmp(*s3, "string")){
		str = cat("char *", " ", (*s1)->code, "", "");
	} else if (0 == strcmp(*s3, "boolean")){
		str = cat("int", " ", (*s1)->code, "", "");
	} else {
		str = cat(*s3, " ", (*s1)->code, "", "");
	}
	*ss = createRecord(str, "");
	freeRecord(*s1);
	free(*s3);
	free(str);
};
// | var ':' TYPE ',' paramsdef	
void pard2(record **ss, record **s1, char **s3, record **s5) {
	char *str;

	if(0 == strcmp(*s3, "string")){
		str = cat("char *", " ", (*s1)->code, ", ", (*s5)->code);
	} else if (0 == strcmp(*s3, "boolean")){
		str = cat("int", " ", (*s1)->code, ", ", (*s5)->code);
	} else {
		str = cat(*s3, " ", (*s1)->code, ", ", (*s5)->code);
	}
	*ss = createRecord(str, "");
	freeRecord(*s1);
	freeRecord(*s5);
	free(*s3);
	free(str);
}
// | empty rule
void pard3(record **ss) {
	*ss = createRecord("","");
};

//params : exp
void par1(record **ss, record **s1) {
    *ss = *s1;
}
// | exp ',' params
void par2(record **ss, record **s1, record **s3) {
	char *str = cat((*s1)->code, ", ", (*s3)->code, "", "");
	*ss = createRecord(str, "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(str);
}
// | empty rule 
void par3(record **ss) {
	*ss = createRecord("","");
};

//func_proc_call : ID '(' params ')'
void f_proc_c1(record **ss, char **s1, record **s3) {
	char *str = cat(*s1, "(", (*s3)->code, ")", "");
	*ss = createRecord(str, "");
	freeRecord(*s3);
	//free(*s1);
	free(str);
};


//commands : command ';' commands
void comds1(record **ss, record **s1, record **s3) {
	char *str = cat((*s1)->code, ";\n", (*s3)->code, "", "");
	freeRecord(*s1);
	freeRecord(*s3);
	*ss = createRecord(str, "");
	free(str);
}
// | empty rule
void comds2(record **ss) {
	*ss = createRecord("", "");
};


//command : declaration
void comd1(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | assign
void comd2(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | initialization
void comd3(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | control_block
void comd4(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | loop_block
void comd5(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | func_proc_call
void comd6(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
//| BREAK
void comd7(record **ss) {
    *ss = createRecord("break", "");
}
//| RETURN
void comd8(record **ss) {
    *ss = createRecord("return", "");
}
// | RETURN exp				
void comd9(record **ss, record **s2) {
	char *str = cat("return ", (*s2)->code, "", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	free(str);
}
// | CONTINUE
void comd10(record **ss) {
    *ss = createRecord("continue", "");
}
// | INPUT	'(' STR_LITERAL ',' exp ')'	
void comd11(record **ss, char **s3, record **s5) {
	char *str = cat("scanf(", *s3, ",", (*s5)->code, ")");
    *ss = createRecord(str, "");
	free(str);
	free(*s3);
	freeRecord(*s5);
}
// | OUTPUT	'(' STR_LITERAL ',' exp ')'	
void comd12(record **ss, char **s3, record**s5) {
	char *str = cat("printf(", *s3, ",", (*s5)->code, ")");
	*ss = createRecord(str, "");
	free(*s3);
	freeRecord(*s5);
	free(str);
};


//user_def : STRUCT ID BEGIN_BLOCK declaration_seq END_BLOCK		
void u_d1(record **ss, char **s2, record **s4) {
	char *str = cat("struct", *s2, "{\n", (*s4)->code, "}");
	*ss = createRecord(str, "");
	freeRecord(*s4);
	//free(*s2);
	free(str);
}
// | ENUM ID BEGIN_BLOCK enum_init END_BLOCK				
void u_d2(record **ss, char **s2, record **s4) {
	char *str = cat("enum", *s2, "{\n", (*s4)->code, "}");
	*ss = createRecord(str, "");
	freeRecord(*s4);
	//free(*s2);
	free(str);
};
//enum_init :	ID
void enum_i1(record **ss, char **s1) {
    *ss = createRecord(*s1, "");
    free(*s1);
}
// | ID ',' enum_init									
void enum_i2(record **ss, char **s1, record **s3) {
	char *str = cat(*s1, ", ", (*s3)->code, "", "");
	*ss = createRecord(str, "");
	freeRecord(*s3);
	free(*s1);
	free(str);
}
// | ID ASSIGN NUMBER									
void enum_i3(record **ss, char **s1, int *s3) {
	char strNum[30];
	sprintf(strNum, "%d", *s3);

	char *str = cat(*s1, " = ", strNum, "", "");
	*ss = createRecord(str, "");
	free(*s1);
	free(str);
}
// | ID ASSIGN NUMBER ',' enum_init					
void enum_i4(record **ss, char **s1, int *s3, record **s5) {
	char strNum[30];
	sprintf(strNum, "%d", *s3);

	char *str = cat(*s1, " = ", strNum, ", ", (*s5)->code);
	*ss = createRecord(str, "");
	freeRecord(*s5);
	free(*s1);
	free(str);
};
// type_def : TYPEDEF ID ASSIGN user_def
void ty_d1(record **ss, char **s2, record **s4) {
	char *str = cat("typedef", " ", (*s4)->code, " ", *s2);
	*ss = createRecord(str, "");
	freeRecord(*s4);
	free(*s2);
	free(str);
};

//assign : OPC ID
void asg1(record **ss, char **s1, char **s2) {
	char *str = cat(*s1, *s2, "", "", "");
	*ss = createRecord(str, "");
	free(*s1);
	free(*s2);
	free(str);
}
// | ID OPC
void asg2(record **ss, char **s1, char **s2) {
	char *str = cat(*s1, *s2, "", "", "");
	*ss = createRecord(str, "");
	free(*s1);
	free(*s2);
	free(str);
}
// | var ASSIGN exp
void asg3(record **ss, record **s1, record **s3) {
	char *str = cat((*s1)->code, " = ", (*s3)->code, "", "");
	*ss = createRecord(str, "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(str);
}
// | var OPA exp										
void asg4(record **ss, record **s1, char **s2, record **s3) {
	char *str = cat((*s1)->code, " ", (*s2), " ", (*s3)->code);
	*ss = createRecord(str, "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(*s2);
	free(str);
};

		
//control_block : IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK				
void ctrl_b1(record **ss, record **exp, record **commands, record **elseBlock, char *ifId) {
	char *str1 = cat("if (", (*exp)->code, "){\n", (*commands)->code, "goto ");
	char *str2 = cat(str1, ifId, ";\n}\n", (*elseBlock)->code, "");
	//char *str2 = cat(str1, "goto ", ifId, ";\n", (*elseBlock)->code);
	*ss = createRecord(str2, "");
	freeRecord(*exp);
	freeRecord(*commands);
	free(str1);
	free(str2);
}


// else_block : 
void empty_else(record **ss, char *ifId) {
	char *str = cat(ifId, ":\n", "", "", "");
	*ss = createRecord(str, "");
	free(str);
}

// else_block : ELSE BEGIN_BLOCK commands END_BLOCK
void else_b(record **ss, record **commands, char *ifId) {
	char *str = cat("{\n", ifId, ":\n", (*commands)->code, "};\n");
	*ss = createRecord(str, "");
	freeRecord(*commands);
	free(str);
}


// | IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK	
//					ELSE BEGIN_BLOCK commands END_BLOCK
void ctrl_b2(record **ss, record **s3, record **s6, record **s10) { // Esta função não está em uso
	char *blockPrefix = cat("Prefix", "_", "", "", "");  //Aqui iremos adicionar o identificador unico seguido de um _
	char *str1 = cat("if (", (*s3)->code, "){\n", "goto ", blockPrefix);
	char *str2 = cat(str1, "IF_BLOCK;\n}\ngoto ", blockPrefix, "ELSE_BLOCK;\n{\n", blockPrefix);
	char *str3 = cat(str2, "IF_BLOCK:\n", (*s6)->code, "goto ", blockPrefix);
	char *str4 = cat(str3, "EXIT_BLOCK;\n}\n{\n", blockPrefix, "ELSE_BLOCK:\n", (*s10)->code);
	char *str5 = cat(str4, "\n}\n", blockPrefix, "EXIT_BLOCK:", "\n");
	*ss = createRecord(str5, "");
	freeRecord(*s3);
	freeRecord(*s6);
	freeRecord(*s10);
	free(blockPrefix);
	free(str1);
	free(str2);
	free(str3);
	free(str4);
	free(str5);
}





// | WHILE '(' exp ')' BEGIN_BLOCK commands END_BLOCK			
void ctrl_b3(record **ss, record **s3, record **s6, char *whileId) {
	//char *blockPrefix = cat("Prefix", "_", "", "", "");
	char *str1 = cat("{\n", whileId, ":\n", "if(", (*s3)->code);
	char *str2 = cat(str1, "){\n", (*s6)->code, "goto ", whileId);
	char *str3 = cat(str2, ";\n}\n}", "", "", "");
	*ss = createRecord(str3, "");
	freeRecord(*s3);
	freeRecord(*s6);
	free(whileId);
	free(str1);
	free(str2);
	free(str3);
};


//loop_block : FOR '(' initialization ';' exp ';' assign ')'
//				BEGIN_BLOCK commands END_BLOCK
void fr1(record **ss, record **s3, record **s5, record **s7, record **s10, char *forId) {
	//char *blockPrefix = cat("Prefix", "_", "", "", "");  //Aqui iremos adicionar o identificador unico seguido de um _
	char *str1 = cat("{\n", (*s3)->code, ";\n", forId, ":\n");
	char *str2 = cat(str1, "if(", (*s5)->code, ") {\n", (*s10)->code);
	char *str3 = cat(str2, (*s7)->code, ";\ngoto ", forId, ";\n}\n}");
	*ss = createRecord(str3, "");
	freeRecord(*s3);
	freeRecord(*s5);
	freeRecord(*s7);
	freeRecord(*s10);
	free(forId);
	free(str1);
	free(str2);
	free(str3);
}
// | FOR '(' assign ';' exp ';' assign ')'
//				BEGIN_BLOCK commands END_BLOCK
void fr2(record **ss, record **s3, record **s5, record **s7, record **s10, char *forId) {
	//char *blockPrefix = cat("Prefix", "_", "", "", "");  //Aqui iremos adicionar o identificador unico seguido de um _
	char *str1 = cat("{\n", (*s3)->code, ";\n", forId, ":\n");;
	char *str2 = cat(str1, "if(", (*s5)->code, ") {\n", (*s10)->code);
	char *str3 = cat(str2, (*s7)->code, ";\ngoto ", forId, ";\n}\n}");
	*ss = createRecord(str3, "");
	freeRecord(*s3);
	freeRecord(*s5);
	freeRecord(*s7);
	freeRecord(*s10);
	free(str1);
	free(str2);
	free(str3);
};


//exp : term
void ex1(record **ss, record **s1) {
	*ss = createRecord((*s1)->code, (*s1)->opt1);
	freeRecord(*s1);
}
// | exp WEAK_OP term
void ex2(record **ss, record **s1, char **s2, record **s3, char *type) {
	char *str = cat((*s1)->code, (*s2), (*s3)->code, "", "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(*s2);
	*ss = createRecord(str, type);
	free(str);
};


//term : factor
void te1(record **ss, record **s1) {
	*ss = createRecord((*s1)->code, (*s1)->opt1);
	free(*s1);
}
// | term STRONG_OP factor
void te2(record **ss, record **s1, char **s2, record **s3, char *type) {
	char *str = cat((*s1)->code, *s2, (*s3)->code, "", "");
	freeRecord(*s1);
	freeRecord(*s3);
	free(*s2);
	*ss = createRecord(str, type);
	free(str);
};


//factor : var
void fac1(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, (*s1)->opt1);
    freeRecord(*s1);
}
//| STR_LITERAL
void fac2(record **ss, char **s1) {
    *ss = createRecord(*s1, "string");
    free(*s1);
}
//| NUMBER						
void fac3(record **ss, int *s1)  {
	char strNum[30];
	sprintf(strNum, "%d", *s1);

	*ss = createRecord(strNum, "int");
}
// | REAL							
void fac4(record **ss, float *s1) {
	char strNum[30];
	sprintf(strNum, "%f", *s1);

	*ss = createRecord(strNum, "float");
}
// | func_proc_call
void fac5(record **ss, record **s1) {
    *ss = createRecord((*s1)->code, "");
    freeRecord(*s1);
}
// | '(' exp ')'
void fac6(record **ss, record **s2) {
	char *str = cat("(", (*s2)->code, ")", "", "");
	*ss = createRecord(str, (*s2)->opt1);
	freeRecord(*s2);
	free(str);
}
// | WEAK_OP factor				
void fac7(record **ss, char **s1, record **s2) {
	char *str = cat(*s1, (*s2)->code, "", "", "");
	*ss = createRecord(str, (*s2)->code);
	freeRecord(*s2);
	free(*s1);
	free(str);
}
//| TRUE
void fac8(record **ss) {
    *ss = createRecord("1", "boolean");
}
// | FALSE
void fac9(record **ss) {
    *ss = createRecord("0", "boolean");
}
//| NOT factor					
void fac10(record **ss, record **s2) {
	char *str = cat("!", (*s2)->code, "", "", "");
	*ss = createRecord(str, "boolean");
	freeRecord(*s2);
	free(str);
}
//| LENGTH '(' factor ')'			
void fac11(record **ss, record **s3) {
	char *str = cat("sizeof(", (*s3)->code, ")", "", "");
	*ss = createRecord(str, "int");
	freeRecord(*s3);
	free(str);
};

//var : ID 
void v1(record **ss, char **s1, char **type) {
    *ss = createRecord(*s1, *type);
	free(*s1);
}
// | ID array_dim						
void v2(record **ss, char **s1, record **s2, char **type) {
	char *str = cat(*s1, (*s2)->code, "", "", "");
	*ss = createRecord(str, *type);
	freeRecord(*s2);
	free(*s1);
	free(str);
}
// | ID '.' var						
void v3(record **ss, char **s1, record **s3) {
	char *str = cat(*s1, ".", (*s3)->code, "", "");
	*ss = createRecord(str, (*s3)->opt1);
	freeRecord(*s3);
	free(*s1);
	free(str);
};
// | ID '->' var
void v4(record **ss, char **s1, record **s3){
	char *str = cat(*s1, "->", (*s3)->code, "", "");
	*ss = createRecord(str, (*s3)->opt1);
	freeRecord(*s3);
	free(*s1);
	free(str);
};
// | '*' var
void v5(record **ss, record **s2){
	char *str = cat("*", (*s2)->code, "", "", "");
	*ss = createRecord(str, (*s2)->opt1);
	freeRecord(*s2);
	free(str);
};
// | '&' var
void v6(record **ss, record **s2){
	char *str = cat("&", (*s2)->code, "", "", "");
	*ss = createRecord(str, (*s2)->opt1);
	freeRecord(*s2);
	free(str);
};

//varDef : ID 
void vd1(record **ss, char **s1) {
    *ss = createRecord(*s1, "");
	free(*s1);
}
// | ID array_dim						
void vd2(record **ss, char **s1, record **s2) {
	char *str = cat(*s1, (*s2)->code, "", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	free(*s1);
	free(str);
}
// | ID '.' varDef						
void vd3(record **ss, char **s1, record **s3) {
	char *str = cat(*s1, ".", (*s3)->code, "", "");
	*ss = createRecord(str, "");
	freeRecord(*s3);
	free(*s1);
	free(str);
};
// | ID '->' varDef
void vd4(record **ss, char **s1, record **s3){
	char *str = cat(*s1, "->", (*s3)->code, "", "");
	*ss = createRecord(str, "");
	freeRecord(*s3);
	free(*s1);
	free(str);
};
// | '*' varDef
void vd5(record **ss, record **s2){
	char *str = cat("*", (*s2)->code, "", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	free(str);
};
// | '&' varDef
void vd6(record **ss, record **s2){
	char *str = cat("&", (*s2)->code, "", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	free(str);
};

//array_dim : '[' ']'
void arrd1(record **ss) {
    *ss = createRecord("[]", "");
}
// | '[' ']' array_dim			
void arrd2(record **ss, record **s3) {
	char *str = cat("[]", (*s3)->code, "", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s3);
	free(str);
}
// | '[' exp ']'				
void arrd3(record **ss, record **s2) {
	char *str = cat("[", (*s2)->code, "]", "", "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	free(str);
}
//| '[' exp ']' array_dim
void arrd4(record **ss, record **s2, record **s4) {
	char *str = cat("[", (*s2)->code, "]", (*s4)->code, "");
	*ss = createRecord(str, "");
	freeRecord(*s2);
	freeRecord(*s4);
	free(str);
};


//main_seq : MAIN_BLOCK '(' ')' BEGIN_BLOCK commands END_BLOCK ';'
void m1(record **ss, record **s5) {
    char *str = cat("int main() {\n", (*s5)->code, "}", "", "");
    freeRecord(*s5);
    *ss = createRecord(str, "");
    free(str);
}
// | empty rule
void m2(record **ss) {
    *ss = createRecord("", "");
};

