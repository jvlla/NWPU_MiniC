#include "Type.h"

Type::Type(type_set type)
{
    this->type_ = type;
}

// 用于在创建变量时判断，主要是为了数组，restrict是符号表里面的类型
bool Type::isLegal(Type * restrict) const
{
    if (this->type_ != restrict->type_)
        return false;
    else
        return true;
}

Type::type_set Type::get_type()
{
    return this->type_;
}

std::string Type::get_type_content() const
{
    // 太坑了，string不能返回NULL，否则一旦用于赋值之类，会抛出异常，必须返回空字符串
    return "";
}