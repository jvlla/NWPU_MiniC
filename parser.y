%{
#include "common.h"
#include "lexer.h"
#include "parser.hpp"
#include "structs.h"

using namespace std;

void yyerror(const char * msg);

extern SymTable sym_table;
extern SynTree syn_tree;
%}

%union
{
    int num;
    char * name;  // 终结符ident返回值，从词法分析
    SynNode * p_node;  // 
    // char * operation;  // 操作符返回值
    struct op_p_node * p_op_p_node;
    char * operation;
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
%type<p_node>  Aloexpr Item Itemtail Factor Muldiv Lop Val Rop Elem Idexpr Literal Realarg Arg Realargs
%type<p_op_p_node> Alotail
%type<operation> Addsub

%start  Program

%%
// Program         : Segment
//                     {

//                     }
//                 | Program Segment
//                     {
//                         yyerror("unsupported Program");
//                     };

Program         :  Expr
                    {
                        if ($1 != NULL)
                            cout << "not null" << endl;
                        syn_tree.get_root()->add_sub_program($1);
                    }

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
                        $$ = $1;
                        yyerror("unsupported Expr");
                    };

Assexpr         : Orexpr Asstail
                    {
                        cout << $1 << " " << $2 << endl;
                        if ($1 != NULL && $2 != NULL)
                        {
                            Op * p_op = new Op($1, $2, "=", yylineno);
                            $$ = p_op;
                        }
                        else if ($1 != NULL && $2 == NULL)
                            $$ = $1;
                        else if ($1 == NULL && $2 != NULL)
                            yyerror("the left of = is blank");
                        else
                            $$ = NULL;
                        yyerror("unsupported Assexpr");
                    };

Asstail         :
                    {
                        $$ = NULL;
                    }
                | '=' Assexpr Asstail
                    {
                        if ($3 == NULL)
                            $$ = $2;
                        yyerror("unsupported Asstail");
                    };

Orexpr          : Andexpr Ortail
                    {
                        cout << $1 << " " << $2 << endl;
                        if ($2 == NULL)
                            $$ = $1;
                        yyerror("unsupported Orexpr");
                    };

Ortail          :
                    {
                        $$ = NULL;
                    }
                | OR Andexpr Ortail
                    {
                        yyerror("unsupported Ortail");
                    };

Andexpr         : Cmpexpr Andtail
                    {
                        if ($2 == NULL)
                            $$ = $1;
                        yyerror("unsupported Andexpr");
                    };

Andtail         :
                    {
                        $$ = NULL;
                    }
                | AND Cmpexpr Andtail
                    {
                        yyerror("unsupported Andexpr");
                    };

Cmpexpr         : Aloexpr Cmptail
                    {
                        if ($2 == NULL)
                            $$ = $1;
                        yyerror("unsupported Cmpexpr");
                    };

Cmptail         :
                    {
                        $$ = NULL;
                    }
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
                        cout << $1 << " " << $2 << endl;
                        if ($2 != NULL)
                        {
                            Op * p_op;
                            p_op = new Op($1, $2->p_node, $2->operation, yylineno);
                            $$ = p_op;
                        }
                        else
                            $$ = $1;
                        yyerror("unsupported Aloexpr");
                    };

Alotail         :   { $$ = NULL; }
                | Addsub Item Alotail
                    {
                        cout << $1 << $2 << $3 << endl;
                        struct op_p_node * p_op_p_node = new struct op_p_node();  // 返回值
                        p_op_p_node->operation = $1;  // Addsub肯定不为空，直接赋
                        // 如果右边仍有加减法，即Alotail不为空
                        if ($3 != NULL)
                        {
                            // 但没有左操作数，报错 这情况是不是没法有？
                            if ($2 == NULL)
                                yyerror("Item is NULL");
                            // 生成语法树上新的Op节点
                            Op * p_op;
                            if ($3->operation == 0)
                                p_op = new Op($2, $3->p_node, "+", yylineno);
                            else
                                p_op = new Op($2, $3->p_node, "-", yylineno);
                            free($3);  // 这个应该可以释放吧
                            // 赋给返回值
                            p_op_p_node->p_node = p_op;
                        }
                        else
                        {
                            // Item为空可能吗？好像不，算了，保险一点
                            if ($2 == NULL)
                                yyerror("Item is NULL");
                            // Item赋给返回值
                            p_op_p_node->p_node = $2;
                        }

                        $$ = p_op_p_node;
                        yyerror("unsupported Alotail");
                    };
// 之后这些应该就是用来算数的了
Addsub          : '+'   // 这个有不被释放的危险啊
                    { 
                        $$ = (char *) malloc(10);
                        memset($$, 0, 10);
                        $$[0] = '+';
                    }
                | '-' 
                    { 
                        $$ = (char *) malloc(10);
                        memset($$, 0, 10);
                        $$[0] = '-';
                    };

Item            : Factor Itemtail
                    {
                        cout << $1 << " " << $2 << endl;
                        if ($2 == NULL)
                            $$ = $1;
                        yyerror("unsupported Item");
                    };

Itemtail        :
                    {
                        $$ = NULL;
                    }
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
                        $$ = $1;
                        yyerror("unsupported Factor Val");
                    }

Lop             : '!' | '-' | '&' | '*' | INCR | DECR
                    {
                        yyerror("unsupported Lop");
                    }

Val             : Elem
                    {
                        $$ = $1;
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
                        if ($2 == NULL)
                        {
                            Variable * p_variable = new Variable($1, &sym_table, yylineno);
                            $$ = p_variable;
                        }
                        yyerror("unsupported Elem IDENT Idexpr");
                    }
                | '(' Expr')'
                    {
                        yyerror("unsupported Elem (Expr)");
                    }
                | Literal
                    {
                        $$ = $1;
                        yyerror("unsupported Elem Literal");
                    }

Idexpr          :
                    {
                        $$ = NULL;
                    }
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
                        Constant * p_constant = new Constant($1, yylineno);
                        $$ = p_constant;
                        cout << $$ << endl;
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
    // exit(EXIT_FAILURE);
}