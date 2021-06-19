#ifndef __WHILE_H__
#define __WHILE_H__
#include "Stmt.h"
#include "Block.h"
#include "Terminal.h"

class While: public Stmt
{
  public:
    While(SynNode * p_condition, Block * p_statement, int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table);
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    SynNode * p_condition_;  // 判断条件
    Block * p_statement_;  // 条件为真执行语句，可以为NULL
};

#endif