#include "Type.h"

Type::Type(type_set type, int * limit)
{
    this->type_ = type;
    this->limit_ = limit;
}

// 用于在创建变量时判断，主要是为了数组，restrict是符号表里面的类型
bool Type::isLegal(Type * restrict)
{
    if (this->type_ != restrict->type_)
        return false;
    else if(this->type_ == INT)
        return true;
    else
    {
        for (int i = 0; i < ARR_SIZE; i++)
        {
            // 变量为度大于变量类型维度，不合法
            if (this->limit_[i] >= restrict->limit_[i])
                return false;
            // 变量维度小于变量类型维度，不合法
            else if (this->limit_[i] == -1 && restrict->limit_[i] != -1)
                return false;
            // 两者长度匹配，在10维之前停止，合法
            else if (this->limit_[i] == -1 && restrict->limit_[i] == -1)
                return true;
            else
                continue;
        }
        // 二者均为10维，合法
        return true;
    }
}

std::string Type::get_type_content()
{
    std::string ret = "";

    if (this->type_ == INT)
        ;
    else if (this->type_ == ARRAY)
        for (int i = 0; i < ARR_SIZE && this->limit_[i] != -1; i++)
            ret += "[" + std::to_string(this->limit_[i]) + "]";

    return ret;
}