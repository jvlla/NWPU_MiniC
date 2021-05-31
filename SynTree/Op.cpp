#include "Op.h"

Op::Op(SynNode * p_first, SynNode * p_second, Operator * p_operator, int line): Expr(line)
{
    this->p_first_ = p_first;
    this->p_first_->set_prev(this);
    this->p_second_ = p_second;
    this->p_second_->set_prev(this);
    this->p_operator_ = p_operator;
}

// 输出用于产生图的dot文件
void Op::gen_graph(std::ofstream * p_fout) const
{
    Expr::gen_graph(p_fout);
    this->p_first_->gen_graph(p_fout);
    this->p_second_->gen_graph(p_fout);
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Op::get_node_content() const
{
    return this->p_operator_->get_string();
}