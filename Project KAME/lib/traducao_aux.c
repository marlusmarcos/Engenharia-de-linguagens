#include "traducao_aux.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


char * getBlockID(){
    char *outStr = (char *) malloc(sizeof(char) * 30);
	sprintf(outStr, "%d", blockID);

    return outStr;
};
char * incBlockID(){
    char *outStr = (char *) malloc(sizeof(char) * 30);
    blockID++;
	sprintf(outStr, "%d", blockID);

    return outStr;
};

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