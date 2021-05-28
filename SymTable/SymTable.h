#ifndef __SYM_TABLE__
#define __SYM_TABLE__
#include <string>
#include <vector>
#include "Type.h"

class SymTable
{
  public:
    SymTable();
    // 返回变量id值 放置失败（就是有重名）抛出异常
    int put(std::string name, Type * p_tpye, int line);
    // 返回bool值确定有没有同名变量
    bool isExist(std::string name);
    // 返回变量名对应的变量id
    int get_id(std::string name);
    // 返回变量名对应的类型的指针
    Type * get_p_type(std::string name);
    // 将符号表输出到文件
    void gen_table(std::ofstream * p_fout);
  private:
    static long s_id_;  // 唯一的变量编号，即id
    struct elem {
        int id;
        std::string name;
        Type * p_type;
        int line;
    };
    std::vector<elem> elems;
};

#endif