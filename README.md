# Engenharia de Linguagens

Projeto da disciplina de engenharia de linguagens do curso de Engenharia de Software da UFRN.

## Como testar o lex?

 1. Primeiro passo:

    1.1. Executar o comando: $ flex lexer.l

    1.2. Após isso, se tudo estiver tudo correto, o lex vai gerar um arquivo lex.yy.c

 2. Segundo passo:

    2.1. Realizar o processo de compilação do código C gerado pelo lex: $ gcc -o project lex.yy.c -ll.

 3. Terceiro passo:

    3.1 Agora para executar é só rodar: $ ./project < exemplo.txt

# Equipe    

* Alexandre Dantas dos Santos
* Alvaro Prudencio Araújo
* Elexandro Torres Alves
* Kaio Henrique de Sousa
* Marlus Marcos Rodrigues Costa da Silva
