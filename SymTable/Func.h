#ifndef __FUNC_H__
#define __FUNC_H__
#include "Type.h"

#define PARAMS_SIZE 10

class Func: public Type
{
  public:
    // 参数类型数组p_params_type必须首先全部初始化为NULL
    Func(type_set type, int types[PARAMS_SIZE]);
    // 用于在使用变量时判断使用是否合法
    virtual bool isLegal(Type * restrict) const;
    // 只用在输出图的时候打印数组值
    virtual std::string get_type_content() const;
  private:
    int types_[PARAMS_SIZE];
};

#endif