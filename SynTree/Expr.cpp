#include "Expr.h"

long Expr::s_temp_count_ = 0;

Expr::Expr(int line): SynNode(line)
{
    this->temp_count_ = s_temp_count_;
    s_temp_count_++;
}

void Expr::gen_graph(std::ofstream * p_fout) const
{
    SynNode::gen_graph(p_fout);
}