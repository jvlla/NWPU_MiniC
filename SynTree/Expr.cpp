#include "Expr.h"

Expr::Expr(int line, SynNode::node_type_set node_type): SynNode(line, node_type)
{
    this->p_temp_ = new TempVariable(line);
}

TempVariable * Expr::get_temp_variable() const
{
    return this->p_temp_;
}

void Expr::gen_graph(std::ofstream * p_fout) const
{
    SynNode::gen_graph(p_fout);
}

void Expr::quad_if_else(std::string arg_1, std::string arg_2, std::string result, std::string jump_instr,
        QuadTable * p_quad_table) const
{
    long label[3];
    for (int i = 0; i < 3; i++)
        label[i] = SynNode::get_new_label();
    // 这个翻译确实没啥好说的，if-else就这么翻，见曾老师PPT ch05-4 P4
    p_quad_table->add(jump_instr, arg_1, arg_2, "L" + std::to_string(label[0]));
    p_quad_table->add_jump_label(label[1]);
    p_quad_table->add_label(label[0]);
    p_quad_table->add("=", "1", "", result);
    p_quad_table->add_jump_label(label[2]);
    p_quad_table->add_label(label[1]);
    p_quad_table->add("=", "0", "", result);
    p_quad_table->add_label(label[2]);
}
