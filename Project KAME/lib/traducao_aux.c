#include "traducao_aux.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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