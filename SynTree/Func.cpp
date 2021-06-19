#include "Func.h"
#include "../SymTable/Type.h"
#include "SynTreeException.h"
#include <iostream>

Func::Func(Block * p_block, TypeFunc * p_type, std::string func_name, SymTable * p_sym_table, int line):
    Block(p_block, line, SynNode::FUNC)
{
    Block::set_content(func_name);
    this->p_type_ = p_type;
    if (this->p_type_->get_type() == Type::FUNC_INT)
        this->p_temp_ = new TempVariable(line);
    else
        this->p_temp_ = NULL;
    label_func_in = SynNode::get_new_label();
    label_func_out = SynNode::get_new_label();
    this->p_sym_table_ = p_sym_table;
}

void Func::gen_graph(std::ofstream * p_fout) const
{
    Block::gen_graph(p_fout);
}

// 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
const Terminal * Func::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret,
    QuadTable * p_quad_table)
{
    p_quad_table->add_label(label_func_in);
    // 因为传递的是指向TempVariable的指针，并且已经赋值，void函数就是NULL，所以不用分类可以直接传
    Block::gen_ir(label_in, label_out, label_func_out, this->p_temp_, p_quad_table);
    p_quad_table->add_label(label_func_out);
    p_quad_table->add("ret", "", "", "");

    // 因为func只能连接到root节点（类型为block），返回值不会使用，可以返回NULL
    return NULL;
}

std::string Func::get_func_name()
{
    return Block::get_node_content();
}

long Func::get_label_in()
{
    return this->label_func_in;
}

TypeFunc * Func::get_func_type()
{
    return this->p_type_;
}

// 返回函数返回Terminal
Terminal * Func::get_ret_terminal()
{
    return this->p_temp_;
}

std::string Func::get_node_content() const
{
    std::string ret;
    int * p_params_id;
    Type * p_param_type;
    std::string str_param;

    ret = Block::get_node_content();
    p_params_id = this->p_type_->get_params_type();
    ret += "(";
    for (int i = 0; i < PARAMS_SIZE; i++)
        if (p_params_id[i] != -1)
        {
            str_param = this->p_sym_table_->get_name(p_params_id[i]);
            ret += str_param;
            if (i != PARAMS_SIZE && p_params_id[i] != -1)
                ret += ", ";
        }
    ret += ")";

    return ret;
}

