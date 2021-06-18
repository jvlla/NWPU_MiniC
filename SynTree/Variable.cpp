#include "Variable.h"
#include "../SymTable/Array.h"

Variable::Variable(std::string name, SymTable * p_sym_table, int line): Terminal(line, SynNode::VARIABLE)
{
    if (!p_sym_table->isExist(name))
        throw new SynTreeException("undefined variable " + name, SynNode::get_line());
    Type * p_type = p_sym_table->get_p_type(name);
    
    this->name_ = name;
    this->p_type_ = p_type;
}

Variable::Variable(std::string name, int * limit, SymTable * p_sym_table, int line): Terminal(line, VARIABLE)
{
    if (!p_sym_table->isExist(name))
        throw new SynTreeException("undefined variable " + name, SynNode::get_line());
    Type * p_type_new = new Array(limit);
    if (!p_type_new->isLegal(p_sym_table->get_p_type(name)))
        throw new SynTreeException("illegal type variable " + name, SynNode::get_line());
    
    this->name_ = name;
    this->p_type_ = p_type_new;
}

// 输出用于产生图的dot文件
void Variable::gen_graph(std::ofstream * p_fout) const
{
    Terminal::gen_graph(p_fout);
}

const Terminal * Variable::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table) const
{
    return this;
}

std::string Variable::to_string() const
{
    return this->name_;
}

std::string Variable::get_node_content() const
{
    std::string ret = this->name_;
    ret += this->p_type_->get_type_content();

    return ret;
}