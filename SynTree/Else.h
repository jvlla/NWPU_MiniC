#ifndef __ELSE_H__
#define __ELSE_H__
#include "Stmt.h"

class Else: public Stmt
{
  public:
    Else(SynNode * p_statement, int line);
    void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    SynNode * p_statement_;  // else执行语句，可以为NULL
};

#endif