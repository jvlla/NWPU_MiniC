#ifndef __BREAK_H__
#define __BREAK_H__
#include "Stmt.h"

class Break: public Stmt
{
  public:
    Break(int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table);
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
};

#endif