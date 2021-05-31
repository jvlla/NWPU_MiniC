#include "Operator.h"

Operator::Operator(std::string the_operator)
{
    this->operator_ = the_operator;
}

// 返回操作符的string表示
std::string Operator::get_string()
{
    return this->operator_;
}