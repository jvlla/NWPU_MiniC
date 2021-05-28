#include "Terminal.h"

// 这个因为都是叶子节点，所以构造时也就没有子节点不需要设置前驱了
Terminal::Terminal(int line): SynNode(line) {}

// 输出用于产生图的dot文件
void Terminal::gen_graph(std::ofstream * p_fout) const
{
    SynNode::gen_graph(p_fout);
}