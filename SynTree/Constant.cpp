#include "Constant.h"

Constant::Constant(int value, int line): Terminal(line, SynNode::CONSTANT)
{
    this->value_ = value;
}

// 输出用于产生图的dot文件
void Constant::gen_graph(std::ofstream * p_fout) const
{
    Terminal::gen_graph(p_fout);
}

const Terminal * Constant::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    return this;
}

std::string Constant::to_string() const
{
    return std::to_string(this->value_);
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Constant::get_node_content() const
{
    return std::to_string(this->value_);
}