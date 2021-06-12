#ifndef __STMT_H__
#define __STMT_H__
#include "SynNode.h"

// 虚类，其实没什么用，但还是弄一个，万一以后有需要的可以抽象出来的共同点呢
class Stmt: public SynNode
{
  public:
    Stmt(int line, SynNode::node_type_set node_type);
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
    virtual const Terminal * gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const = 0;
  protected:
    virtual std::string get_node_content() const = 0;
};

#endif