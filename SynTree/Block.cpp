#include "Block.h"
#include <iostream>

Block::Block(int line): SynNode(line) {}

// 添加同一block下的其它语句、函数等
void Block::add_sub_program(SynNode * p_sub_program)
{
    this->sub_programs_.push_back(p_sub_program);
    p_sub_program->set_prev(this);
}

// 设置图中节点内容，用在最开始写root，ifelse真假情况中间
void Block::set_content(std::string content)
{
    this->content_ = content;
}

void Block::gen_graph(std::ofstream * p_fout) const
{
    SynNode::gen_graph(p_fout);
    for (int i = 0; i < this->sub_programs_.size(); i++)
    {
        std::cout << std::to_string(i) << std::endl;
        (this->sub_programs_)[i]->gen_graph(p_fout);
    }
        
}

std::string Block::get_node_content() const
{
    return this->content_;
}