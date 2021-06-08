%{
#include "common.h"
#include "lexer.h"
#include "parser.hpp"
#include "helper.h"

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
    struct operator_node * p_operator_node;
    Operator * p_operator;
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
%type<p_node> Altexpr Expr Assexpr Orexpr Andexpr Cmpexpr
%type<p_node>  Aloexpr Item Factor Val Elem Idexpr Literal Realarg Arg Realargs
%type<p_operator_node> Alotail Itemtail Cmptail Andtail Ortail Asstail
%type<p_operator> '=' AND OR
%type<p_operator> Addsub Muldiv Lop Cmps Rop

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
                    { $$ = NULL }
                | ELSE Statement
                    {
                        yyerror("unsupported Elsestat");
                    };
// --完成--
// 表达式Expr
Altexpr         :
                    { $$ = NULL }
                | Expr
                    {
                        $$ = $1;
                        yyerror("unsupported Altexpr");
                    };
// --完成--
Expr            : Assexpr
                    {
                        $$ = $1;
                        yyerror("unsupported Expr");
                    };
// --完成-- 可能
Assexpr         : Orexpr Asstail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        yyerror("unsupported Assexpr");
                    };
// --完成--
Asstail         :   { $$ = NULL; }
                | '=' Assexpr Asstail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Asstail");
                    };
// --完成--
Orexpr          : Andexpr Ortail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        yyerror("unsupported Orexpr");
                    };
// --完成--
Ortail          :   { $$ = NULL; }
                | OR Andexpr Ortail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Ortail");
                    };
// --完成--
Andexpr         : Cmpexpr Andtail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        yyerror("unsupported Andexpr");
                    };
// --完成--
Andtail         :   { $$ = NULL; }
                | AND Cmpexpr Andtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Andexpr");
                    };
// --完成--
Cmpexpr         : Aloexpr Cmptail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        yyerror("unsupported Cmpexpr");
                    };
// --完成--
Cmptail         :   { $$ = NULL; }
                | Cmps Aloexpr Cmptail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Cmptail");
                    };
// --完成--
Cmps            : '>' { $$ = new Operator(Operator::BINARY_GREATER); } 
                | '<' { $$ = new Operator(Operator::BINARY_LESS); } 
                | GE { $$ = new Operator(Operator::BINARY_GREATER_EQUAL); }
                | LE { $$ = new Operator(Operator::BINARY_LESS_EQUAL); }
                | EQ { $$ = new Operator(Operator::BINARY_EQUAL); }
                | NE { $$ = new Operator(Operator::BINARY_NOT_EQUAL); }
// --完成--
Aloexpr         : Item Alotail
                    {
                        if ($2 != NULL)
                            $$ = new Op($1, $2->p_node, $2->p_operator, yylineno);
                        else
                            $$ = $1;
                        yyerror("unsupported Aloexpr");
                    };
// --完成--
Alotail         :   { $$ = NULL; }
                | Addsub Item Alotail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Alotail");
                    };
// --完成--
// 之后这些应该就是用来算数的了
Addsub          : '+' { $$ = new Operator(Operator::BINARY_ADD); }
                | '-' { $$ = new Operator(Operator::BINARY_SUB); };
// --完成--
Item            : Factor Itemtail
                    {
                        if ($2 != NULL)
                            $$ = new Op($1, $2->p_node, $2->p_operator, yylineno);
                        else
                            $$ = $1;
                        yyerror("unsupported Item");
                    };
// --完成--
Itemtail        :   { $$ = NULL; }
                | Muldiv Factor Itemtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        yyerror("unsupported Itemtail");
                    };
// --完成--
Muldiv          : '*' { $$ = new Operator(Operator::BINARY_MUL); }
                | '/' { $$ = new Operator(Operator::BINARY_DIV); };
// --完成--
Factor          : Lop Factor
                    {
                        $$ = new Unary($2, $1, yylineno);
                        yyerror("unsupported Factor Lop Factor");
                    }
                | Val
                    {
                        $$ = $1;
                        yyerror("unsupported Factor Val");
                    }
// --完成--
Lop             : '!' { $$ = new Operator(Operator::UNARY_NOT); 
    cout << "here" << endl;}
    
                | '-' { $$ = new Operator(Operator::UNARY_MINUS); }
                | '&' { $$ = new Operator(Operator::UNARY_ADDRESS); }
                | '*' { $$ = new Operator(Operator::UNARY_INDIRECTION); }  // 这个应该是解引用符号吧，回头要注意
                | INCR { $$ = new Operator(Operator::UNARY_INCR); } 
                | DECR { $$ = new Operator(Operator::UNARY_DECR); };
// --完成--
Val             : Elem
                    {
                        $$ = $1;
                        yyerror("unsupported Val Elem");
                    }
                | Elem Rop
                    {
                        $$ = new Unary($1, $2, yylineno);
                        yyerror("unsupported Val Rop");
                    }
// --完成--
Rop             : INCR { $$ = new Operator(Operator::UNARY_INCR); }
                | DECR { $$ = new Operator(Operator::UNARY_DECR); };

Elem            : IDENT Idexpr
                    {
                        if ($2 == NULL)
                            $$ = new Variable($1, &sym_table, yylineno);
                        yyerror("unsupported Elem IDENT Idexpr");
                    }
                | '(' Expr')'
                    {
                        $$ = $2;
                        yyerror("unsupported Elem (Expr)");
                    }
                | Literal 
                    { 
                        $$ = $1; 
                        yyerror("unsupported Elem Literal"); 
                    };

Idexpr          :   { $$ = NULL; }
                | '[' Expr ']' 
                    {
                        yyerror("unsupported Idexpr [Expr]");
                    }
                | '(' Realarg ')'
                    {
                        yyerror("unsupported Idexpr (Realarg)");
                    }
// --完成--
Literal         : NUM
                    {
                        $$ = new Constant($1, yylineno);
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
// --完成--
Arg             : Expr
                    {
                        $$ = $1;
                        yyerror("unsupported Arg");
                    }
%%

void yyerror(const char * msg)
{
    printf("Line(%d): %s\n", yylineno, msg);
    // exit(EXIT_FAILURE);
}