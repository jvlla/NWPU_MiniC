#ifndef __SYN_NODE__
#define __SYN_NODE__
#include <fstream>
#include "../SymTable/SymTable.h"

class SynNode
{
  public:
    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    SynNode(int line);
    // 设置当前节点前驱，每次创建新的更高级节点必须调用
    void set_prev(SynNode * p_prev);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // virtual void gen_ir(int label_in, int label_out) const = 0;
  protected:
    // 被gen_graph()调用，产生图中节点连线
    void emit_link(std::ofstream * p_fout) const; 
    // 被gen_graph()调用，产生图中节点
    void emit_node(std::ofstream * p_fout) const;
    // 被emit_xxx()调用，返回节点名字，形如Nxx
    std::string get_node_name() const;
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
  private:
    static long s_count_;  // 唯一节点编号
    long count_;  // 当前节点编号
    SynNode * p_prev_;
    int line_;  // 节点所在代码行

    // static long s_label_;  // 标签唯一id 放到stmt那里用
    // static long s_temp_;  // 翻译临时变量唯一id
};

#endif