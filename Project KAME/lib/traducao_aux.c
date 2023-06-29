#include "traducao_aux.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
* Função para contatenar até 5 strings.
*/
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

/*
* Função para auxiliar na concatenação de strings.
*/
char* concatenarStrings(int quantidadeStrings, char** strings) {
    int tamanhoSaida = 1;
    
    for (int i = 0; i < quantidadeStrings; i++) {
        if (strings[i] != NULL) {
            tamanhoSaida += strlen(strings[i]);
        }
    }
    
    char* saida = (char*)malloc(tamanhoSaida * sizeof(char));
    
    if (!saida) {
        printf("Erro de alocação. Encerrando o programa...\n");
        exit(0);
    }
    
    saida[0] = '\0';
    
    
    for (int i = 0; i < quantidadeStrings; i++) {
        if (strings[i] != NULL) {
            strcat(saida, strings[i]);
        }
    }
    
    return saida;
}


/*
* Função para auxiliar na tradução do for da gramatica para codigo simplificado C utilizando o goto.
*/
char * forToGoTo(char * initializationCode, char * expressionCode, char * assignCode, char * comandsCode) {
	char *identificadorFor;
	char *forCodePart1;
	char *forCodePart2;
	char *forCodePart3;
	
	identificadorFor = concatenarStrings(2, (char*[]){"identificadorFor_", "teste"});

	if (!identificadorFor){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}

	forCodePart1 = concatenarStrings(6, (char*[]){"{\n", initializationCode, ";", "\n", identificadorFor, ":\n" });

	if (!forCodePart1){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}

	forCodePart2 = concatenarStrings(4, (char*[]){forCodePart1, "if(", expressionCode, ") {\n"});

	if (!forCodePart2){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}
	
	forCodePart3 = concatenarStrings(7, (char*[]){forCodePart2, comandsCode, assignCode, ";", "\ngoto ", identificadorFor, ";\n}\n}"}); 
  
  	if (!forCodePart3){
    	printf("Allocation problem. Closing application...\n");
    	exit(0);
  	}

	free(identificadorFor);
	free(forCodePart1);
	free(forCodePart2);

  
  return forCodePart3;

}

/*
* Função para auxiliar na tradução do if else da gramatica para codigo simplificado C utilizando o goto.
*/
// | IF '(' exp ')' BEGIN_BLOCK commands END_BLOCK	
//					ELSE BEGIN_BLOCK commands END_BLOCK
char * ifElseToGoTo(char * expressionCode, char * ifComandsCode, char * elseComandsCode) {
  char *ifElseToGoToCodePart1 = cat("if (", expressionCode, "){\n", "goto IF_BLOCK;", "} ");
  char *ifElseToGoToCodePart2 = cat("if (", expressionCode, "){\n", ifComandsCode, "} ");
  char *ifElseToGoToCodePart2 = cat("if (", expressionCode, "){\n", ifComandsCode, "} ");
	char *ifElseToGoToCodePart3 = cat(ifElseToGoToCodePart1, "else", "{\n", elseComandsCode, "}");


	*ss = createRecord(ifElseToGoToCodePart2, "");
	freeRecord(*s3);
	freeRecord(*s6);
	freeRecord(*s10);
	free(str1);
	free(str2);




	char *identificadorFor;
	char *forCodePart1;
	char *forCodePart2;
	char *forCodePart3;
	
	identificadorFor = concatenarStrings(2, (char*[]){"identificadorFor_", "teste"});

	if (!identificadorFor){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}

	forCodePart1 = concatenarStrings(6, (char*[]){"{\n", initializationCode, ";", "\n", identificadorFor, ":\n" });

	if (!forCodePart1){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}

	forCodePart2 = concatenarStrings(4, (char*[]){forCodePart1, "if(", expressionCode, ") {\n"});

	if (!forCodePart2){
    	printf("Problema de alocação de memoria. Fechando o compilador...\n");
    	exit(0);
  	}
	
	forCodePart3 = concatenarStrings(7, (char*[]){forCodePart2, comandsCode, assignCode, ";", "\ngoto ", identificadorFor, ";\n}\n}"}); 
  
  	if (!forCodePart3){
    	printf("Allocation problem. Closing application...\n");
    	exit(0);
  	}

	free(identificadorFor);
	free(forCodePart1);
	free(forCodePart2);

  
  return forCodePart3;

}

/*

int i = 5;
    
    if(i <= 10) {
        goto IF_BLOCK;
    }
    goto ELSE_BLOCK;
    {
        IF_BLOCK:
        printf("IF\n");
        goto EXIT_BLOCK;
    }
    {
        ELSE_BLOCK:
        printf("ELSE\n");
    }
    
    EXIT_BLOCK:
    
  
    int x = 10;
    while(x < 100) {
        x++;
    }
    
    
    printf("**************\n");
    
    int x = 10;
    {
        WHILE_IN:
        if(x <= 10) {
            x++;
            //codigo usuario
            printf("%d", x);
            goto WHILE_IN;
        }
    }


*/
