#include <string>
#include "SynTree/SynNode.h"
#include "SynTree/Operator.h"
#include "SynTree/Op.h"

// 结构体中包含指向Operator, SynNode的指针，类似 + a 的意思
struct operator_node {
    Operator * p_operator;
    SynNode * p_node;
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