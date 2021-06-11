%{
#include "common.h"
#include "lexer.h"
#include "parser.hpp"
#include "helper.h"
#include "ParserException.h"

using namespace std;

void yyerror(const char * msg);

extern SymTable sym_table;
extern SynTree syn_tree;
%}

%union
{
    int num;
    char * name;  // 终结符ident返回值，从词法分析
    Type * p_type;
    SynNode * p_node;
    Block * p_block;
    struct operator_node * p_operator_node;  // 传递部分表达式结构体
    Operator * p_operator;
    struct def * p_def;  // 传递函数、变量声明结构体
    struct def_vars * p_def_vars;  // 传递变量声明结构体
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
/* 文法分析器返回部分 */
%type<num> NUM
%type<name> IDENT
/* 语法分析器部分 */
%type<p_node> Program 
/* 函数外部 */
%type<p_def> Segment Def Idtail
%type<p_type> Type
%type<p_def_vars> Deflist
%type<name> Defdata

%type<p_block> Functail Blockstat 
/* 函数内部 */
%type<p_block> Subprogram
%type<p_node> Localdef
%type<p_node> Onestatement

%type<p_node> Vardef Para 
%type<p_node> Oneparas Onepara Paradata Paradatatail Paradatatails 
%type<p_node> Statement Breakstat Continuestat Returnstat Assignstat Emptystat Whilestat Ifstat Elsestat
// 表达式部分
%type<p_node> Altexpr Expr Assexpr Orexpr Andexpr Cmpexpr
%type<p_node>  Aloexpr Item Factor Val Elem Idexpr Literal Realarg Arg Realargs
%type<p_operator_node> Alotail Itemtail Cmptail Andtail Ortail Asstail
%type<p_operator> '=' AND OR
%type<p_operator> Addsub Muldiv Lop Cmps Rop

%start  Program

%%
Program         : Segment
                    {
                        if (!$1->is_var_def)
                        {
                            // 当函数有函数体即为函数定义时 这里少个检查吧，明天再补，太晚了
                            if ($1->p_def_func->p_body != NULL)
                            {
                                syn_tree.get_root()->add_sub_program($1->p_def_func->p_body);
                                $1->p_def_func->p_body->set_content($1->p_def_func->name);
                            }

                            free($1->p_def_func->name);
                            free($1->p_def_func);
                        }
                            
                        cout << "here50" << endl;
                        free($1);
                        yyerror("unsupported Program Segment");
                    }
                | Program Segment
                    {
                        if (!$2->is_var_def)
                        {
                            if ($2->p_def_func->p_body != NULL)
                            {
                                syn_tree.get_root()->add_sub_program($2->p_def_func->p_body);
                                $2->p_def_func->p_body->set_content($2->p_def_func->name);
                            }

                            free($2->p_def_func->name);
                            free($2->p_def_func);
                        }
                            
                        free($2);
                        yyerror("unsupported Program Program Segment");
                    };

// 只考虑单个声明情况下
Segment         :  Type Def
                    {
                        // 变量声明
                        if ($2->is_var_def)
                        {
                            struct def_vars * p_def_vars = $2->p_def_vars;
                            // 这个简化了，实际应该考虑数组Type什么的
                            for (int i = 0; i < VARS_SIZE && p_def_vars->p_names[i] != NULL; i++)
                            {
                                // cout << "here10" << endl;
                                sym_table.put(p_def_vars->p_names[i], $1, yylineno);
                                // 因为符号表put实际上是创建了新的string对象，所以可以释放
                                free(p_def_vars->p_names[i]);
                            }
                            // 释放数组
                            free(p_def_vars);
                        }
                        // 函数声明
                        else
                        {
                            Func * p_func;
                            // 函数只有两种类型：void和int，分开创建，因为type返回只能是普通的void或int
                            if ($1->get_type() == Type::INT)
                                p_func = new Func(Type::FUNC_INT, $2->p_def_func->param_ids);
                            else
                                p_func = new Func(Type::FUNC_VOID, $2->p_def_func->param_ids);
                            sym_table.put($2->p_def_func->name, p_func, yylineno);
                        }

                        $$ = $2;
                        yyerror("unsupported Segment");
                    };

Type            :  INT
                    {
                        $$ = new Type(Type::INT);
                        yyerror("unsupported Type INT");
                    }
                |  VOID
                    {
                        $$ = new Type(Type::VOID);
                        yyerror("unsupported Type VOID");
                    };

Def             :  '*' IDENT Deflist
                    {
                        yyerror("unsupported Def * IDENT Deflist");
                    }
                |  IDENT Idtail
                    {
                        if($2->is_var_def)
                        {
                            struct def_vars * p_def_vars = $2->p_def_vars;
                            for (int i = 0; i < VARS_SIZE; i++)
                            {
                                // 如果变量声明已达到VARS_SIZE限制大小，报错抛出异常
                                if (i == VARS_SIZE - 1 && p_def_vars->p_names[i] != NULL)
                                    throw new ParserException(
                                        "The number of variable eclaration exceed limit " 
                                        + to_string(VARS_SIZE));
                                if (p_def_vars->p_names[i] == NULL)
                                {
                                    p_def_vars->p_names[i] = $1;
                                    // 放入变量名，退出循环
                                    break;
                                }
                            }
                        }
                        else
                            $2->p_def_func->name = $1;

                        $$ = $2;
                        yyerror("unsupported Def IDENT Idtail");
                    };

Deflist         :  ',' Defdata Deflist
                    {
                        // 如果当前是最后一个变量声明
                        if ($3 == NULL)
                        {
                            // 创建返回定义变量定义的结构体
                            struct def_vars * p_def_vars = new struct def_vars();
                            // 将变量名指针数字全部初始化为NULL
                            for (int i = 0; i < VARS_SIZE; i++)
                                p_def_vars->p_names[i] = NULL;
                            p_def_vars->p_names[0] = $2;
                            $$ = p_def_vars;
                        }
                        // 如果后面还跟着其它变量声明
                        else
                        {
                            // 变量变量名指针数组，在最后放入当前变量名
                            for (int i = 0; i < VARS_SIZE; i++)
                            {
                                // 如果变量声明已达到VARS_SIZE限制大小，报错抛出异常
                                if (i == VARS_SIZE - 1 && $3->p_names[i] != NULL)
                                    throw new ParserException(
                                        "The number of variable eclaration exceed limit " 
                                        + to_string(VARS_SIZE));
                                if ($3->p_names[i] == NULL)
                                {
                                    $3->p_names[i] = $2;
                                    // 放入变量名，退出循环
                                    break;
                                }
                            }
                            $$ = $3;
                        }
                        yyerror("unsupported Deflist , Defdata Deflist");
                    }
                | ';' 
                    { $$ = NULL; };

// 当前假设只有简单的变量，没有数组什么，只返回char *
Defdata         :  IDENT Vardef
                    {
                        if ($2 == NULL)
                            $$ = $1;
                        yyerror("unsupported Defdata IDENT Vardef");
                    }
                |  '*' IDENT
                    {
                        yyerror("unsupported Defdata * IDENT");
                    };

Vardef          : 
                    { 
                        // cout << "here1" << endl;
                        $$ = NULL; 
                    }
                |  '[' NUM ']' Vardef  // Vardef在后面写正好递归返回构建树一样的数组
                    {
                        yyerror("unsupported Vardef");
                    }

Idtail          :  Vardef Deflist
                    {
                        // cout << "here2" << endl;
                        // 这里和Deflist的情况还不一样，因为Idetail的产生式中第一个是Vardef，
                        // Deflist的产生式中第一个是Defdata，其中可能包含Vardef
                        // 先忽略Vardef，即假设没有数组，后面要补上-----------------------------
                        struct def * p_def = new struct def();

                        p_def->is_var_def = true;
                        if ($2 == NULL)
                        {
                            cout << "here3" << endl;
                            // 后面没有定义也要创建def_vars结构，因为到Def产生式必定有变量被声明
                            struct def_vars * p_def_vars = new struct def_vars();
                            for (int i = 0; i < VARS_SIZE; i++)
                            {
                                // cout << "here4" << endl;
                                (p_def_vars->p_names)[i] = NULL;
                            }
                            // cout << "here5" << endl;
                            p_def->p_def_vars = p_def_vars;
                        }
                        else
                        {
                            // 先注释，之后还要添加存Vardef数组维度的数组，方法差不多
                            // // 变量变量名指针数组，在最后放入当前变量名
                            // for (int i = 0; i < VARS_SIZE; i++)
                            // {
                            //     // 如果变量声明已达到VARS_SIZE限制大小，报错抛出异常
                            //     if (i == VARS_SIZE - 1 && $2->p_names[i] != NULL)
                            //         throw new ParserException(
                            //             "The number of variable eclaration exceed limit " 
                            //             + to_string(VARS_SIZE));
                            //     if ($3->p_names[i] == NULL)
                            //     {
                            //         $2->p_names[i] = $1;
                            //         // 放入变量名，退出循环
                            //         break;
                            //     }
                            // }
                            p_def->p_def_vars = $2;
                        }

                        $$ = p_def;
                        yyerror("unsupported Idtail Vardef Deflist");
                    }
                |  '(' Para ')' Functail
                    {
                        struct def * p_def = new struct def();
                        struct def_func * p_def_func = new struct def_func();

                        p_def->is_var_def = false;
                        p_def->p_def_func = p_def_func;
                        for (int i = 0; i < PARAMS_SIZE; i++)
                            p_def_func->param_ids[i] = -1;
                        p_def_func-> p_body = $4;
                        if ($2 != NULL)
                        {
                            
                        }

                        $$ = p_def;
                        yyerror("unsupported Idtail (Para) Functail");
                    }

Functail        :  Blockstat
                    {
                        if ($1 != NULL)
                            // 设置Block为函数体
                            $1->set_func();
                        
                        $$ = $1;
                        yyerror("unsupported Functail Blockstat");
                    }
                |  ';'
                    { $$ = NULL; };

Para            :           // 这个可能不对
                    { $$ = NULL; }
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
                    { $$ = NULL; }
                | Onestatement
                    {
                        // 当Onestatement有返回值即返回了指向了节点的指针，能够构造语法树时
                        if ($1 != NULL)
                        {
                            Block * p_block = new Block(yylineno);
                            p_block->add_sub_program($1);
                            $$ = p_block;
                        }
                        else
                            $$ = NULL;
                    }
                | Subprogram Onestatement
                    {
                        // 当Subprogram有返回值即已经存在了Block并其中已有节点时，不需要新建节点
                        if ($1 != NULL)
                            if ($2 != NULL)
                                $1->add_sub_program($2);
                        else
                            // 如果有新的节点
                            if ($2 != NULL)
                            {
                                Block * p_block = new Block(yylineno);
                                p_block->add_sub_program($2);
                                $$ = p_block;
                            }
                            else
                                // 如果既没有已经存在的Block，也没有新的节点，返回NULL
                                $$ = NULL;

                        yyerror("unsupported Subprogram");
                    };

Onestatement    : Localdef 
                    {
                        yyerror("unsupported Onestatement Localdef");
                    }
                | Statement
                    {
                        $$ = $1;
                        yyerror("unsupported Onestatement Statement");
                    };

Localdef        : Type Defdata Deflist
                    {
                        yyerror("unsupported Localdef");
                    }

// 语句Stmt部分
// --完成--    应该是，就是直接相等就可以了
Statement       : Whilestat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Whilestat");
                    }
                | Ifstat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Ifstat");
                    }
                | Breakstat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Breakstat");
                    }
                | Continuestat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Continuestat");
                    }
                | Returnstat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Returnstat");
                    }
                | Blockstat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Blockstat");
                    }
                | Assignstat
                    {
                        $$ = $1;
                        yyerror("unsupported Statement Assignstat");
                    }
                | Emptystat
                    {
                        $$ = $1;
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

// --完成--
Assignstat      : Altexpr ';'
                    {
                        $$ = $1;
                        yyerror("unsupported Assignstat");
                    };

Blockstat       : '{' Subprogram '}'
                    {
                        $$ = $2;
                        yyerror("unsupported Blockstat");
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
                    { $$ = NULL; }
                | ELSE Statement
                    {
                        yyerror("unsupported Elsestat");
                    };
// --完成--
// 表达式Expr
Altexpr         :
                    { $$ = NULL; }
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
Lop             : '!' { $$ = new Operator(Operator::UNARY_NOT); }
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