#ifndef __QUAD_TABLE__
#define __QUAD_TABLE__
#include <vector>
#include <string>
#include <fstream>

// 四元式结果储存表
class QuadTable
{
    public:
      // 暂时不需要构造参数
      // QuadTable();
      // 向四元式列表中增加新的项
      void add(std::string op, std::string arg1, std::string arg2, std::string result);
      // 向四元式列表中增加新的label
      void add_label(long label_count);
      // 无条件跳转到lable
      void add_jump_label(long label_count);
      // 将四元式输出到文件
      void export_to_file(std::ofstream * p_fout);
    private:
      // 二维vector，其中每一一维vecotr都是op, arg1, arg2, result这样的四元式
      // 但好像没办法限制一维vector的大小为4，但反正私有变量没关系吧
      std::vector<std::vector<std::string>> quadruples_;
};

#endif