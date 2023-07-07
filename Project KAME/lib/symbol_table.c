#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

#define TABLE_SIZE 109

/**
 * 
 * Função de hash para calcular o indice da tabela;
 * Rerefencia pega e adaptada de: http://www.cse.yorku.ca/~oz/hash.html
*/
unsigned int hash(unsigned char *str, int tamanho) {
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % tamanho;
}


SymbolInfos *createSymbol(char *key, char *name, char *type) {
    SymbolInfos *symbol = malloc(sizeof(SymbolInfos));
    
    symbol->key = strdup(key);
    symbol->name = strdup(name);
    symbol->type = strdup(type);
    
    return symbol;
}

listNode *createlistNode(SymbolInfos *symbol) {
    listNode *no = malloc(sizeof(listNode));
    no->symbol = symbol;
    no->nextNode = NULL;
    return no;
}

SymbolTable *createSymbolTable(int size) {
    SymbolTable *table = malloc(sizeof(SymbolTable));
    
    table->symbols = calloc(size, sizeof(listNode *));
    table->size = size;
    
    return table;
}

void insert(SymbolTable *table, char *key, char *name, char *type) {
    unsigned int index = hash(key, table->size);
    
    SymbolInfos *symbol = createSymbol(key, name, type);
    listNode *node = createlistNode(symbol);
    
    if (table->symbols[index] == NULL) {
        table->symbols[index] = node;
    } else {
        listNode *current = table->symbols[index];
        
        while (current->nextNode != NULL) {
            current = current->nextNode;
        }
        
        current->nextNode = node;
    }
}

SymbolInfos *lookup(SymbolTable *table, char *key) {
    unsigned int index = hash(key, table->size);
    
    listNode *current = table->symbols[index];
    
    while (current != NULL) {
        if (strcmp(current->symbol->key, key) == 0) {
            return current->symbol;
        }
        
        current = current->nextNode;
    }
    
    return NULL;
}

void printTable(SymbolTable *table) {
    int i;
    

    for (i = 0; i < table->size; i++) {
        listNode *current = table->symbols[i];
        
        while (current != NULL) {
            printf("--------------------------\n");
            printf("Chave:  | %s\n", current->symbol->key);
            printf("Nome:   | %s\n", current->symbol->name);
            printf("Tipo:   | %s\n", current->symbol->type);
            
            current = current->nextNode;
        }
    }
    printf("--------------------------\n");
}

void freeSymbol(SymbolInfos *symbol) {
    free(symbol->key);
    free(symbol->name);
    free(symbol->type);
    free(symbol);
}

void freeListNode(listNode *no) {
    if (no != NULL) {
        freeListNode(no->nextNode);
        freeSymbol(no->symbol);
        free(no);
    }
}

void freeSymbolTable(SymbolTable *table) {
    int i;
    
    for (i = 0; i < table->size; i++) {
        freeListNode(table->symbols[i]);
    }
    
    free(table->symbols);
    free(table);
}


