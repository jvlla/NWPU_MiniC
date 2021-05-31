#ifndef __OPERATOR_H__
#define __OPERATOR_H__
#include <string>

// 其实这个类没什么用，不过好像直接传
class Operator
{
  public:
    // 避免用保留关键字
    Operator(std::string the_operator);
    // 返回操作符的string表示
    std::string get_string();
  private:
    std::string operator_;
};

#endif