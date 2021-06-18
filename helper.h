/*
 * 重要注意事项：为确保结构体在定义函数外仍可用，所有的结构体都需要指针声明，new分配空间（或malloc），
 * 关键是用完了要free！！！！！！ （当然了其实不free也无所谓，但指针new是必须的）
 * 然后每个结构体里面的指向数组的指针都要全部初始化为NULL或-1！！！！！！ 非常重要，保证后续判断的正确性
 */
#include "common.h"

// 已经在SymTable/Type.h里面定义过了，所以就不再定义
// #define PARMAS_SIZE 10  // 函数最多有10个参数
#define VARS_SIZE 10  // 一次最多声明10个变量

// 结构体中包含指向Operator, SynNode的指针，类似 + a 的意思
struct operator_node {
    Operator * p_operator;
    SynNode * p_node;
};

// 用于传递函数和变量的声明（没有函数的定义，这个返回只用来填符号表）
// 但有个问题，如果函数自身递归调用，调用时这个结构体还没返回，也就没有定义，会出错。不过，不会这么刁钻吧……
struct def {
    bool is_var_def;  // ==true传递的是变量声明，==false传递的是函数声明
    union
    {
        struct def_func * p_def_func;
        struct def_vars * p_def_vars;
    };
};

// 传递函数定义结构体
struct def_func {
    TypeFunc * p_type_func;  // 函数类型
    char * name;  // 函数名
    int param_ids[PARAMS_SIZE];  // 符号表中形参的id号，最多10个
    Block * p_body;  // 函数体中的变量
};

// 传递变量定义结构体
// 肯定将来还要为了指针改
struct def_vars {
    struct single_def_var *p_single_def_vars[VARS_SIZE];
};

// 传递单个变量定义的结构体
struct single_def_var {
    char * p_name;
    int dim_limit[ARR_SIZE];
};

struct var_params {
    bool is_func_call;  // 函数调用或数组调用
    union
    {
        SynNode *p_params_nodes[PARAMS_SIZE];  // 存储了临时变量的指针数组
    };
};

// 所有接收的指向节点的指针都必须是SynNode *, 因为进来的不一定是Op还是Variable等节点
// 返回的节点根据情况可以具体一些，不必须是SynNode *
// 接收指向Operator, SynNode, 结构体的指针，返回指向结构体的指针和行号
// 结构体中包含操作符，类似 + a 的意思
struct operator_node * operator_node_struct
    (Operator * p_operator, SynNode * p_node, struct operator_node * p_struct, int line);

// 接收指向SynNode, 结构体的指针和行号，返回指向Op的指针
// 类似 a + b 这样，所以最后可以归约为一个Op节点
SynNode * node_struct(SynNode * p_node, struct operator_node * p_struct, int line);

void parser_tracker(std::string message);