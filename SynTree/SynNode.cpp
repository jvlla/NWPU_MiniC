#include "SynNode.h"
#include "../common.h"

long SynNode::s_count_ = 0;
long SynNode::s_label_ = 0;

SynNode::SynNode(int line, SynNode::node_type_set node_type)
{
    this->count_ = s_count_;
    s_count_++;
    this->p_prev_ = NULL;
    this->line_ = line;
    this->node_type_ = node_type;
}

// 设置当前节点前驱，每次创建新的更高级节点必须调用
void SynNode::set_prev(SynNode * p_prev)
{
    this->p_prev_ = p_prev;
}

void SynNode::gen_graph(std::ofstream * p_fout) const
{
#ifdef DEBUG
    std::string node_type_str;
    switch(this->node_type_)
    {
        case SynNode::EXPR: node_type_str = "Expr"; break;
        case SynNode::OP: node_type_str = "Op"; break;
        case SynNode::UNARY: node_type_str = "Unary"; break;
        case SynNode::TERMINAL: node_type_str = "Terminal"; break;
        case SynNode::VARIABLE: node_type_str = "Variable"; break;
        case SynNode::CONSTANT: node_type_str = "Constant"; break;
        case SynNode::TEMP_VARIABLE: node_type_str = "TempVariable"; break;
        case SynNode::BLOCK: node_type_str = "Block"; break;
        case SynNode::STMT: node_type_str = "Stmt"; break;
        case SynNode::IF: node_type_str = "If"; break;
        case SynNode::ELSE: node_type_str = "Else"; break;
        case SynNode::WHILE: node_type_str = "While"; break;
        case SynNode::BREAK: node_type_str = "Break"; break;
        case SynNode::CONTINUE: node_type_str = "Continue"; break;
        case SynNode::RETURN: node_type_str = "Return"; break;
        case SynNode::FUNC: node_type_str = "Func"; break;
        case SynNode::FUNC_CALL: node_type_str = "FuncCall"; break;
    }
    std::cout << node_type_str << ": " << this->get_node_content() << std::endl;
#endif
    this->emit_node(p_fout);  // 先生成自己的节点，这样之后才能连起来
    this->emit_link(p_fout);  // 把自己和前驱连起来
}

int SynNode::get_line() const
{
    return this->line_;
}

SynNode::node_type_set SynNode::get_node_type() const
{
    return this->node_type_;
}

// 被gen_graph()调用，产生图中节点连线
void SynNode::emit_link(std::ofstream * p_fout) const
{
    if (this->p_prev_ != NULL)
        *p_fout << this->p_prev_->get_node_name() << " -- " << this->get_node_name() << std::endl;
}

// 被gen_graph()调用，产生图中节点
void SynNode::emit_node(std::ofstream * p_fout) const
{
    *p_fout << this->get_node_name() 
        << " [shape=box, label=\"" << this->get_node_content() << "\"]" << std::endl;
}

// 被emit_xxx()调用，返回节点名字，形如Nxx
std::string SynNode::get_node_name() const
{
    return "N" + std::to_string(this->count_);
}

void SynNode::set_node_type(node_type_set new_type)
{
    this->node_type_ = new_type;
}

long SynNode::get_new_label() const
{
    return s_label_++;
}
