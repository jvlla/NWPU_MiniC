#include "TypeArray.h"

TypeArray::TypeArray(int * limit): Type(Type::ARRAY)
{
    for (int i = 0; i < ARR_SIZE; i++)
        this->p_limit_[i] = limit[i];
}

// 用于在使用变量时判断使用是否合法
bool TypeArray::isLegal(Type * restrict) const
{
    if (!Type::isLegal(restrict))
        return false;
    
    for (int i = 0; i < ARR_SIZE; i++)
    {
        // 变量维度大于变量类型维度，不合法
        if (this->p_limit_[i] >= ((TypeArray *)restrict)->p_limit_[i])
            return false;
        // 变量维度小于变量类型维度，不合法
        else if (this->p_limit_[i] == -1 && ((TypeArray *)restrict)->p_limit_[i] != -1)
            return false;
        // 两者长度匹配，在10维之前停止，合法
        else if (this->p_limit_[i] == -1 && ((TypeArray *)restrict)->p_limit_[i] == -1)
            return true;
        else
            continue;
    }
    // 二者均为10维，合法
    return true;
}

// 只用在输出图的时候打印数组值
std::string TypeArray::get_type_content() const
{
    std::string ret = "";
    for (int i = 0; i < ARR_SIZE && this->p_limit_[i] != -1; i++)
        ret += "[" + std::to_string(this->p_limit_[i]) + "]";

    return ret;
}

// 返回维度数组
int * TypeArray::get_dim_limits()
{
    return this->p_limit_;
}
