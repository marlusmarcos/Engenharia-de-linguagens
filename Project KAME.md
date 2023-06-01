# Project KAME

Projeto da nossa linguagem para a disciplina de Engenharia de Software

Comandos para utilizar :
```
lex example4.l
yacc example4.y -d -v -g  (-d: y.tab.h; -v: y.output; -g: y.dot [GraphViz])
gcc lex.yy.c y.tab.c -o parser.exe 
```
