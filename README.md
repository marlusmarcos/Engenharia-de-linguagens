# Engenharia de Linguagens

Projeto da disciplina de engenharia de linguagens do curso de Engenharia de Software da UFRN.

## Como testar o lex?

 1. Primeiro passo:

    1.1. Executar o comando: $ flex lexer.l

    1.2. Após isso, se tudo estiver tudo correto, o lex vai gerar um arquivo lex.yy.c

 2. Segundo passo:

    2.1 Executar o comando: $ yacc parser.y -d -v

      2.1.1 Para executar no windows use o seguinte commando $ bison -dy parser.y

    2.2 Após isso, serão criados os arquivos y.tab.c e y.tab.h

 3. Segundo passo:

    3.1. Realizar o processo de compilação do código C gerado pelo lex e yacc: $ gcc lex.yy.c y.tab.c -o compilador -ll.

 3. Terceiro passo:

    3.1 Agora para executar é só rodar: $ ./compilador < exemplo.txt

# Equipe    

* Alexandre Dantas dos Santos
* Alvaro Prudencio Araújo
* Elexandro Torres Alves
* Kaio Henrique de Sousa
* Marlus Marcos Rodrigues Costa da Silva

# Versão Bison

bison (GNU Bison) 3.8.2
Escrito por Robert Corbett e Richard Stallman.

