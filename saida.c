#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char b[256];

int main()
{
    strcpy(b, "");
    if ( 0 ) goto LABEL_if_true_1;
    strcpy(b, "2");
    goto LABEL_fim_if_else_1;
LABEL_if_true_1:
    strcpy(b, "1");
LABEL_fim_if_else_1:
    printf("%s",b);
    return 0;
}


