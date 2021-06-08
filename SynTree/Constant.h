#ifndef __CONSTANT_H__
#define __CONSTANT_H__
#include "Terminal.h"

class Constant: public Terminal
{
  public:
    // 先这样吧，回头如果有机会再扩展
    Constant(int value, int line);
    // 输出用于产生图的dot文件
    void gen_graph(std::ofstream * p_fout) const;
    // 并不输出四元式，只返回Terminal指针
    virtual const Terminal * gen_ir(int label_in, int label_out, QuadTable * p_quad_table) const;
    // 返回常量的string表示，为数字
    virtual std::string to_string() const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    std::string get_node_content() const;
  private:
    int value_;  // 常数的值，以后可以变成union，包括float什么的
    Type * p_type_;  // 常数类型，其实不需要吧，不过保险起见
};

#endif