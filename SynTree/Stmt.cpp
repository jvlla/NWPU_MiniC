#include "Stmt.h"

Stmt::Stmt(int line, SynNode::node_type_set node_type): SynNode(line, node_type) {}

void Stmt::gen_graph(std::ofstream * p_fout) const
{
    SynNode::gen_graph(p_fout);
}