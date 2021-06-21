#include "Block.h"
#include "Func.h"
#include "SynTreeException.h"
#include <iostream>
#include <vector>
#include <iostream>

Block::Block(int line): SynNode(line, SynNode::BLOCK) {}

Block::Block(Block * that, int line, SynNode::node_type_set node_type): SynNode(line, node_type)
{
    this->content_ = that->content_;
    this->sub_programs_.swap((that->sub_programs_));
    // 将block子节点保存过来后还需要设置前驱
    for(std::vector<SynNode *>::iterator it = this->sub_programs_.begin();
        it != this->sub_programs_.end(); it++)
        (*it)->set_prev(this);
    
    // 之前的Block节点就用不到了，可以释放
    free(that);
}

// 添加同一block下的其它语句、函数等
void Block::add_sub_program(SynNode * p_sub_program)
{
    if (p_sub_program != NULL)
    {
        this->sub_programs_.push_back(p_sub_program);
        p_sub_program->set_prev(this);
    }
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
        (this->sub_programs_)[i]->gen_graph(p_fout);
    }
}

// 这个和上边好像啊，能合并吗？好像不太行，函数指针什么类型也不一样，以后再研究吧
const Terminal * Block::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    // 如果是root节点（虽然这么判断实在不太好，万一有个Root函数就可能有问题）
    if (this->content_ == "root")
    {
        // std::cout << "in root" << std::endl;
        for (int i = 0; i < this->sub_programs_.size(); i++)
        {
            // std::cout << (this->sub_programs_)[i]->get_node_type() << std::endl;
            // std::cout << ((Block *)((this->sub_programs_)[i]))->get_node_content() << std::endl;
            // 如果该节点是Func且函数名是main
            if ((this->sub_programs_)[i]->get_node_type() == SynNode::FUNC
                && ((Block *)((this->sub_programs_)[i]))->get_node_content() == "Function main")
                {
                    // 先翻译main函数
                    (this->sub_programs_)[i]->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
                    break;
                }
        }
        for (int i = 0; i < this->sub_programs_.size(); i++)
        {
            // 如果该节点是Func且函数名是main
            if ((this->sub_programs_)[i]->get_node_type() == SynNode::FUNC
                && ((Block *)(this->sub_programs_)[i])->get_node_content() != "Function main")
                (this->sub_programs_)[i]->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        }
    }
    else
        for (int i = 0; i < this->sub_programs_.size(); i++)
            (this->sub_programs_)[i]->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);

    // 因为block只能出现在函数体、if真情况等处，可以返回NULL
    return NULL;
}

Func * Block::get_func(std::string func_name)
{
    if (this->content_ != "PROGRAM")
        throw new SynTreeException("wrong use in function call, this node isn't root node"
            , SynNode::get_line());
    
    for (int i = 0; i < this->sub_programs_.size(); i++)
    {
        // 先判断是否是Func节点
        if (this->sub_programs_[i]->get_node_type() == SynNode::FUNC)
        {
            // 再判断函数名是否相同
            if(((Func *) this->sub_programs_[i])->get_func_name() == func_name)
                return (Func *) this->sub_programs_[i];
        }
    }

    // 没找到返回NULL
    return NULL;
}

std::string Block::get_node_content() const
{
    return this->content_;
}
