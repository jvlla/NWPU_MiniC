#include "Return.h"
#include "SynTreeException.h"
#include "Terminal.h"
#include "TempVariable.h"
#include <string>

Return::Return(SynNode * p_ret_value, int line): Stmt(line, SynNode::RETURN)
{
    this->p_ret_value_ = p_ret_value;
    if (this->p_ret_value_ != NULL)
        this->p_ret_value_->set_prev(this);
}

void Return::gen_graph(std::ofstream * p_fout) const
{
    Stmt::gen_graph(p_fout);
    if (this->p_ret_value_ != NULL)
        this->p_ret_value_->gen_graph(p_fout);
}

const Terminal * Return::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    // 如果label_ret为-1未被设置，即return语句位于函数外（应该不可能）或函数翻译有误
    if (label_ret == -1)
        throw new SynTreeException("return statement in wrong place or wrong function translation"
            , SynNode::get_line());
    const Terminal * terminal_ret;
    std::string ret_val;

    // 如果单独return; 但函数非void
    if (this->p_ret_value_ == NULL && temp_ret != NULL)
        throw new SynTreeException("return nothing but isn't void function", SynNode::get_line());
    // 如果return xxx; 但函数为void
    else if (this->p_ret_value_ != NULL && temp_ret == NULL)
        throw new SynTreeException("return expr in void function", SynNode::get_line());
    // 如果return; 函数为void 什么也不做
    else if (this->p_ret_value_ == NULL && temp_ret == NULL)
        {}
    // 如果return xxx; 函数不为void 将函数返回值临时变量赋值
    else
    {
        terminal_ret = 
            this->p_ret_value_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        ret_val = terminal_ret->to_string();
        p_quad_table->add("=", ret_val, "", temp_ret->to_string());
    }
    p_quad_table->add_jump_label(label_ret);

    // return语句返回值不会用于赋值，可以直接为NULL
    return NULL;
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Return::get_node_content() const
{
    return "return";
}