#ifndef SEMANTICS
#define SEMANTICS

#include "record.h"

void dec_seq1(record **, record **, record **);
void dec_seq2(record **);
void dec1(record **, record **, char **);
void dec2(record **, record **);
void dec3(record **, record **);
void id_l1(record **, char **);
void id_l2(record **, char **, record **);
void id_l3(record **, char **, record **);
void id_l4(record **, char **, record **, record **);
void init1(record **, record **, char **, record **);
void subprogs1(record **, record **, record **);
void subprogs2(record **);
void subprog1(record **, record **);
void subprog2(record **, record **);
void func1(record **, char **, record **, char **, record **);
void proc1(record **, char **, record **, record **);
void pard1(record **, record **, char **);
void pard2(record **, record **, char **, record **);
void pard3(record **);
void par1(record **, record **);
void par2(record **, record **, record **);
void par3(record **);
void f_proc_c1(record **, char **, record **);
void comds1(record **, record **, record **);
void comds2(record **);
void comd1(record **, record **);
void comd2(record **, record **);
void comd3(record **, record **);
void comd4(record **, record **);
void comd5(record **, record **);
void comd6(record **, record **);
void comd7(record **);
void comd8(record **);				
void comd9(record **, record **);
void comd10(record **);
void comd11(record **, char **, record **);	
void comd12(record **, record **);
	
void u_d1(record **, char **, record **);
void u_d2(record **, char **, record **);
void enum_i1(record **, char **);
void enum_i2(record **, char **, record **);
void enum_i3(record **, char **, int *);
void enum_i4(record **, char **, int *, record **);
void ty_d1(record **, char **, record **);

void asg1(record **, char **, char **);
void asg2(record **, char **, char **);
void asg3(record **, record **, record **);
void asg4(record **, record **, char **, record **);
void ctrl_b1(record **, record **, record **, record **, char *);
void else_b(record **, record **, char *);
void ctrl_b2(record **, record **, record **, record **);
void ctrl_b3(record **, record **, record **, char *);

void fr1(record **, record **, record **, record **, record **, char *);
void fr2(record **, record **, record **, record **, record **, char *);
void ex1(record **, record **);
void ex2(record **, record **, char **, record **);
void te1(record **, record **);
void te2(record **, record **, char **, record **);
void fac1(record **, record **);
void fac2(record **, char **);
void fac3(record **, int *);
void fac4(record **, float *);
void fac5(record **, record **);
void fac6(record **, record **);
void fac7(record **, char **, record **);
void fac8(record **);
void fac9(record **);
void fac10(record **, record **);
void fac11(record **, record **);

void v1(record **, char **);
void v2(record **, char **, record **);
void v3(record **, char **, record **);
void arrd1(record **);
void arrd2(record **, record **);
void arrd3(record **, record **);
void arrd4(record **, record **, record **);
void m1(record **, record **);
void m2(record **);

void empty_else(record **, char *);

#endif