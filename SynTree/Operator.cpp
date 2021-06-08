#include "Operator.h"
#include "SynTreeException.h"

Operator::Operator(Operator::operator_type type)
{
    this->type_ = type;
}

Operator::operator_type Operator::get_type()
{
    return this->type_;
}

// 返回操作符的string表示
std::string Operator::to_string()
{
    std::string ret;

    // 返回操作符对应符号
    switch (this->type_)
    {
        case Operator::UNARY_NOT:
            ret = "!";
            break;
        case Operator::UNARY_MINUS:
            ret = "-";
            break;
        case Operator::UNARY_ADDRESS:
            ret = "&";
            break;
        case Operator::UNARY_INDIRECTION:
            ret = "*";
            break;
        case Operator::UNARY_INCR:
            ret = "++";
            break;
        case Operator::UNARY_DECR:
            ret = "--";
            break;
        case Operator::BINARY_ASSIGN:
            ret = "=";
            break; 
        case Operator::BINARY_ADD:
            ret = "+";
            break;
        case Operator::BINARY_SUB:
            ret = "-";
            break;
        case Operator::BINARY_MUL:
            ret = "*";
            break;
        case Operator::BINARY_DIV:
            ret = "/";
            break;
        case Operator::BINARY_GREATER:
            ret = ">";
            break;
        case Operator::BINARY_LESS:
            ret = "<";
            break;
        case Operator::BINARY_GREATER_EQUAL:
            ret = ">=";
            break;
        case Operator::BINARY_LESS_EQUAL:
            ret = "<=";
            break;
        case Operator::BINARY_EQUAL:
            ret = "==";
            break;
        case Operator::BINARY_NOT_EQUAL:
            ret = "!=";
            break;
        case Operator::BINARY_AND:
            ret = "&&";
            break;
        case Operator::BINARY_OR:
            ret = "||";
            break;
        default:
            throw new SynTreeException("Illegal operator type");
            break;
    }

    return ret;
}