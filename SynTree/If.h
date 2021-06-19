#ifndef __IF_H__
#define __IF_H__
#include "Stmt.h"
#include "Else.h"
#include "Block.h"
#include "Terminal.h"

class If: public Stmt
{
  public:
    If(SynNode * p_condition, Block * p_statement, Else * p_else, int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table);
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    SynNode * p_condition_;  // if条件
    Block * p_statement_;  // 真条件执行语句，可以为NULL
    Else * p_else_;  // else语句，如果有的话，可以为NULL
};

#endif