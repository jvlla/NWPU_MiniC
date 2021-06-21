#include "TempVariable.h"

long TempVariable::s_count_ = 0;

TempVariable::TempVariable(int line): Terminal(line, SynNode::TEMP_VARIABLE)
{
    this->count_ = s_count_;
    s_count_++;
}

// 返回临时变量的string表示，Txx
std::string TempVariable::to_string() const
{
    return "t" + std::to_string(count_);
}

void TempVariable::gen_graph(std::ofstream * p_fout) const {}

Terminal * TempVariable::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    return NULL;
}

std::string TempVariable::get_node_content() const{ return NULL; }
