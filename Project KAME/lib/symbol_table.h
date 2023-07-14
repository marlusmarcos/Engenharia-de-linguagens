#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE

#define TABLE_SIZE 109

typedef struct {
    char *key;
    char *name;
    char *type;
} SymbolInfos;

typedef struct listNode {
    SymbolInfos *symbol;
    struct listNode *nextNode;
} listNode;

typedef struct {
    listNode **symbols;
    int size;
} SymbolTable;

unsigned int hash(unsigned char *, int);
SymbolInfos *createSymbol(char *, char *, char *);
listNode *createlistNode(SymbolInfos *);
SymbolTable *createSymbolTable(int);
void insert(SymbolTable *, char *, char *, char *);
SymbolInfos *lookup(SymbolTable *, char *);
void printTable(SymbolTable *);
void freeSymbol(SymbolInfos *);
void freeListNode(listNode *);
void freeSymbolTable(SymbolTable *);

#endif








