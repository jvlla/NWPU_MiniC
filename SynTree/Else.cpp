#include "Else.h"

Else::Else(SynNode * p_statement, int line): Stmt(line, SynNode::ELSE)
{
    this->p_statement_ = p_statement;
    if (this->p_statement_ != NULL)
        this->p_statement_->set_prev(this);
}

void Else::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
    if (this->p_statement_ != NULL)
        this->p_statement_->gen_graph(p_fout);
}

const Terminal * Else::gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const
{
    this->p_statement_->gen_ir(label_in, label_out, p_quad_table);

    return NULL;
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Else::get_node_content() const
{
    return "else";
}