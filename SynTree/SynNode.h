#ifndef __SYN_NODE__
#define __SYN_NODE__
#include <fstream>
#include "../SymTable/SymTable.h"
#include "../QuadTable.h"

// 前向声明，SynNode类要用到Terminal类，Terminal类也要用到SynNode类，
// 但头文件不能互相引用，只能这样，反正指针无所谓
class Terminal;
class TempVariable;

class SynNode
{
  public:
    // 存储节点类型的枚举类型，用于get_node_type()返回
    // 增加了新的还要记得在.cpp的gen_graph()的switch也加一下
    enum node_type_set {EXPR, OP, UNARY, TERMINAL, VARIABLE, CONSTANT, TEMP_VARIABLE,
        BLOCK, STMT, IF, ELSE, WHILE, BREAK, CONTINUE, RETURN, FUNC, FUNC_CALL};

    // 注意，每个构造函数都要调用传递过来的节点的set_prev()函数设定前驱
    SynNode(int line, node_type_set node_type);
    // 设置当前节点前驱，每次创建新的更高级节点必须调用
    void set_prev(SynNode * p_prev);
    // 输出用于产生图的dot文件
    // 每个具体类都要先调用SynNode::gen_graph用以生成自身节点，之后再深度优先遍历
    virtual void gen_graph(std::ofstream * p_fout) const;
    // 用于产生四元式的函数，每个节点依次递归调用，进行深度优先遍历
    // 传入开始、结束标签值，为了continue, break之类的可以跳
    // 返回值用于生成四元式，比如if (1 < 2)，这个 1 < 2 gen_ir()后返回 txx
    // 返回Terminal类型吧，要进行返回的一方是变量、常量或Expr(这个肯定返回临时变量)，都属于Terminal
    // 其它就返回NULL就好
    // label == -1时是异常值，比如最开始无处可跳的时候就可以用，但应该不用判断，正常情况传不到if这种能用到的地方
    virtual const Terminal * gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
        QuadTable * p_quad_table) const = 0;
    // 返回节点行号
    int get_line() const;
    // 返回节点类型枚举变量
    node_type_set get_node_type() const;
  protected:
    // 被gen_graph()调用，产生图中节点连线
    void emit_link(std::ofstream * p_fout) const; 
    // 被gen_graph()调用，产生图中节点
    void emit_node(std::ofstream * p_fout) const;
    // 被emit_xxx()调用，返回节点名字，形如Nxx
    std::string get_node_name() const;
    // 设置节点类型，只能被子类调用，还是要保持一定封装性，主要是Func节点的类型不好设置不然
    // 但也没用到，还是觉得，不删了，放在这里也可能有用的
    void set_node_type(node_type_set new_type);
    // 被emit_node()调用，返回可以在图中以文字显示的节点内容
    virtual std::string get_node_content() const = 0;
    // 获取新的label编号，用于进行中间表达式翻译。因为只有子类调用，放在protected
    // 这个可能不是const函数，因为修改了静态变量s_label_，但不加const肯定没法编译，也就算了
    long get_new_label() const;
  private:
    static long s_count_;  // 唯一节点编号
    static long s_label_;  // label唯一编号，基本各种节点都要用，就放在这里
    long count_;  // 当前节点编号
    SynNode * p_prev_;
    int line_;  // 节点所在代码行
    node_type_set node_type_;
};

#endif