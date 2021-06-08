#ifndef __OPERATOR_H__
#define __OPERATOR_H__
#include <string>

//Operator类要用enum详细写出类型主要是为了进行短路求值，不过不一定能干到，希望有空做
class Operator
{
  public:
    // unary,单目运算符； binary,双目运算符
    //                  !          -            &              *
    enum operator_type {UNARY_NOT, UNARY_MINUS, UNARY_ADDRESS, UNARY_INDIRECTION,
    //++          --          =              +           -           *           /
      UNARY_INCR, UNARY_DECR, BINARY_ASSIGN, BINARY_ADD, BINARY_SUB, BINARY_MUL, BINARY_DIV,
    //>               <            >=                    <=
      BINARY_GREATER, BINARY_LESS, BINARY_GREATER_EQUAL, BINARY_LESS_EQUAL,
    //==            !=                &&          ||
      BINARY_EQUAL, BINARY_NOT_EQUAL, BINARY_AND, BINARY_OR};
    // 避免用保留关键字
    Operator(operator_type type);
    // 返回Operator类的类型
    operator_type get_type();
    // 返回操作符的string表示
    // 计划是只用在抽象语法树中，所以直接是返回对应符号，如果需要再弄个ir版的
    std::string to_string();
  private:
    operator_type type_;
};

#endif