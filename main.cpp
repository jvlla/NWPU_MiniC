#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "lexer.h"
#include "parser.hpp"

extern int yyparse (void);

int main(int argc, char *argv[])
{
    yyin = stdin;

    if(argc > 1)
    {
        if((yyin = fopen(argv[1],"r"))==NULL)
        {
            printf("Can't open file %s\n",argv[1]);
            return -1;
        }
    }

    yyparse();

    return 0;
}
