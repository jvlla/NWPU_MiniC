#ifndef __FUNC_CALL_H__
#define __FUNC_CALL_H__
#include "Expr.h"
// 包含这各头文件就是为了拿到PARAMS_SIZE常量
#include "../SymTable/TypeFunc.h"

class FuncCall: public Expr
{
  public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    FuncCall(std::string func_name, SynNode *p_params_nodes[PARAMS_SIZE]
        , TypeFunc * p_func_type, long func_labe_in, Terminal * p_func_terminal, 
        SymTable * p_sym_table, int line);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    std::string func_name_;
    TypeFunc * p_func_type_;
    long func_labe_in_;
    Terminal * p_func_terminal_;
    SymTable * p_sym_table_;
    SynNode * p_params_nodes_[PARAMS_SIZE];
};

#endif