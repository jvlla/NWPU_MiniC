%{
#include "common.h"
#include "lexer.h"
#include "parser.hpp"

using namespace std;

void yyerror(const char * msg);

extern SymTable sym_table;
extern SynTree syn_tree;
%}

%union
{
    int num;
    char * name;
    SynNode * p_node;
};

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
%type<num> NUM
%type<name> IDENT
%type<p_node> Program Segment Type Def Deflist Defdata Vardef Idtail Functail Para 
%type<p_node> Oneparas Onepara Paradata Paradatatail Paradatatails 
%type<p_node> Subprogram Onestatement Localdef
%type<p_node> Statement Breakstat Continuestat Returnstat Blockstat Assignstat Emptystat Whilestat Ifstat Elsestat
%type<p_node> Altexpr Expr Assexpr Asstail Orexpr Ortail Andexpr Andtail Cmpexpr Cmptail Cmps
%type<p_node>  Aloexpr Alotail Addsub Item Itemtail Factor Muldiv Lop Val Rop Elem Idexpr Literal Realarg Arg Realargs

%start  Program

%%
Program         : Segment
                    {

                    }
                | Program Segment
                    {
                        yyerror("unsupported Program");
                    };

Segment         :  Type Def
                    {
                        yyerror("unsupported Segment");
                    };

Type            :  INT
                    {
                        yyerror("unsupported Type INT");
                    }
                |  VOID
                    {
                        yyerror("unsupported Type VOID");
                    };

Def             :  '*' IDENT Deflist
                    {
                        yyerror("unsupported Def * IDENT Deflist");
                    }
                |  IDENT Idtail
                    {
                        yyerror("unsupported Def IDENT Idtail");
                    };

Deflist         :  ',' Defdata Deflist
                    {
                        yyerror("unsupported Deflist , Defdata Deflist");
                    }
                | ';' 
                    {};  // 这里本身就不用做什么

Defdata         :  IDENT Vardef
                    {
                        yyerror("unsupported Defdata IDENT Vardef");
                    }
                |  '*' IDENT
                    {
                        yyerror("unsupported Defdata * IDENT");
                    };

Vardef          : 
                    {}
                |  '[' NUM ']' Vardef  // Vardef在后面写正好递归返回构建树一样的数组
                    {
                        yyerror("unsupported Vardef");
                    }

Idtail          :  Vardef Deflist
                    {
                        yyerror("unsupported Idtail Vardef Deflist");
                    }
                |  '(' Para ')' Functail
                    {
                        yyerror("unsupported Idtail (Para) Functail");
                    }

Functail        :  Blockstat
                    {
                        yyerror("unsupported Functail Blockstat");
                    }
                |  ';'
                    {};

Para            :           // 这个可能不对
                    {}
                | Onepara Oneparas
                    {
                        yyerror("unsupported Para");
                    };

Oneparas        :
                    {}
                | ',' Onepara Oneparas
                    {
                        yyerror("unsupported Oneparas");
                    };

Onepara         : Type Paradata
                    {
                        yyerror("unsupported Onepara");
                    };

Paradata        : '*' IDENT
                    {
                        yyerror("unsupported Paradata * IDENT");
                    }
                | IDENT Paradatatail
                    {
                        yyerror("unsupported Paradata IDENT Paradatatail");
                    };

Paradatatail    : '[' ']' Paradatatails  // 这个可能也有问题
                    {
                        yyerror("unsupported Paradatatail [] Paradatatails");
                    }
                | Paradatatails
                    {
                        yyerror("unsupported Paradata Paradatatails");
                    };

Paradatatails   :
                    {}
                | '[' NUM ']' Paradatatails
                    {
                        yyerror("unsupported Paradatatails");
                    };

// 以下是函数内部了
Subprogram      :
                    {}
                | Subprogram Onestatement
                    {
                        yyerror("unsupported Subprogram");
                    };

Onestatement    : Localdef 
                    {
                        yyerror("unsupported Onestatement Localdef");
                    }
                | Statement
                    {
                        yyerror("unsupported Onestatement Statement");
                    };

Localdef        : Type Defdata Deflist
                    {
                        yyerror("unsupported Localdef");
                    }

// 语句Stmt部分
Statement       : Whilestat
                    {
                        yyerror("unsupported Statement Whilestat");
                    }
                | Ifstat
                    {
                        yyerror("unsupported Statement Ifstat");
                    }
                | Breakstat
                    {
                        yyerror("unsupported Statement Breakstat");
                    }
                | Continuestat
                    {
                        yyerror("unsupported Statement Continuestat");
                    }
                | Returnstat
                    {
                        yyerror("unsupported Statement Returnstat");
                    }
                | Blockstat
                    {
                        yyerror("unsupported Statement Blockstat");
                    }
                | Assignstat
                    {
                        yyerror("unsupported Statement Assignstat");
                    }
                | Emptystat
                    {
                        yyerror("unsupported Statement Emptystat");
                    };

Breakstat       : BREAK ';'
                    {
                        yyerror("unsupported Breakstat");
                    };

Continuestat    : CONTINUE ';'
                    {
                        yyerror("unsupported Continuestat");
                    };

Returnstat      : RETURN Altexpr ';'
                    {
                        yyerror("unsupported Returnstat");
                    };

Assignstat      : Altexpr ';'
                    {
                        yyerror("unsupported Assignstat");
                    };

Blockstat       : '{' Subprogram '}'
                    {

                    };

Emptystat       : ';'
                    {};  // 这个就是什么都不干的

Whilestat       : WHILE '(' Expr ')' Statement
                    {
                        yyerror("unsupported Whilestat");
                    };

Ifstat          : IF  '(' Expr ')' Statement Elsestat
                    {
                        yyerror("unsupported Ifstat");
                    };

Elsestat        :
                    {}
                | ELSE Statement
                    {
                        yyerror("unsupported Elsestat");
                    };

// 表达式Expr
Altexpr         :
                    {}
                | Expr
                    {
                        yyerror("unsupported Altexpr");
                    };

Expr            : Assexpr
                    {
                        yyerror("unsupported Expr");
                    };

Assexpr         : Orexpr Asstail
                    {
                        yyerror("unsupported Assexpr");
                    };

Asstail         :
                    {}
                | '=' Assexpr Asstail
                    {
                        yyerror("unsupported Asstail");
                    };

Orexpr          : Andexpr Ortail
                    {
                        yyerror("unsupported Orexpr");
                    };

Ortail          :
                    {}
                | OR Andexpr Ortail
                    {
                        yyerror("unsupported Ortail");
                    };

Andexpr         : Cmpexpr Andtail
                    {
                        yyerror("unsupported Andexpr");
                    };

Andtail         :
                    {}
                | AND Cmpexpr Andtail
                    {
                        yyerror("unsupported Andexpr");
                    };

Cmpexpr         : Aloexpr Cmptail
                    {
                        yyerror("unsupported Cmpexpr");
                    };

Cmptail         :
                    {}
                | Cmps Aloexpr Cmptail
                    {
                        yyerror("unsupported Cmptail");
                    };

Cmps            : GE | '>' | '<' | LE | EQ | NE
                    {
                        yyerror("unsupported Cmps");
                    };

Aloexpr         : Item Alotail
                    {
                        yyerror("unsupported Aloexpr");
                    };

Alotail         :
                    {}
                | Addsub Item Alotail
                    {
                        yyerror("unsupported Alotail");
                    };
// 之后这些应该就是用来算数的了
Addsub          : '+' | '-'
                    {
                        yyerror("unsupported Addsub");
                    };

Item            : Factor Itemtail
                    {
                        yyerror("unsupported Item");
                    };

Itemtail        :
                    {}
                | Muldiv Factor Itemtail
                    {
                        yyerror("unsupported Itemtail");
                    };

Muldiv          : '*' | '/'
                    {
                        yyerror("unsupported Muldiv");
                    };

Factor          : Lop Factor
                    {
                        yyerror("unsupported Factor Lop Factor");
                    }
                | Val
                    {
                        yyerror("unsupported Factor Val");
                    }

Lop             : '!' | '-' | '&' | '*' | INCR | DECR
                    {
                        yyerror("unsupported Lop");
                    }

Val             : Elem
                    {
                        yyerror("unsupported Val Elem");
                    }
                | Elem Rop
                    {
                        yyerror("unsupported Val Rop");
                    }

Rop             : INCR | DECR
                    {
                        yyerror("unsupported Rop");
                    }

Elem            : IDENT Idexpr
                    {
                        yyerror("unsupported Elem IDENT Idexpr");
                    }
                | '(' Expr')'
                    {
                        yyerror("unsupported Elem (Expr)");
                    }
                | Literal
                    {
                        yyerror("unsupported Elem Literal");
                    }

Idexpr          :
                    {}
                | '[' Expr ']' 
                    {
                        yyerror("unsupported Idexpr [Expr]");
                    }
                | '(' Realarg ')'
                    {
                        yyerror("unsupported Idexpr (Realarg)");
                    }

Literal         : NUM
                    {
                        yyerror("unsupported Literal");
                    }

Realarg         :  // 这是不是也可能有问题
                    {}
                | Arg Realargs
                    {
                        yyerror("unsupported Realarg");
                    }

Realargs        :
                    {}
                | ',' Arg Realargs
                    {
                        yyerror("unsupported Realargs");
                    }

Arg             : Expr
                    {
                        yyerror("unsupported Arg");
                    }
%%

void yyerror(const char * msg)
{
    printf("Line(%d): %s\n", yylineno, msg);
}