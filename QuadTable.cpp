#include "QuadTable.h"
#include <iomanip>

// 向四元式列表中增加新的项
void QuadTable::add(std::string op, std::string arg1, std::string arg2, std::string result)
{
    this->quadruples_.push_back({op, arg1, arg2, result});
}

void QuadTable::add_label(long label_count)
{
    this->quadruples_.push_back({"Label", "", "", "L" + std::to_string(label_count)});
}

void QuadTable::add_jump_label(long label_count)
{
    this->quadruples_.push_back({"J", "", "", "L" + std::to_string(label_count)});
}

void QuadTable::export_to_file(std::ofstream * p_fout)
{
    std::vector<int> tempVec;

    //     vector<vector<int>> vec(5, vector<int>(6, 0));
    // int i,j;
    // for (i = 0; i < vec.size(); i++)
    // {
    //     for(j = 0; j < vec[i].size(); j++)
    //         cout << vec[i][j] << " ";
    //     cout << endl;
    // }
    // 用迭代器好像搞不定逗号，回头再看吧
    for(std::vector<std::vector<std::string>>::iterator it_outer = this->quadruples_.begin(); 
        it_outer != this->quadruples_.end(); it_outer++)
    {
        *p_fout << "(";
        // 这里判断条件的花活是为了能最后不多输一个逗号
        for(std::vector<std::string>::iterator it_inner = it_outer->begin(); 
            it_inner != it_outer->end();  it_inner++)
        {
            // 如果没有参数，传入空字符串""，但为了让四元式和PPT上一致，填入-
            // 应该可以用setw()对齐的，但空格、字母和等号等不等长，还是对不齐……
            if (*it_inner != "")
                // *p_fout << std::setw(5) << *it_inner;
                *p_fout << *it_inner;
            else 
                // *p_fout << std::setw(5) << "-";
                *p_fout << "-";
            if ((it_inner + 1) != it_outer->end())
                *p_fout << ", ";
        }
        *p_fout << ")" << std::endl;
    }
}