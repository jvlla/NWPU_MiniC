#ifndef __TYPE_H__
#define __TYPE_H__
#include <string>

class Type
{
  public:
    enum type_set {INT, VOID, ARRAY, FUNC_INT, FUNC_VOID};
    // 这个int数组不用复制，记得要malloc分配，之后所有的值置为-1
    Type(type_set type);
    // 用于在使用变量时判断使用是否合法
    virtual bool isLegal(Type * restrict) const;
    // 返回类型
    type_set get_type();
    // 只用在输出图的时候打印数组值
    virtual std::string get_type_content() const;
  private:
    type_set type_;
};

#endif