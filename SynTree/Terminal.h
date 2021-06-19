#ifndef __TERMINAL_H__
#define __TERMINAL_H__
#include "SynNode.h"

class Terminal: public SynNode
{
  public:
    // 这个因为都是叶子节点，所以构造时也就没有子节点不需要设置前驱了
    Terminal(int line, SynNode::node_type_set node_type);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) = 0;
    // 返回各种变量、常量和临时变量的string表示
    virtual std::string to_string() const = 0;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
};

#endif