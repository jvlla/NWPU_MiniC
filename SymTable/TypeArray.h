#ifndef __TYPE_ARRAY_H__
#define __TYPE_ARRAY_H__
#include "Type.h"

// 限制数组维度最高为10
#define ARR_SIZE 10

class TypeArray: public Type
{
  public:
    // 传入的维度数组limit必须都先初始化为-1
    TypeArray(int * p_limit);
    // 用于在使用变量时判断使用是否合法
    virtual bool isLegal(Type * restrict) const;
    // 只用在输出图的时候打印数组值
    virtual std::string get_type_content() const;
    // 返回维度数组
    int * get_dim_limits();
  private:
    int p_limit_[ARR_SIZE];
};

#endif