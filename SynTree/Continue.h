#ifndef __CONTINUE_H__
#define __CONTINUE_H__
#include "Stmt.h"

class Continue: public Stmt
{
  public:
    Continue(int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
};

#endif