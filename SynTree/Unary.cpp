#include "Unary.h"

Unary::Unary(SynNode * p_next, Operator * p_operator, int line): Expr(line)
{
    this->p_next_ = p_next;
    this->p_next_->set_prev(this);
    this->p_operator_ = p_operator;
}

// 输出用于产生图的dot文件
void Unary::gen_graph(std::ofstream * p_fout) const
{
    Expr::gen_graph(p_fout);
    this->p_next_->gen_graph(p_fout);
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Unary::get_node_content() const
{
    return this->p_operator_->get_string();
}