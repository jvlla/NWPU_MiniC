#include "While.h"

While::While(SynNode * p_condition, Block * p_statement, int line): Stmt(line, SynNode::WHILE)
{
    this->p_condition_ = p_condition;
    this->p_condition_->set_prev(this);
    this->p_statement_ = p_statement;
    if (this->p_statement_ != NULL)
    {
        this->p_statement_->set_prev(this);
        this->p_statement_->set_content("true");
    }
}

void While::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
    this->p_condition_->gen_graph(p_fout);
    if (p_statement_ != NULL)
        this->p_statement_->gen_graph(p_fout);
}

const Terminal * While::gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const
{
    long label[3];
    const Terminal * terminal_condition, * terminal_loop;
    std::string condition;

    for (int i = 0; i < 3; i++)
        label[i] = SynNode::get_new_label();
    // 翻译见曾老师PPT Ch05-4 P6
    p_quad_table->add_label(label[0]);
    terminal_condition = this->p_condition_->gen_ir(label_in, label_out, p_quad_table);
    condition = terminal_condition->to_string();
    p_quad_table->add("JNZ", condition, "", "L" + std::to_string(label[1]));
    p_quad_table->add_jump_label(label[2]);
    p_quad_table->add_label(label[1]);
    // while语句中，label_in为label[0], label_out为label[2]
    if (this->p_statement_ != NULL)
        terminal_loop = this->p_statement_->gen_ir(label[0], label[2], p_quad_table);
    p_quad_table->add_jump_label(label[0]);
    p_quad_table->add_label(label[2]);

    // while语句返回值不会用于赋值，可以直接为NULL
    return NULL;
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string While::get_node_content() const
{
    return "while";
}
