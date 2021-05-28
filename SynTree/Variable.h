#ifndef __VARIABLE_H__
#define __VARIABLE_H__
#include "Terminal.h"
#include "SynTreeException.h"
#include "../SymTable/Type.h"

class Variable: public Terminal
{
  public:
    // 这个构造函数主要要检查变量是否合法，构造函数分两个版本，上面的是普通变量的，下面的数组类型的
    // 普通变量只要检查是否先声明过就好
    Variable(std::string name, SymTable * p_sym_table, int line);
    // 数组类型还要检查维数什么的类型是否符合
    // 数组变量多传一个维度数组，反正只有一种数组，也不用分什么了
    Variable(std::string name, int * limit, SymTable * p_sym_table, int line);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    std::string name_;
    Type * p_type_;
};

#endif