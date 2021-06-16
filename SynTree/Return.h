#ifndef __RETURN_H__
#define __RETURN_H__
#include "Stmt.h"

// return 怎么根据函数是void或int检验有没有返回值？！ 好像就做不到啊
class Return: public Stmt
{
  public:
    Return(SynNode * p_ret_value, int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
    SynNode * p_ret_value_;
};

#endif