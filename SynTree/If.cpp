#include "If.h"

If::If(SynNode * p_condition, Block * p_statement, Else * p_else, int line)
    :Stmt(line, SynNode::IF)
{
    this->p_condition_ = p_condition;
    this->p_condition_->set_prev(this);
    this->p_statement_ = p_statement;
    if (this->p_statement_ != NULL)
    {
        this->p_statement_->set_prev(this);
        this->p_statement_->set_content("true");
    }
        
    this->p_else_ = p_else;
    if (this->p_else_ != NULL)
        this->p_else_->set_prev(this);
}

void If::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
    this->p_condition_->gen_graph(p_fout);
    if (p_statement_ != NULL)
        this->p_statement_->gen_graph(p_fout);
    if (p_else_ != NULL)
        this->p_else_->gen_graph(p_fout);
}

const Terminal * If::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    long label[3];
    const Terminal * terminal_condition, * terminal_true, * terminal_false;
    std::string condition;

    if (this->p_else_ != NULL)
    {
        // 当真假条件共存时需要三个label
        for (int i = 0; i < 3; i++)
            label[i] = SynNode::get_new_label();
        // 翻译见曾老师PPT Ch05-4 P4
        terminal_condition = 
            this->p_condition_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        condition = terminal_condition->to_string();
        p_quad_table->add("JNZ", condition, "", "L" + std::to_string(label[0]));
        p_quad_table->add_jump_label(label[1]);
        p_quad_table->add_label(label[0]);
        // if条件并不能改变出入label，因为break或continue后跳转还是根据while的label的
        terminal_true = 
            this->p_statement_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        p_quad_table->add_jump_label(label[2]);
        p_quad_table->add_label(label[1]);
        // if条件并不能改变出入label，因为break或continue后跳转还是根据while的label的
        terminal_false = 
            this->p_else_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        p_quad_table->add_label(label[2]);
    }
    else
    {
        // 当只有真条件时，只需两个label
        for (int i = 0; i < 2; i++)
            label[i] = SynNode::get_new_label();
        terminal_condition = 
            this->p_condition_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        condition = terminal_condition->to_string();
        p_quad_table->add("JNZ", condition, "", "L" + std::to_string(label[0]));
        p_quad_table->add_jump_label(label[1]);
        p_quad_table->add_label(label[0]);
        // if条件并不能改变出入label，因为break或continue后跳转还是根据while的label的
        terminal_true = 
            this->p_statement_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        p_quad_table->add_label(label[1]);
    }
    
    // if语句返回值不会用于赋值，可以直接为NULL
    return NULL;
}

std::string If::get_node_content() const
{
    return "if";
}
