#ifndef __VARIABLE_H__
#define __VARIABLE_H__
#include "Terminal.h"
#include "SynTreeException.h"
#include "../SymTable/Type.h"

// 数组变量四元式的不同是在Op那里翻译的，很不合适。也只翻译了+-*/=的情况。凑合能过检查测试就好
class Variable: public Terminal
{
  public:
    // 这个构造函数主要要检查变量是否合法，构造函数分两个版本，上面的是普通变量的，下面的数组类型的
    // 普通变量只要检查是否先声明过就好
    Variable(std::string name, SymTable * p_sym_table, int line);
    // 数组类型还要检查维数什么的类型是否符合，dim是数组调用的维度，不过因为文法简化了所以就只有1维其实
    Variable(std::string name, SymTable * p_sym_table, int dim, SynNode * p_dim, int line);
    // 输出用于产生图的dot文件
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 并不输出四元式，只返回Terminal指针
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table);
    // 返回变量的string表示，为名字name_
    virtual std::string to_string() const;
    // 这两个都是用来进行函数变量调用时被其他节点调用的，这个办法是很烂，但凑合吧，可算到最后的内容了
    // 到op, unary节点去判断进行不同的操作
    bool is_arr() ;
    const Terminal * get_dim_terminal();
    std::string get_name();
  protected:
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const;
  private:
    std::string name_;  // 变量名
    Type * p_type_;  // 变量类型
    bool is_array_;  // 标记是否为数组变量
    SynNode * p_dim_;  // 指向产生维度的节点
    const Terminal * p_dim_terminal_;
};

#endif