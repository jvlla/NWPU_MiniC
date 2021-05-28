#ifndef __EXPR_H__
#define __EXPR_H__
#include "SynNode.h"

class Expr: public SynNode
{
  public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    Expr(int line);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // virtual void gen_ir(int label_in, int label_out) const = 0;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
  private:
    static long s_temp_count_;  // 翻译临时变量唯一id
    long temp_count_;
};

#endif