#include "helper.h"

extern int yylineno;

struct operator_node * operator_node_struct
    (Operator * p_operator, SynNode * p_node, struct operator_node * p_struct, int line)
{
    struct operator_node * p_operator_node = new struct operator_node();  // 返回值
    p_operator_node->p_operator = p_operator;

    // 如果右边仍有运算，即p_struct不为空
    if (p_struct != NULL)
    {
        // 因为node不为空，所以不用错误判断
        // 生成语法树上新的Op节点
        Op * p_op = new Op(p_node, p_struct->p_node, p_struct->p_operator, line);
        p_operator_node->p_node = p_op;

        free(p_struct);
    }
    else
        // 节点直接赋给返回值中节点
        p_operator_node->p_node = p_node;

    return p_operator_node;
}

SynNode * node_struct(SynNode * p_node, struct operator_node * p_struct, int line)
{
    SynNode * p_ret_node;

    if (p_struct != NULL)
        p_ret_node = new Op(p_node, p_struct->p_node, p_struct->p_operator, line);
    else
        p_ret_node = p_node;

    return p_ret_node;
}

void parser_tracker(std::string message)
{
#ifdef DEBUG
    std::cout << "Line(" << yylineno << "): " << message << std::endl;
#endif
}