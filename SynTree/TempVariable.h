#ifndef __TEMP_VARIABLE_H__
#define __TEMP_VARIABLE_H__
#include <string>
#include "Terminal.h"

/* 其实TempVariable继承Terminal类不太合适，毕竟TempVariable不是语法树中的节点，
 * 但为了方便gen_ir()返回，这么用吧
 */
class TempVariable: public Terminal {
  public:
    TempVariable(int line);
    // gen_graph, gen_ir, emit_node只是为了能继承Terminal，不必要实现
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 并不输出四元式，只返回Terminal指针
    virtual Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const;
    // 返回临时变量的string表示，tXX
    virtual std::string to_string() const;
  protected:
    virtual std::string get_node_content() const;
  private:
    static long s_count_;  // 唯一临时变量编号
    long count_;  // 当前临时变量编号
};

#endif