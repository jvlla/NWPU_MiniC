#ifndef __TYPE_H__
#define __TYPE_H__
#include <string>

#define ARR_SIZE 10

class Type
{
  public:
    enum type_set {INT, ARRAY};
    // 这个int数组不用复制，记得要malloc分配，之后所有的值置为-1
    Type(type_set type, int * limit);
    // 用于在创建变量时判断，主要是为了数组，restrict是符号表里面的类型
    bool isLegal(Type * restrict);
    // 只用在输出图的时候打印数组值
    std::string get_type_content();
  private:
    type_set type_;
    int * limit_;
};

#endif