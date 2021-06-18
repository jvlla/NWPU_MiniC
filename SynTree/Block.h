#ifndef __BLOCK_H__
#define __BLOCK_H__
#include "SynNode.h"
#include <vector>

class Func;

class Block: public SynNode
{
  public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    Block(int line);
    // Func类调用该构造函数，提供已创建好的block对象
    Block(Block * that, int line, SynNode::node_type_set node_type);
    // 添加同一block下的其它语句、函数等
    void add_sub_program(SynNode * p_sub_program);
    // 设置图中节点内容，用在最开始写root，ifelse真假情况中间，还有函数名
    void set_content(std::string content);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const;
    Func * get_func(std::string func_name);
  protected:
    virtual std::string get_node_content() const;
  private:
    std::vector<SynNode *> sub_programs_;
    std::string content_;
};

#endif