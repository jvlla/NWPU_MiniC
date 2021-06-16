#include "TypeFunc.h"

TypeFunc::TypeFunc(type_set type, int types[PARAMS_SIZE]): Type(type)
{
    this->type_ = type;
    for (int i = 0; i < PARAMS_SIZE; i++)
    {
        if (types[i] != -1)
            this->types_[i] = types[i];
        else
            break;
    }   
}

// 用于在使用变量时判断使用是否合法
bool TypeFunc::isLegal(Type * restrict) const
{
    if (!Type::isLegal(restrict))
        return false;
    
    for (int i = 0; i < PARAMS_SIZE; i++)
    {
        // 函数变量数量超过函数定义，不合法
        if (this->types_[i] != ((TypeFunc *)restrict)->types_[i])
            return false;
        // 两者长度匹配，在10维之前停止，合法
        else if (this->types_[i] == -1 && ((TypeFunc *)restrict)->types_[i] == -1)
            return true;
        else
            continue;
    }

    return true;
}

// 只用在输出图的时候打印数组值
std::string TypeFunc::get_type_content() const
{
    // 先这样
    return "()";
}