#ifndef __EXPR_H__
#define __EXPR_H__
#include "SynNode.h"
#include "TempVariable.h"

class Expr: public SynNode
{
  public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    Expr(int line, SynNode::node_type_set node_type);
    // 输出用于产生图的dot文件
    TempVariable * get_temp_variable() const;
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const = 0;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
    // 由于表达式中如>, !等很多都要使用短路求值，用类似if-else的方式翻译，因此将其做成一个函数方便使用
    // 接收进行互相判断的参数arg_1，arg_2以及该表达式向上一级传递的结果reslut和跳转指令，均为string形式
    // 进行的if-else运算均类似 if(arg1 操作 arg2) result = 1 else result = 0, 注意先1后0
    void quad_if_else(std::string arg_1, std::string arg_2, std::string result, std::string jump_instr,
        QuadTable * p_quad_table) const;
  private:
    TempVariable * p_temp_;  // 每个Expr都有临时变量，t1 = a + b 这样算的
};

#endif