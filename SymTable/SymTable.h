#ifndef __SYM_TABLE__
#define __SYM_TABLE__
#include <string>
#include <vector>
#include "Type.h"

// 用于符号表记录，记录符号唯一id，名字，类型和定义行号
class SymTable
{
  public:
    SymTable();
    // 返回变量id值 放置失败（就是有重名）抛出异常
    int put(std::string name, Type * p_type, int scope, int line);
    // 返回bool值确定有没有同名变量
    bool isExist(std::string name);
    // 返回变量名对应的变量id
    int get_id(std::string name);
    // 返回变量id对应的变量名
    std::string get_name(int id);
    // 返回变量名对应的类型的指针
    Type * get_p_type(std::string name);
    // 返回变量名对应的类型的指针
    Type * get_p_type(int id);
    // 将符号表输出到文件
    void gen_table(std::ofstream * p_fout);
  private:
    static long s_id_;  // 唯一的变量编号，即id
    struct elem {
        int id;
        std::string name;
        Type * p_type;
        int scope;
        int line;
    };
    std::vector<elem> elems;
};

#endif