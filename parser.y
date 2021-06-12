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
    Type * p_type;
    SynNode * p_node;
    Block * p_block;
    struct operator_node * p_operator_node;  // 传递部分表达式结构体
    Operator * p_operator;
    struct def * p_def;  // 传递函数、变量声明结构体
    struct def_vars * p_def_vars;  // 传递变量声明结构体
    If * p_if;
    Else * p_else;
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
%type<p_def_vars> Localdef
%type<p_node> Onestatement

%type<p_node> Vardef Para 
%type<p_node> Oneparas Onepara Paradata Paradatatail Paradatatails 
%type<p_node> Statement Breakstat Continuestat Returnstat Assignstat Emptystat Whilestat
%type<p_if> Ifstat
%type<p_else> Elsestat
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
                            
                        free($1);
                        parser_tracker("Program Segment");
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
                        parser_tracker("Program Program Segment");
                    };

// 只考虑单个声明情况下
Segment         :  Type Def
                    {
                        // 变量声明
                        if ($2->is_var_def)
                        {
                            struct def_vars * p_def_vars = $2->p_def_vars;
                            // 这个简化了，实际应该考虑数组Type什么的
                            // 倒叙遍历，因为变量放的时候是从后往前的

                            for (int i = VARS_SIZE - 1; i >= 0; i--)
                            {
                                cout << "here10" << endl;
                                if (p_def_vars->p_names[i] != NULL)
                                {
                                    cout << "in" << endl;
                                    sym_table.put(p_def_vars->p_names[i], $1, yylineno);
                                    // 因为符号表put实际上是创建了新的string对象，所以可以释放
                                    free(p_def_vars->p_names[i]);
                                }
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
                        parser_tracker("Segment");
                    };

Type            :  INT
                    {
                        $$ = new Type(Type::INT);
                        parser_tracker("Type INT");
                    }
                |  VOID
                    {
                        $$ = new Type(Type::VOID);
                        parser_tracker("Type VOID");
                    };

Def             :  '*' IDENT Deflist
                    {
                        parser_tracker("Def * IDENT Deflist");
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
                        parser_tracker("Def IDENT Idtail");
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
                        parser_tracker("Deflist , Defdata Deflist");
                    }
                | ';' 
                    { $$ = NULL; };

// 当前假设只有简单的变量，没有数组什么，只返回char *
Defdata         :  IDENT Vardef
                    {
                        if ($2 == NULL)
                            $$ = $1;
                        parser_tracker("Defdata IDENT Vardef");
                    }
                |  '*' IDENT
                    {
                        parser_tracker("Defdata * IDENT");
                    };

Vardef          : 
                    { 
                        // cout << "here1" << endl;
                        $$ = NULL; 
                    }
                |  '[' NUM ']' Vardef  // Vardef在后面写正好递归返回构建树一样的数组
                    {
                        parser_tracker("Vardef");
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
                        parser_tracker("Idtail Vardef Deflist");
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
                        parser_tracker("Idtail (Para) Functail");
                    }

Functail        :  Blockstat
                    {
                        if ($1 != NULL)
                            // 设置Block为函数体
                            $1->set_func();
                        
                        $$ = $1;
                        parser_tracker("Functail Blockstat");
                    }
                |  ';'
                    { $$ = NULL; };

Para            :           // 这个可能不对
                    { $$ = NULL; }
                | Onepara Oneparas
                    {
                        parser_tracker("Para");
                    };

Oneparas        :
                    {}
                | ',' Onepara Oneparas
                    {
                        parser_tracker("Oneparas");
                    };

Onepara         : Type Paradata
                    {
                        parser_tracker("Onepara");
                    };

Paradata        : '*' IDENT
                    {
                        parser_tracker("Paradata * IDENT");
                    }
                | IDENT Paradatatail
                    {
                        parser_tracker("Paradata IDENT Paradatatail");
                    };

Paradatatail    : '[' ']' Paradatatails  // 这个可能也有问题
                    {
                        parser_tracker("Paradatatail [] Paradatatails");
                    }
                | Paradatatails
                    {
                        parser_tracker("Paradata Paradatatails");
                    };

Paradatatails   :
                    {}
                | '[' NUM ']' Paradatatails
                    {
                        parser_tracker("Paradatatails");
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
                        
                        parser_tracker("Subprogram Onestatement");
                    }
                | Subprogram Onestatement
                    {
                        // 当Subprogram有返回值即已经存在了Block并其中已有节点时，不需要新建节点
                        if ($1 != NULL)
                        {
                            if ($2 != NULL)
                                $1->add_sub_program($2);
                            $$ = $1;
                        }
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

                        parser_tracker("Subprogram Subprogram Onestatement");
                    };

// --完成--
Onestatement    : Localdef 
                    {
                        $$ = NULL;
                        parser_tracker("Onestatement Localdef");
                    }
                | Statement
                    {
                        $$ = $1;
                        parser_tracker("Onestatement Statement");
                    };

Localdef        : Type Defdata Deflist
                    {
                        struct def_vars * p_def_vars;

                        // 如果仅有一个变量声明，仍要创建一个结构体，统一形式嘛
                        if ($3 == NULL)
                        {
                            // 创建返回定义变量定义的结构体
                            p_def_vars = new struct def_vars();
                            // 将变量名指针数字全部初始化为NULL
                            for (int i = 0; i < VARS_SIZE; i++)
                                p_def_vars->p_names[i] = NULL;
                            p_def_vars->p_names[0] = $2;
                            $$ = p_def_vars;
                        }
                        // 否则已经把变量放到已经存在的结构体就好
                        else
                        {
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
                            p_def_vars = $3;
                        }

                        for (int i = VARS_SIZE - 1; i >= 0; i--)
                        {
                            if (p_def_vars->p_names[i] != NULL)
                            {
                                sym_table.put(p_def_vars->p_names[i], $1, yylineno);
                                // 因为符号表put实际上是创建了新的string对象，所以可以释放
                                free(p_def_vars->p_names[i]);
                            }
                        }
                        // 释放数组
                        free(p_def_vars);

                        $$ = NULL;
                        parser_tracker("Localdef");
                    }

// 语句Stmt部分
// --完成--    应该是，就是直接相等就可以了
Statement       : Whilestat
                    {
                        $$ = $1;
                        parser_tracker("Statement Whilestat");
                    }
                | Ifstat
                    {
                        $$ = $1;
                        parser_tracker("Statement Ifstat");
                    }
                | Breakstat
                    {
                        $$ = $1;
                        parser_tracker("Statement Breakstat");
                    }
                | Continuestat
                    {
                        $$ = $1;
                        parser_tracker("Statement Continuestat");
                    }
                | Returnstat
                    {
                        $$ = $1;
                        parser_tracker("Statement Returnstat");
                    }
                | Blockstat
                    {
                        $$ = $1;
                        parser_tracker("Statement Blockstat");
                    }
                | Assignstat
                    {
                        $$ = $1;
                        parser_tracker("Statement Assignstat");
                    }
                | Emptystat
                    {
                        $$ = $1;
                        parser_tracker("Statement Emptystat");
                    };

// --完成--
Breakstat       : BREAK ';'
                    {
                        $$ = new Break(yylineno);
                        parser_tracker("Breakstat");
                    };

// --完成--
Continuestat    : CONTINUE ';'
                    {
                        $$ = new Continue(yylineno);
                        parser_tracker("Continuestat");
                    };

Returnstat      : RETURN Altexpr ';'
                    {
                        parser_tracker("Returnstat");
                    };

// --完成--
Assignstat      : Altexpr ';'
                    {
                        $$ = $1;
                        parser_tracker("Assignstat Altexpr ;");
                    };

Blockstat       : '{' Subprogram '}'
                    {
                        $$ = $2;
                        parser_tracker("Blockstat Subprogram");
                    };

// --完成--
Emptystat       : ';'
                    { $$ = NULL; };

// --完成--
Whilestat       : WHILE '(' Expr ')' Statement
                    {
                        // 当while循环语句不使用括号包裹时，即直接是语句而非Block时，需要额外套一层Block
                        if ($5->get_node_type() != SynNode::BLOCK)
                        {
                            Block * p_block = new Block(yylineno);
                            p_block->add_sub_program($5);
                            $$ = new While($3, p_block, yylineno);
                        }
                        else
                            $$ = new While($3, (Block *) $5, yylineno);
                        
                        parser_tracker("Whilestat");
                    };

// --完成--
Ifstat          : IF  '(' Expr ')' Statement Elsestat
                    {
                        // 当if真条件不使用括号包裹时，即直接是语句而非Block时，需要额外套一层Block
                        if ($5->get_node_type() != SynNode::BLOCK)
                        {
                            Block * p_block = new Block(yylineno);
                            p_block->add_sub_program($5);
                            $$ = new If($3, p_block, $6, yylineno);
                        }
                        else
                            $$ = new If($3, (Block *) $5, $6, yylineno);
                        parser_tracker("Ifstat");
                    };

// --完成--
Elsestat        :
                    { $$ = NULL; }
                | ELSE Statement
                    {
                        $$ = new Else($2, yylineno);
                        parser_tracker("Elsestat");
                    };
// --完成--
// 表达式Expr
Altexpr         :
                    { $$ = NULL; }
                | Expr
                    {
                        $$ = $1;
                        parser_tracker("Altexpr");
                    };
// --完成--
Expr            : Assexpr
                    {
                        $$ = $1;
                        parser_tracker("Expr");
                    };
// --完成-- 可能
Assexpr         : Orexpr Asstail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Assexpr");
                    };
// --完成--
Asstail         :   { $$ = NULL; }
                | '=' Assexpr Asstail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Asstail");
                    };
// --完成--
Orexpr          : Andexpr Ortail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Orexpr");
                    };
// --完成--
Ortail          :   { $$ = NULL; }
                | OR Andexpr Ortail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Ortail");
                    };
// --完成--
Andexpr         : Cmpexpr Andtail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Andexpr");
                    };
// --完成--
Andtail         :   { $$ = NULL; }
                | AND Cmpexpr Andtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Andexpr");
                    };
// --完成--
Cmpexpr         : Aloexpr Cmptail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Cmpexpr");
                    };
// --完成--
Cmptail         :   { $$ = NULL; }
                | Cmps Aloexpr Cmptail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Cmptail");
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
                        parser_tracker("Aloexpr");
                    };
// --完成--
Alotail         :   { $$ = NULL; }
                | Addsub Item Alotail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Alotail");
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
                        parser_tracker("Item");
                    };
// --完成--
Itemtail        :   { $$ = NULL; }
                | Muldiv Factor Itemtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Itemtail");
                    };
// --完成--
Muldiv          : '*' { $$ = new Operator(Operator::BINARY_MUL); }
                | '/' { $$ = new Operator(Operator::BINARY_DIV); };
// --完成--
Factor          : Lop Factor
                    {
                        $$ = new Unary($2, $1, yylineno);
                        parser_tracker("Factor Lop Factor");
                    }
                | Val
                    {
                        $$ = $1;
                        parser_tracker("Factor Val");
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
                        parser_tracker("Val Elem");
                    }
                | Elem Rop
                    {
                        $$ = new Unary($1, $2, yylineno);
                        parser_tracker("Val Rop");
                    }
// --完成--
Rop             : INCR { $$ = new Operator(Operator::UNARY_INCR); }
                | DECR { $$ = new Operator(Operator::UNARY_DECR); };

Elem            : IDENT Idexpr
                    {
                        if ($2 == NULL)
                            $$ = new Variable($1, &sym_table, yylineno);
                        parser_tracker("Elem IDENT Idexpr");
                    }
                | '(' Expr')'
                    {
                        $$ = $2;
                        parser_tracker("Elem (Expr)");
                    }
                | Literal 
                    { 
                        $$ = $1; 
                        parser_tracker("Elem Literal"); 
                    };

Idexpr          :   { $$ = NULL; }
                | '[' Expr ']' 
                    {
                        parser_tracker("Idexpr [Expr]");
                    }
                | '(' Realarg ')'
                    {
                        parser_tracker("Idexpr (Realarg)");
                    }
// --完成--
Literal         : NUM
                    {
                        $$ = new Constant($1, yylineno);
                        parser_tracker("Literal");
                    }

Realarg         :  // 这是不是也可能有问题
                    {}
                | Arg Realargs
                    {
                        parser_tracker("Realarg");
                    }

Realargs        :
                    {}
                | ',' Arg Realargs
                    {
                        parser_tracker("Realargs");
                    }
// --完成--
Arg             : Expr
                    {
                        $$ = $1;
                        parser_tracker("Arg");
                    }
%%

// 其实好像不用了
void yyerror(const char * msg)
{
    printf("Line(%d): %s\n", yylineno, msg);
}