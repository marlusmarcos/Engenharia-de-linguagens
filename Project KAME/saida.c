

int main() {
int soma = 0;
{
int i = 0;
identificadorFor_teste:
if(i<10) {
soma += i;
i++;
goto identificadorFor_teste;
}
};
int j;
int multi = 1;
{
j = 0;
identificadorFor_teste:
if(j<5) {
multi *= j;
j++;
goto identificadorFor_teste;
}
};
int k = 3;
{
k = 3;
identificadorFor_teste:
if(k>-5) {
k--;
goto identificadorFor_teste;
}
};
}