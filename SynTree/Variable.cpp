#include "Variable.h"
#include "../SymTable/TypeArray.h"
#include <iostream>

Variable::Variable(std::string name, SymTable * p_sym_table, int line): Terminal(line, SynNode::VARIABLE)
{
    if (!p_sym_table->isExist(name))
        throw new SynTreeException("undefined variable " + name, SynNode::get_line());
    Type * p_type = p_sym_table->get_p_type(name);
    
    this->name_ = name;
    this->p_type_ = p_type;
    this->is_array_ = false;
    this->p_dim_ = NULL;
}

Variable::Variable(std::string name, SymTable * p_sym_table, int dim, SynNode * p_dim, int line)
    : Terminal(line, SynNode::VARIABLE)
{
    if (!p_sym_table->isExist(name))
        throw new SynTreeException("undefined variable " + name, SynNode::get_line());
    Type * p_define_type;
    int * p_dims;  // 符号表中数组维度数组
    
    // 这些是对数组类型进行判断，其实全是扯淡
    p_define_type = p_sym_table->get_p_type(name);
    if (p_define_type->get_type() != Type::ARRAY)
        throw new SynTreeException("use normal variable " + name + " as array variable"
            , SynNode::get_line());
    p_dims = ((TypeArray *) p_define_type)->get_dim_limits();
    // 如果符号表中的数组变量没有维度或维度大于等于2
    if ((p_dims[0] == -1) || (p_dims[0] != -1 && p_dims[1] != -1))
        throw new SynTreeException("can only use linear array, can't use " + name
            , SynNode::get_line());
    
    this->name_ = name;
    this->p_type_ = p_define_type;
    this->is_array_ = true;
    this->p_dim_ = p_dim;
    this->p_dim_->set_prev(this);
}

// 输出用于产生图的dot文件
void Variable::gen_graph(std::ofstream * p_fout) const
{
    Terminal::gen_graph(p_fout);
    if (this->is_array_)
        this->p_dim_->gen_graph(p_fout);
}

const Terminal * Variable::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    if (this->is_array_)
        this->p_dim_terminal_ = 
            this->p_dim_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);

    return this;
}

std::string Variable::to_string() const
{
    return this->name_;
}

bool Variable::is_arr()
{
    return this->is_array_;
}

const Terminal * Variable::get_dim_terminal()
{
    return this->p_dim_terminal_;
}

std::string Variable::get_name()
{
    return this->name_;
}

std::string Variable::get_node_content() const
{
    std::string ret = this->name_;
    if (this->is_array_)
        ret += "[]";

    return ret;
}
