#ifndef __SYN_TREE__
#define __SYN_TREE__
#include "Block.h"
#include <fstream>

class SynTree
{
  public:
    SynTree();
    // 获得所有树的根节点，是Block类型
    Block * get_root();
    // 从根节点递归输出图
    void gen_graph(std::ofstream * p_fout, std::string grahp_name);
  private:
    Block * p_block_;
};

#endif