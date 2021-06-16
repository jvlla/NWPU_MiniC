#ifndef __FUNC_H__
#define __FUNC_H__
#include "Block.h"
#include <string>
#include "../SymTable/TypeFunc.h"
#include "TempVariable.h"

// 继承对象Block，因为Func节点大部分其实还是和Block一样，区别在于有了类型、gen_ir()不一样等，所以算继承
class Func: public Block
{
  public:
    Func(Block * p_block, TypeFunc * p_type, std::string func_name, int line);
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const;
  protected:
    virtual std::string get_node_content() const;
  private:
    TypeFunc * p_type_;
    TempVariable * p_temp_;  // 只有int函数有p_temp_
};

#endif