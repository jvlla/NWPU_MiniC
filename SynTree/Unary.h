#ifndef __UNARY_H__
#define __UNARY_H__
#include "Expr.h"

class Unary: public Expr
{
    public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    Unary(SynNode * p_next, std::string operation, int line);
    // 输出用于产生图的dot文件
    void gen_graph(std::ofstream * p_fout) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    std::string get_node_content() const;
  private:
    SynNode * p_next_;
    std::string operation_;
};

#endif