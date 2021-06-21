#include "Continue.h"
#include <iostream>

Continue::Continue(int line): Stmt(line, SynNode::CONTINUE)  {}

void Continue::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
}

const Terminal * Continue::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    p_quad_table->add_jump_label(label_in);

    // continue语句返回值不会用于赋值，可以直接为NULL
    return NULL;
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Continue::get_node_content() const
{
    return "continue";
}
