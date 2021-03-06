%{
#include "common.h"
#include "lexer.h"
#include "parser.hpp"
#include "help.h"

using namespace std;

void yyerror(const char * msg);

extern SymTable g_sym_table;
extern SynTree g_syn_tree;
int g_scope = 1;
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
    struct single_def_var * p_singel_def_var;  // 传递单个变量定义的结构
    int * p_arr_limit;  // 传递int维度的数组
    struct var_params * p_var_params;  // 传递变量参数的结构体，面对如a[1], b(2, 3)这样的情况
    If * p_if;
    Else * p_else;
    int * p_params_def;  // 指向数组的指针，数组中存放的是变量声明的id
    int id;  // 声明变量id
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
%type<p_singel_def_var> Defdata
%type<p_arr_limit> Vardef
/* 函数参数 */
%type<p_params_def> Para Oneparas
%type<id> Onepara
/* paradata只是暂时当作char *，假设就没有数组作为函数参数 */
%type<name> Paradata
%type<p_node> Paradatatail Paradatatails

%type<p_block> Functail Blockstat 
/* 函数内部 */
%type<p_block> Subprogram
%type<p_def_vars> Localdef
%type<p_node> Onestatement
/* 语句部分 */
%type<p_node> Statement Breakstat Continuestat Returnstat Assignstat Emptystat Whilestat
%type<p_if> Ifstat
%type<p_else> Elsestat
/* 表达式部分 */
%type<p_node> Altexpr Expr Assexpr Orexpr Andexpr Cmpexpr
%type<p_node> Aloexpr Item Factor Val Elem Literal
%type<p_operator_node> Alotail Itemtail Cmptail Andtail Ortail Asstail
/*函数/数组调用参数*/
%type<p_var_params> Idexpr Realarg Realargs
%type<p_node> Arg
/* 操作符 */
%type<p_operator> '=' AND OR
%type<p_operator> Addsub Muldiv Lop Cmps Rop

%start  Program

%%
// --完成--
Program         : Segment
                    {
                        if (!$1->is_var_def)
                        {
                            // 当函数有函数体即为函数定义时
                            if ($1->p_def_func->p_body != NULL)
                            {
                                Func * p_func = 
                                    new Func($1->p_def_func->p_body, $1->p_def_func->p_type_func, $1->p_def_func->name, &g_sym_table, yylineno);
                                g_syn_tree.get_root()->add_sub_program(p_func);
                                $1->p_def_func->p_body->set_content($1->p_def_func->name);
                            }

                            free($1->p_def_func->name);
                            free($1->p_def_func);
                        }

                        free($1);
                        parser_tracker("Program->, Segment");
                    }
                | Program Segment
                    {
                        if (!$2->is_var_def)
                        {
                            // 当函数有函数体即为函数定义时
                            if ($2->p_def_func->p_body != NULL)
                            {
                                Func * p_func = 
                                    new Func($2->p_def_func->p_body, $2->p_def_func->p_type_func, $2->p_def_func->name, &g_sym_table, yylineno);

                                g_syn_tree.get_root()->add_sub_program(p_func);
                                $2->p_def_func->p_body->set_content($2->p_def_func->name);
                            }

                            free($2->p_def_func->name);
                            free($2->p_def_func);
                        }

                    free($2);
                        parser_tracker("Program->, Program Segment");
                    };

// --完成--
Segment         :  Type Def
                    {
                        // 变量声明
                        if ($2->is_var_def)
                        {
                            struct def_vars * p_def_vars = $2->p_def_vars;
                            struct single_def_var * p_singel_def_var;

                            // 倒叙遍历，因为变量放的时候是从后往前的
                            for (int i = VARS_SIZE - 1; i >= 0; i--)
                            {
                                if (p_def_vars->p_single_def_vars[i] != NULL)
                                {
                                    p_singel_def_var = p_def_vars->p_single_def_vars[i];
                                    // 如果是普通变量声明
                                    if (p_singel_def_var->dim_limit[0] == -1)
                                    {
                                        g_sym_table.put(p_singel_def_var->p_name, $1, 0, yylineno);
                                    }
                                    else
                                    {
                                        TypeArray * p_type_array = new TypeArray(p_singel_def_var->dim_limit);
                                        g_sym_table.put(p_singel_def_var->p_name, p_type_array, 0, yylineno);
                                    }

                                    // 因为符号表put实际上是创建了新的string对象，所以可以释放
                                    free(p_singel_def_var->p_name);
                                    free(p_def_vars->p_single_def_vars[i]);
                                }
                            }

                            // 释放数组
                            free(p_def_vars);
                        }
                        // 函数声明
                        else
                        {
                            TypeFunc * p_type_func;

                            // 函数只有两种类型：void和int，分开创建，因为type返回只能是普通的void或int
                            if ($1->get_type() == Type::INT)
                                p_type_func = new TypeFunc(Type::FUNC_INT, $2->p_def_func->param_ids);
                            else
                                p_type_func = new TypeFunc(Type::FUNC_VOID, $2->p_def_func->param_ids);
                            $2->p_def_func->p_type_func = p_type_func;
                            g_sym_table.put($2->p_def_func->name, p_type_func, 0, yylineno);
                        }

                        $$ = $2;
                        parser_tracker("Segment->, Type Def");
                    };

// --完成--
Type            :  INT
                    {
                        $$ = new Type(Type::INT);
                        parser_tracker("Type->, INT");
                    }
                |  VOID
                    {
                        $$ = new Type(Type::VOID);
                        parser_tracker("Type->, VOID");
                    };

Def             :  '*' IDENT Deflist
                    {
                        throw new ParserException("Unsupported variable type pointer", yylineno);
                        parser_tracker("Def-> * IDENT Deflist");
                    }
                |  IDENT Idtail
                    {
                        if($2->is_var_def)
                        {
                            struct def_vars * p_def_vars = $2->p_def_vars;
                            for (int i = 0; i < VARS_SIZE; i++)
                            {
                                if (p_def_vars->p_single_def_vars[i]->p_name == NULL)
                                {
                                    $2->p_def_vars->p_single_def_vars[i]->p_name = $1;
                                    break;
                                }
                                // 如果变量声明已达到VARS_SIZE限制大小，报错抛出异常
                                if (i == VARS_SIZE - 1 && p_def_vars->p_single_def_vars[i] != NULL)
                                    throw new ParserException(
                                        "The number of variable eclaration exceed limit " 
                                        + to_string(VARS_SIZE), yylineno);
                            }
                        }
                        else
                            $2->p_def_func->name = $1;

                        $$ = $2;
                        parser_tracker("Def-> IDENT Idtail");
                    };

Deflist         :  ',' Defdata Deflist
                    {
                        struct def_vars * p_def_vars;

                        if($3 == NULL)
                        {
                            p_def_vars = new struct def_vars();
                            for (int i = 0; i < VARS_SIZE; i++)
                                p_def_vars->p_single_def_vars[i] = NULL;
                        }
                        else
                            p_def_vars = $3;
                        // 放入新参数
                        for (int i = 0; i < VARS_SIZE; i++)
                        {
                            if (p_def_vars->p_single_def_vars[i] == NULL)
                            {
                                p_def_vars->p_single_def_vars[i] = $2;
                                break;
                            }
                            // 变量数达到上限
                            if (p_def_vars->p_single_def_vars[i] != NULL && i == VARS_SIZE - 1)
                                throw new ParserException("too many variables", yylineno);
                        }

                        $$ = p_def_vars;
                        parser_tracker("Deflist-> Defdata Deflist");
                    }
                | ';' 
                    { $$ = NULL; };

// 假设只有普通变量和数组变量
Defdata         :  IDENT Vardef
                    {
                        struct single_def_var * p_singel_def_var = new struct single_def_var();
                        int dims_num = 0;  // 用于逆序数组维度

                        p_singel_def_var->p_name = $1;
                        for (int i = 0; i < ARR_SIZE; i++)
                                p_singel_def_var->dim_limit[i] = -1;
                        
                        if ($2 != NULL)
                        {
                            // 先逆序维度
                            for (int i = 0; i < ARR_SIZE; i++)
                            {
                                if($2[i] != -1)
                                    dims_num++;
                                else
                                    break;
                            }
                            for (int i = 0; i < dims_num; i++)
                                p_singel_def_var->dim_limit[i] = $2[dims_num - 1 - i];

                            free $2;
                        }

                        $$ = p_singel_def_var;
                        parser_tracker("Defdata-> IDENT Vardef");
                    }
                |  '*' IDENT
                    {
                        parser_tracker("Defdata-> * IDENT");
                    };

Vardef          : 
                    { 
                        $$ = NULL; 
                    }
                |  '[' NUM ']' Vardef  // Vardef在后面写正好递归返回构建树一样的数组
                    {
                        int * p_arr_limit;

                        // 如果是最后一个参数，创建维度数组
                        if ($4 == NULL)
                        {
                            p_arr_limit = (int *) malloc(ARR_SIZE * sizeof(int));
                            for (int i = 0; i < ARR_SIZE; i++)
                                p_arr_limit[i] = -1;
                        }
                        else
                            p_arr_limit = $4;

                        // 放入新参数
                        for(int i = 0; i < ARR_SIZE; i++)
                        {
                            if(p_arr_limit[i] == -1)
                            {
                                p_arr_limit[i] = $2;
                                break;
                            }

                            // 如果数组维度到达上限，抛出异常
                            if(p_arr_limit[i] != -1 && i == ARR_SIZE - 1)
                                throw new ParserException("too many array dimensions", yylineno);
                        }
                        
                        $$ = p_arr_limit;
                        parser_tracker("Vardef-> [ NUM ] Vardef");
                    }

Idtail          :  Vardef Deflist
                    {
                        // 这里和Deflist的情况还不一样，因为Idetail的产生式中第一个是Vardef，
                        // Deflist的产生式中第一个是Defdata，其中可能包含Vardef
                        struct def * p_def = new struct def();
                        struct def_vars * p_def_vars;
                        struct single_def_var * p_singel_def_var;
                        int dims_num;

                        p_def->is_var_def = true;
                        if ($2 == NULL)
                        {
                            p_def_vars = new struct def_vars();
                            for (int i = 0; i < VARS_SIZE; i++)
                                p_def_vars->p_single_def_vars[i] = NULL;
                        }
                        else
                            p_def_vars = $2;
                        // 放入新参数
                        for (int i = 0; i < VARS_SIZE; i++)
                        {
                            if (p_def_vars->p_single_def_vars[i] == NULL)
                            {
                                p_singel_def_var = new struct single_def_var();
                                p_singel_def_var->p_name = NULL;
                                for (int i = 0; i < ARR_SIZE; i++)
                                    p_singel_def_var->dim_limit[i] = -1;
                                if ($1 != NULL)
                                {
                                    // 先逆序维度
                                    for (int i = 0; i < ARR_SIZE; i++)
                                    {
                                        if($1[i] != -1)
                                            dims_num++;
                                        else
                                            break;
                                    }
                                    for (int i = 0; i < dims_num; i++)
                                        p_singel_def_var->dim_limit[i] = $1[dims_num - 1 - i];
                                    free $1;
                                }
                                p_def_vars->p_single_def_vars[i] = p_singel_def_var;

                                break;
                            }
                            // 变量数达到上限
                            if (p_def_vars->p_single_def_vars[i] != NULL && i == VARS_SIZE - 1)
                                throw new ParserException("too many variables", yylineno);
                        }
                        p_def->p_def_vars = p_def_vars;

                        $$ = p_def;
                        parser_tracker("Idtail-> Vardef Deflist");
                    }
                |  '(' Para ')' Functail
                    {
                        struct def * p_def = new struct def();
                        struct def_func * p_def_func = new struct def_func();

                        p_def->is_var_def = false;
                        p_def->p_def_func = p_def_func;
                        p_def_func->p_body = $4;
                        if ($2 != NULL)
                            for (int i = 0; i < PARAMS_SIZE; i++)
                            {
                                // cout << $2[i] << endl;
                                p_def_func->param_ids[i] = $2[i];
                            }
                        else
                            for (int i = 0; i < PARAMS_SIZE; i++)
                                p_def_func->param_ids[i] = -1;

                        $$ = p_def;
                        g_scope++;
                        parser_tracker("Idtail-> (Para) Functail");
                    }

// --完成--
Functail        :  Blockstat
                    {
                        $$ = $1;
                        parser_tracker("Functail-> Blockstat");
                    }
                |  ';'
                    { $$ = NULL; };

Para            :           // 这个可能不对
                    { $$ = NULL; }
                | Onepara Oneparas
                    {
                        int * p_params_def, * p_params_order;
                        int params_num;  // 参数个数

                        // 如果该Oneparas是最后一个参数，创建指向参数的指针并初始化数组全部置-1
                        if ($2 == NULL)
                        {
                            p_params_def = (int *) malloc(PARAMS_SIZE * sizeof(int));
                            for (int i = 0; i < PARAMS_SIZE; i++)
                                p_params_def[i] = -1;
                        }
                        else
                            p_params_def = $2;
                        // 放入新参数
                        for (int i = 0; i < PARAMS_SIZE; i++)
                        {
                            if (p_params_def[i] == -1)
                            {
                                p_params_def[i] = $1;
                                break;
                            }
                            // 如果变量数已达到上限，抛出异常
                            if (p_params_def[i] != -1 && i == PARAMS_SIZE - 1)
                                throw new ParserException("too many parameters", yylineno);
                        }

                        // 因为参数放置是倒叙的，所以从后往前重新排序参数
                        p_params_order = (int *) malloc(PARAMS_SIZE * sizeof(int));
                        // 还是先全部置-1
                        for (int i = 0; i < PARAMS_SIZE; i++)
                            p_params_order[i] = -1;
                        // 计算共多少个
                        for (int i = 0; i< PARAMS_SIZE; i++)
                            if(p_params_def[i] != -1)
                                params_num++;
                            else
                                break;
                        // 仅对有效参数id转置
                        for (int i = 0; i < params_num; i++)
                            p_params_order[i] = p_params_def[params_num - 1 - i];
                        free(p_params_def);

                        $$ = p_params_order;
                        parser_tracker("Para-> Onepara Oneparas");
                    };

Oneparas        :
                    { $$ = NULL; }
                | ',' Onepara Oneparas
                    {
                        int * p_params_def;

                        // 如果该Oneparas是最后一个参数，创建指向参数的指针并初始化数组全部置-1
                        if ($3 == NULL)
                        {
                            p_params_def = (int *) malloc(PARAMS_SIZE * sizeof(int));
                            for (int i = 0; i < PARAMS_SIZE; i++)
                                p_params_def[i] = -1;
                        }
                        else
                            p_params_def = $3;

                        for (int i = 0; i < PARAMS_SIZE; i++)
                        {
                            if (p_params_def[i] == -1)
                            {
                                p_params_def[i] = $2;
                                break;
                            }
                            // 如果变量数已达到上限，抛出异常
                            if (p_params_def[i] != -1 && i == PARAMS_SIZE - 1)
                                throw new ParserException("too many parameters", yylineno);
                        }
                        
                        $$ = p_params_def;
                        parser_tracker("Oneparas-> , Onepara Oneparas");
                    };

Onepara         : Type Paradata
                    {
                        $$ = g_sym_table.put($2, $1, g_scope, yylineno);
                        parser_tracker("Onepara-> Type Paradata");
                    };

Paradata        : '*' IDENT
                    {
                        parser_tracker("Paradata-> * IDENT");
                    }
                | IDENT Paradatatail
                    {
                        // 直接不考虑数组的情况
                        $$ = $1;
                        parser_tracker("Paradata-> IDENT Paradatatail");
                    };

Paradatatail    : '[' ']' Paradatatails  // 这个可能也有问题
                    {
                        parser_tracker("Paradatatail-> [] Paradatatails");
                    }
                | Paradatatails
                    {
                        $$ = $1;
                        parser_tracker("Paradata-> Paradatatails");
                    };

Paradatatails   :
                    { $$ = NULL; }
                | '[' NUM ']' Paradatatails
                    {
                        parser_tracker("Paradatatails-> [ NUM ] Paradatatails");
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
                        
                        parser_tracker("Subprogram-> Onestatement");
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

                        parser_tracker("Subprogram-> Subprogram Onestatement");
                    };

// --完成--
Onestatement    : Localdef 
                    {
                        $$ = NULL;
                        parser_tracker("Onestatement-> Localdef");
                    }
                | Statement
                    {
                        $$ = $1;
                        parser_tracker("Onestatement-> Statement");
                    };

Localdef        : Type Defdata Deflist
                    {
                        struct def_vars * p_def_vars;
                        struct single_def_var * p_singel_def_var;

                        // 如果仅有一个变量声明，仍要创建一个结构体，统一形式嘛
                        if ($3 == NULL)
                        {
                            // 创建返回定义变量定义的结构体
                            p_def_vars = new struct def_vars();
                            for (int i = 0; i < VARS_SIZE; i++)
                                p_def_vars->p_single_def_vars[i] = NULL;
                        }
                        else
                            p_def_vars = $3;

                        for (int i = 0; i < VARS_SIZE; i++)
                        {
                            if (p_def_vars->p_single_def_vars[i] == NULL)
                            {
                                p_def_vars->p_single_def_vars[i] = $2;
                                break;
                            }
                            // 变量数达到上限
                            if (p_def_vars->p_single_def_vars[i] != NULL && i == VARS_SIZE - 1)
                                throw new ParserException("too many variables", yylineno);
                        }

                        for (int i = VARS_SIZE - 1; i >= 0; i--)
                        {
                            if (p_def_vars->p_single_def_vars[i] != NULL)
                            {
                                p_singel_def_var = p_def_vars->p_single_def_vars[i];

                                // 如果是普通变量声明
                                if (p_singel_def_var->dim_limit[0] == -1)
                                {
                                    g_sym_table.put(p_singel_def_var->p_name, $1, g_scope, yylineno);
                                }
                                else
                                {
                                    TypeArray * p_type_array = new TypeArray(p_singel_def_var->dim_limit);
                                    g_sym_table.put(p_singel_def_var->p_name, p_type_array, g_scope, yylineno);
                                }

                                // 因为符号表put实际上是创建了新的string对象，所以可以释放
                                free(p_singel_def_var->p_name);
                                free(p_def_vars->p_single_def_vars[i]);
                            }
                        }
                        // 释放数组
                        free(p_def_vars);

                        $$ = NULL;
                        parser_tracker("Localdef-> Type Defdata Deflist");
                    }

// 语句Stmt部分
// --完成--    应该是，就是直接相等就可以了
Statement       : Whilestat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Whilestat");
                    }
                | Ifstat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Ifstat");
                    }
                | Breakstat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Breakstat");
                    }
                | Continuestat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Continuestat");
                    }
                | Returnstat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Returnstat");
                    }
                | Blockstat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Blockstat");
                    }
                | Assignstat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Assignstat");
                    }
                | Emptystat
                    {
                        $$ = $1;
                        parser_tracker("Statement-> Emptystat");
                    };

// --完成--
Breakstat       : BREAK ';'
                    {
                        $$ = new Break(yylineno);
                        parser_tracker("Breakstat-> BREAK ;");
                    };

// --完成--
Continuestat    : CONTINUE ';'
                    {
                        $$ = new Continue(yylineno);
                        parser_tracker("Continuestat-> CONTINUE ;");
                    };

// --完成--
Returnstat      : RETURN Altexpr ';'
                    {
                        $$ = new Return($2, yylineno);
                        parser_tracker("Returnstat-> RETURN Altexpr ;");
                    };

// --完成--
Assignstat      : Altexpr ';'
                    {
                        $$ = $1;
                        parser_tracker("Assignstat-> Altexpr ;");
                    };

// --完成--
Blockstat       : '{' Subprogram '}'
                    {
                        $$ = $2;
                        parser_tracker("Blockstat-> { Subprogram }");
                    };

// --完成--
Emptystat       : ';'
                    { $$ = NULL; };

// --完成--
Whilestat       : WHILE '(' Expr ')' Statement
                    {
                        // 当循环语句为空时
                        if ($5 == NULL)
                        {
                            Block * p_block = new Block(yylineno);
                            $$ = new While($3, p_block, yylineno);
                        }
                        // 当while循环语句不使用括号包裹时，即直接是语句而非Block时，需要额外套一层Block
                        else if ($5->get_node_type() != SynNode::BLOCK)
                        {
                            Block * p_block = new Block(yylineno);
                            p_block->add_sub_program($5);
                            $$ = new While($3, p_block, yylineno);
                        }
                        else
                            $$ = new While($3, (Block *) $5, yylineno);
                        
                        parser_tracker("Whilestat-> WHILE ( Expr ) Statement");
                    };

// --完成--
Ifstat          : IF  '(' Expr ')' Statement Elsestat
                    {
                        // 当真条件语句为空时
                        if ($5 == NULL)
                        {
                            Block * p_block = new Block(yylineno);
                            $$ = new If($3, p_block, $6, yylineno);
                        }
                        // 当if真条件不使用括号包裹时，即直接是语句而非Block时，需要额外套一层Block
                        else if ($5->get_node_type() != SynNode::BLOCK)
                        {
                            Block * p_block = new Block(yylineno);
                            p_block->add_sub_program($5);
                            $$ = new If($3, p_block, $6, yylineno);
                        }
                        else
                            $$ = new If($3, (Block *) $5, $6, yylineno);
                        parser_tracker("Ifstat-> IF ( Expr ) Statement Elsestat");
                    };

// --完成--
Elsestat        :
                    { $$ = NULL; }
                | ELSE Statement
                    {
                        $$ = new Else($2, yylineno);
                        parser_tracker("Elsestat-> ELSE Statement");
                    };

// --完成--
Altexpr         :
                    { $$ = NULL; }
                | Expr
                    {
                        $$ = $1;
                        parser_tracker("Altexpr-> Expr");
                    };

// --完成--
Expr            : Assexpr
                    {
                        $$ = $1;
                        parser_tracker("Expr-> Assexpr");
                    };

// --完成--
Assexpr         : Orexpr Asstail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Assexpr-> Orexpr Asstail");
                    };

// --完成--
Asstail         :   { $$ = NULL; }
                | '=' Assexpr Asstail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Asstail-> = Assexpr Asstail");
                    };

// --完成--
Orexpr          : Andexpr Ortail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Orexpr-> Andexpr Ortail");
                    };

// --完成--
Ortail          :   { $$ = NULL; }
                | OR Andexpr Ortail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Ortail-> OR Andexpr Ortail");
                    };

// --完成--
Andexpr         : Cmpexpr Andtail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Andexpr-> Cmpexpr Andtail");
                    };

// --完成--
Andtail         :   { $$ = NULL; }
                | AND Cmpexpr Andtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Andexpr-> AND Cmpexpr Andtail");
                    };

// --完成--
Cmpexpr         : Aloexpr Cmptail
                    {
                        $$ = node_struct($1, $2, yylineno);
                        parser_tracker("Cmpexpr-> Aloexpr Cmptail");
                    };

// --完成--
Cmptail         :   { $$ = NULL; }
                | Cmps Aloexpr Cmptail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Cmptail-> Cmps Aloexpr Cmptail");
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
                        parser_tracker("Aloexpr-> Item Alotail");
                    };

// --完成--
Alotail         :   { $$ = NULL; }
                | Addsub Item Alotail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Alotail-> Addsub Item Alotail");
                    };

// 之后这些应该就是用来算数的了
// --完成--
Addsub          : '+' { $$ = new Operator(Operator::BINARY_ADD); }
                | '-' { $$ = new Operator(Operator::BINARY_SUB); };

// --完成--
Item            : Factor Itemtail
                    {
                        if ($2 != NULL)
                            $$ = new Op($1, $2->p_node, $2->p_operator, yylineno);
                        else
                            $$ = $1;
                        parser_tracker("Item-> Factor Itemtail");
                    };

// --完成--
Itemtail        :   { $$ = NULL; }
                | Muldiv Factor Itemtail
                    {
                        $$ = operator_node_struct($1, $2, $3, yylineno);
                        parser_tracker("Itemtail-> Muldiv Factor Itemtail");
                    };

// --完成--
Muldiv          : '*' { $$ = new Operator(Operator::BINARY_MUL); }
                | '/' { $$ = new Operator(Operator::BINARY_DIV); };

// --完成--
Factor          : Lop Factor
                    {
                        $$ = new Unary($2, $1, yylineno);
                        parser_tracker("Factor-> Lop Factor");
                    }
                | Val
                    {
                        $$ = $1;
                        parser_tracker("Factor-> Val");
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
                        parser_tracker("Val-> Elem");
                    }
                | Elem Rop
                    {
                        $$ = new Unary($1, $2, yylineno);
                        parser_tracker("Val-> Elem Rop");
                    }

// --完成--
Rop             : INCR { $$ = new Operator(Operator::UNARY_INCR); }
                | DECR { $$ = new Operator(Operator::UNARY_DECR); };

Elem            : IDENT Idexpr
                    {
                        if ($2 != NULL)
                        {
                            if ($2->is_func_call)
                            {
                                Block * p_root;
                                Func * p_func;
                                long func_label_in;
                                TypeFunc * p_func_type;
                                Terminal * p_func_terminal;

                                // 从root节点找函数节点，办法是很烂，但凑合用吧，要来不及了
                                p_root = g_syn_tree.get_root();
                                p_func = p_root->get_func($1);
                                if (p_func == NULL)
                                    throw new ParserException("Can't find function " + (string) $1 + " when function call"
                                        , yylineno);
                                func_label_in = p_func->get_label_in();
                                p_func_type = p_func->get_func_type();
                                p_func_terminal = p_func->get_ret_terminal();

                                if($2->is_func_call)
                                    $$ = new FuncCall($1, $2->p_params_nodes
                                        , p_func_type, func_label_in, p_func_terminal, &g_sym_table, yylineno);
                            }
                            else
                            {
                                $$ = new Variable($1, &g_sym_table, 1, $2->p_dim_expr, yylineno);
                            }
                        }
                        else
                            $$ = new Variable($1, &g_sym_table, yylineno);
                        parser_tracker("Elem-> IDENT Idexpr");
                    }
                | '(' Expr')'
                    {
                        $$ = $2;
                        parser_tracker("Elem-> (Expr)");
                    }
                | Literal 
                    { 
                        $$ = $1; 
                        parser_tracker("Elem-> Literal"); 
                    };

Idexpr          :   { $$ = NULL; }
                | '[' Expr ']' 
                    {
                        struct var_params * p_var_params = new var_params();
                        p_var_params->is_func_call = false;
                        p_var_params->p_dim_expr = $2;

                        $$ = p_var_params;
                        parser_tracker("Idexpr-> [Expr]");
                    }
                | '(' Realarg ')'
                    {
                        $$ = $2;
                        parser_tracker("Idexpr-> (Realarg)");
                    }

// --完成--
Literal         : NUM
                    {
                        $$ = new Constant($1, yylineno);
                        parser_tracker("Literal-> NUM");
                    }

Realarg         :  // 这是不是也可能有问题
                    { $$ = NULL; }
                | Arg Realargs
                    {
                        struct var_params * p_var_params, * p_var_params_order;
                        int params_num = 0;

                        if ($2 == NULL)
                        {
                            p_var_params = new struct var_params();
                            p_var_params->is_func_call = true;
                            for (int i = 0; i < PARAMS_SIZE; i++)
                                p_var_params->p_params_nodes[i] = NULL;
                        }
                        else
                            p_var_params = $2;

                        for (int i = 0; i < PARAMS_SIZE; i++)
                        {
                            if (p_var_params->p_params_nodes[i] == NULL)
                            {
                                p_var_params->p_params_nodes[i] = $1;
                                break;
                            }
                            // 如果变量数已达到上限，抛出异常
                            if (p_var_params->p_params_nodes[i] != NULL && i == PARAMS_SIZE - 1)
                                throw new ParserException("too many parameters", yylineno);
                        }

                        // 因为参数放置是倒叙的，所以从后往前重新排序参数
                        p_var_params_order = new struct var_params();
                        p_var_params_order->is_func_call = true;
                        // 还是先全部置NULL
                        for (int i = 0; i < PARAMS_SIZE; i++)
                            p_var_params_order->p_params_nodes[i] = NULL;
                        // 计算共多少个
                        for (int i = 0; i< PARAMS_SIZE; i++)
                            if(p_var_params->p_params_nodes[i] != NULL)
                                params_num++;
                            else
                                break;
                        // 仅对有效参数id转置
                        for (int i = 0; i < params_num; i++)
                            p_var_params_order->p_params_nodes[i] = p_var_params->p_params_nodes[params_num - 1 - i];
                        free(p_var_params);
                        
                        $$ = p_var_params_order;
                        parser_tracker("Realarg-> Arg Realargs");
                    }

Realargs        :
                    { $$ = NULL; }
                | ',' Arg Realargs
                    {
                        if ($2 == NULL)
                            throw new ParserException(
                                "need a parameter between two comma in function call", yylineno);
                        struct var_params * p_var_params;

                        if ($3 == NULL)
                        {
                            p_var_params = new struct var_params();
                            p_var_params->is_func_call = true;
                            for (int i = 0; i < PARAMS_SIZE; i++)
                                p_var_params->p_params_nodes[i] = NULL;
                        }
                        else
                            p_var_params = $3;

                        for (int i = 0; i < PARAMS_SIZE; i++)
                        {
                            if (p_var_params->p_params_nodes[i] == NULL)
                            {
                                p_var_params->p_params_nodes[i] = $2;
                                break;
                            }
                            // 如果变量数已达到上限，抛出异常
                            if (p_var_params->p_params_nodes[i] != NULL && i == PARAMS_SIZE - 1)
                                throw new ParserException("too many parameters", yylineno);
                        }

                        $$ = p_var_params;
                        parser_tracker("Realargs-> , Arg Realargs");
                    }

// --完成--
Arg             : Expr
                    {
                        $$ = $1;
                        parser_tracker("Arg-> Expr");
                    }
%%

// 其实好像不用了
void yyerror(const char * msg)
{
    printf("Line(%d): %s\n", yylineno, msg);
}
