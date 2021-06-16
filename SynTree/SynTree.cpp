#include "SynTree.h"

SynTree::SynTree()
{
    this->p_block_ = new Block(0);
    this->p_block_->set_content("root");
}

// 获得所有树的根节点，是Block类型
Block * SynTree::get_root()
{
    return this->p_block_;
}

void SynTree::gen_graph(std::ofstream * p_fout, std::string grahp_name)
{
    *p_fout << "graph " << grahp_name << " {" << std::endl;
    this->p_block_->gen_graph(p_fout);
    *p_fout << "}" << std::endl;
}

void SynTree::gen_ir(QuadTable * p_quad_table)
{
    this->p_block_->gen_ir(-1, -1, -1, NULL, p_quad_table);
}