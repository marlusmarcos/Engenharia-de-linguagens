#include "stack.h"
#include <stdlib.h>
//#include <stdio.h>

// https://www.techiedelight.com/pt/stack-implementation/

vatt *createVarAttNode(vatt *x) {
    vatt *no = malloc(sizeof(vatt));
    no->subp = x->subp;
    no->type = x->type;
    no->next = NULL;
    return no;
}

struct stack* newStack()
{
    struct stack *pt = (struct stack*)malloc(sizeof(struct stack));
 
    pt->top = -1;
    pt->items = (void *) malloc(sizeof(vatt));
    pt->items->next = NULL;
 
    return pt;
}
 
int size(struct stack *pt) {
    return pt->top + 1;
}
 
int isEmpty(struct stack *pt) {
    return pt->top == -1;
}

vatt *pushS(struct stack *pt, char *subp, char *type) {
 
    //printf("Inserting %s\n", x.subp);
 
    // adiciona um elemento e incrementa o índice do topo
    vatt *new_node;
    new_node = (vatt *) malloc(sizeof(vatt));

    new_node->subp = subp;
    new_node->type = type;
    new_node->next = pt->items;
    pt->items = new_node;
    pt->top++;
    return new_node;
}
 
vatt *peekS(struct stack *pt)
{
    if (!isEmpty(pt)) {
        return pt->items;
    }
    else {
        return NULL;
    }
}

vatt *popS(struct stack *pt){
    if (isEmpty(pt)){
        return NULL;
    }
    vatt *tmp = peekS(pt);

    //printf("Removing %s\n", tmp->subp);

    vatt *next_node = NULL;

    if (pt->items == NULL) {
        return NULL;
    }

    next_node = pt->items->next;
    free(pt->items);
    pt->items = next_node;
    pt->top--;

    return tmp;
}

/*int main(){
    struct stack *pt = newStack();
    //vatt v1 = {.subp="00", .type="int"};
    //vatt v2 = {.subp="01", .type="int"};
    //vatt v3 = {.subp="02", .type="float"};
    //vatt v4 = {.subp="03", .type="string"};
 
    pushS(pt, "00", "int");
    popS(pt);
    pushS(pt, "01", "int");
    pushS(pt, "02", "float");
    pushS(pt, "03", "int");
    pushS(pt, "04", "string");
 
    vatt *ult = peekS(pt);
    printf("The top element is %s\n", ult->type);
    printf("The stack size is %d\n", size(pt));
 
    popS(pt);
    popS(pt);
    popS(pt);
    popS(pt);
 
    if (isEmpty(pt)) {
        printf("The stack is empty");
    }
    else {
        printf("The stack is not empty");
    }
 
    return 0;
}*/