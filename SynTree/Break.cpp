#include "Break.h"

Break::Break(int line): Stmt(line, SynNode::BREAK) {}

void Break::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
}

const Terminal * Break::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table) const
{
    p_quad_table->add_jump_label(label_out);
    
    // break语句返回值不会用于赋值，可以直接为NULL
    return NULL;
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Break::get_node_content() const
{
    return "break";
}