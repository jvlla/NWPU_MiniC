#include "Func.h"

Func::Func(type_set type, int types[PARAMS_SIZE]): Type(type)
{
    for (int i = 0; i < PARAMS_SIZE; i++)
        this->types_[i] = types[i];
}

// 用于在使用变量时判断使用是否合法
bool Func::isLegal(Type * restrict) const
{
    if (!Type::isLegal(restrict))
        return false;
    
    for (int i = 0; i < PARAMS_SIZE; i++)
    {
        // 函数变量数量超过函数定义，不合法
        if (this->types_[i] != ((Func *)restrict)->types_[i])
            return false;
        // 两者长度匹配，在10维之前停止，合法
        else if (this->types_[i] == -1 && ((Func *)restrict)->types_[i] == -1)
            return true;
        else
            continue;
    }

    return true;
}

// 只用在输出图的时候打印数组值
std::string Func::get_type_content() const
{
    // 先这样
    return "()";
}