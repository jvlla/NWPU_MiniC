%{
#include "common.h"
#include "parser.hpp"

#define		ERRORCHAR	600
%}

%option yylineno
%option noyywrap
/* %option c++ */

/************************************
*	MACRO DEFINITION	*
*************************************/
ident       [A-Za-z_][A-Za-z0-9_]*
num         [0-9]+
white       [\t\040]
white_line  \n|\r\n

/*****************************************
*	RECOGNIION RULES	         *
*****************************************/
%%
 /* 其实下面分类并不准确，比如*是指针也是乘号等 */
 /* 程序控制字 */
"if"            {return IF;}
"else"          {return ELSE;}
"while"         {return WHILE;}
"break"         {return BREAK;}
"continue"      {return CONTINUE;}
"return"        {return RETURN;}
 /* 赋值等号 */
"="             {return '=';}
 /* 类型 */
"int"           {return INT;};
"void"          {return VOID;}
 /* 双目逻辑运算符 */
"||"            {return OR;}
"&&"            {return AND;}
">="            {return GE;}
">"             {return '>';}
"<"             {return '<';}
"<="            {return LE;}
"=="            {return EQ;}
"!="            {return NE;}
 /* 单目逻辑运算符 */
"!"             {return '!';}
"&"             {return '&';}
 /* 加减乘除 */
"+"             {return '+';}
"-"		        {return '-';}
"*"             {return '*';}
"/"             {return '/';}
"%"             {return '%';}
 /* 自加减 */
"++"            {return INCR;}
"--"            {return DECR;}
 /* 各种括号 */
"{"             {return '{';}
"}"             {return '}';}
"("			    {return '(';}
")"			    {return ')';}
"["             {return '[';}
"]"             {return ']';}
 /* 逗号类 */
","             {return ',';}
";"             {return ';';}
 /* 不能放在前面，因为前面的规则先匹配 */
{ident}         {
                    yylval.name = (char *) malloc(100);
                    memset(yylval.name, 0, 100);
                    memcpy(yylval.name, yytext, yyleng);
                    
                    return IDENT;
                }
{num}           {
                    yylval.num = (int)strtol(yytext, (char **)NULL, 10);
                    return NUM;
                }

 /* 遇到空白不做任何操作，跳过；嗯，应该可以 */
{white}+		{}
{white_line}    {}

.               {
                    cout << "Invalid char " << yytext << endl;
                    return ERRORCHAR;
                }
%%