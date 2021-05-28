#include "Unary.h"

Unary::Unary(SynNode * p_next, std::string operation, int line): Expr(line)
{
    this->p_next_ = p_next;
    this->p_next_->set_prev(this);
    this->operation_ = operation;
}

// 输出用于产生图的dot文件
void Unary::gen_graph(std::ofstream * p_fout) const
{
    this->p_next_->gen_graph(p_fout);
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Unary::get_node_content() const
{
    return this->operation_;
}