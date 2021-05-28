#ifndef __TERMINAL_H__
#define __TERMINAL_H__
#include "SynNode.h"

class Terminal: public SynNode
{
  public:
    // 这个因为都是叶子节点，所以构造时也就没有子节点不需要设置前驱了
    Terminal(int line);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // virtual void gen_ir(int label_in, int label_out) const = 0;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
  private:
    static long s_temp_count_;  // 翻译临时变量唯一id
    long temp_count_;
};

#endif