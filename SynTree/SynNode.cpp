#include "SynNode.h"

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
    this->emit_node(p_fout);  // 先生成自己的节点，这样之后才能连起来
    this->emit_link(p_fout);  // 把自己和前驱连起来
}

SynNode::node_type_set SynNode::get_node_type()
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