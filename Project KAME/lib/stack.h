#ifndef STACK
#define STACK
// https://www.techiedelight.com/pt/stack-implementation/

typedef struct VATT {
	   char * subp;
	   char * type;
       struct VATT *next;
}vatt;

typedef struct stack{
    int top;
    vatt *items;
}stack;

vatt *createVarAttNode(vatt *);
struct stack* newStack();
int size(struct stack *pt);
int isEmpty(struct stack *pt);
vatt *pushS(struct stack *pt, char *, char *);
vatt *peekS(struct stack *pt);
vatt *popS(struct stack *pt);

#endif


