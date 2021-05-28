%{
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "lexer.h"
#include "parser.hpp"

void yyerror(const char * msg);
%}

// %union
// {
//     struct expr * exp;
//     int integer;
//     float real;
// };

%start  Input

/* 每行下面的注释是这些终结符代表的意思 */
%token  IDENT NUM
//      ident num
%token  IF ELSE WHILE BREAK CONTINUE RETURN
//      if else while break continue return
%token  INT VOID
//      int void
%token  OR AND GE LE EQ NE
//      || &&  >= <= == !=
%token  INCR DECR
//      ++   --

/* 这些之后都要与相应的类对应，待补 */


%%
Input  :  IDENT INCR NUM
            {
            }
        | NUM GE IDENT
            {
                yyerror("as expected");
            } 

// Input   : /* empty line */
//         | Input Line; /* multi lines */

// Line   : '\n'
//         | Expr '\n'
//             {
//                 expr_print($1);
//             };
// Expr   :  Expr '+' Term
//             {   /* Expr = Expr + Term */
//                 expr_add($1, $3, $$);
//             }
//        |  Expr '-' Term
//             {   /* Expr = Expr + Term */
//                 expr_sub($1, $3, $$);
//             }
//        |  Term
//             {
//                 /* Expr = Term */
//                 $$ = $1;
//             };
%%

void yyerror(const char * msg)
{
    printf("Line(%d): %s\n", yylineno, msg);
}