#include "Block.h"
#include <iostream>

Block::Block(int line): SynNode(line, SynNode::BLOCK) {}

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
        // std::cout << std::to_string(i) << std::endl;
        // std::cout << "gen graph in root block" << std::endl;
        // std::cout << (this->sub_programs_)[i]->get_node_type() << std::endl;
        (this->sub_programs_)[i]->gen_graph(p_fout);
    }
}

// 这个和上边好像啊，能合并吗？好像不太行，函数指针什么类型也不一样，以后再研究吧
const Terminal * Block::gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const
{
    // 不需要对返回值进行什么操作，直接遍历然后深度优先就可以
    for (int i = 0; i < this->sub_programs_.size(); i++)
    {
        // std::cout << std::to_string(i) << std::endl;
        (this->sub_programs_)[i]->gen_ir(label_in, label_out, p_quad_table);
    }

    // 因为block只能出现在函数体、if真情况等处，可以返回NULL
    return NULL;
}

std::string Block::get_node_content() const
{
    return this->content_;
}