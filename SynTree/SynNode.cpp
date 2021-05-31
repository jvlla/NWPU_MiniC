#include "SynNode.h"

long SynNode::s_count_ = 0;

SynNode::SynNode(int line)
{
    this->count_ = s_count_;
    s_count_++;
    this->p_prev_ = NULL;
    this->line_ = line;
}

void SynNode::gen_graph(std::ofstream * p_fout) const
{
    this->emit_node(p_fout);  // 先生成自己的节点，这样之后才能连起来
    this->emit_link(p_fout);  // 把自己和前驱连起来
}

// 设置当前节点前驱，每次创建新的更高级节点必须调用
void SynNode::set_prev(SynNode * p_prev)
{
    this->p_prev_ = p_prev;
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