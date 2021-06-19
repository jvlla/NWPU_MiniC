#include "SymTable.h"
#include "SymTableException.h"
#include <fstream>

long SymTable::s_id_ = 0;

SymTable::SymTable() {}

// 返回变量id值 放置失败（就是有重名）抛出异常
int SymTable::put(std::string name, Type * p_type, int line)
{
    if (this->isExist(name))
        throw new SymTableException("deplicated " + name, -1);
    
    int id_new = this->s_id_;
    s_id_++;
    elem elem_new = {id_new, name, p_type, line};
    this->elems.push_back(elem_new);

    return id_new;
}

// 返回bool值确定有没有同名变量
bool SymTable::isExist(std::string name)
{
    for (int i = 0; i < this->elems.size(); i++)
    {
        if (elems[i].name == name)
            return true;
    }

    return false;
}

// 返回变量名对应的变量id
int SymTable::get_id(std::string name)
{
    for (int i = 0; i < this->elems.size(); i++)
    {
        if (elems[i].name == name)
            return elems[i].id;
    }

    // 没有抛出异常
    throw new SymTableException("unexisted " + name, -1);
}

std::string SymTable::get_name(int id)
{
    if (id < 0 || id > this->elems.size())
        throw new SymTableException("illeagle variable id " + std::to_string(id), -1);
    
    return this->elems[id].name;
}

// 返回变量名对应的类型的指针
Type * SymTable::get_p_type(std::string name)
{
    for (int i = 0; i < this->elems.size(); i++)
    {
        if (elems[i].name == name)
            return elems[i].p_type;
    }

    // 没有抛出异常
    throw new SymTableException("unexisted " + name, -1);
}

// 返回变量名对应的类型的指针
Type * SymTable::get_p_type(int id)
{
    if (id < 0 || id > this->elems.size())
        throw new SymTableException("illeagle variable id " + std::to_string(id), -1);
    
    return this->elems[id].p_type;
}

void SymTable::gen_table(std::ofstream * p_fout)
{
    std::string type;

    *p_fout << "ID\tTOKEN\tTYPE\t\tLINE" << std::endl;
    for (int i = 0; i < this->elems.size(); i++)
    {
        switch(elems[i].p_type->get_type())
        {
            case Type::INT:
                type = "int\t\t"; 
                break;
            case Type::VOID:
                type = "void\t\t";  
                break;
            case Type::ARRAY:
                type = "int array" + elems[i].p_type->get_type_content() + "\t"; 
                break;
            case Type::FUNC_INT:
                type = "int function\t"; 
                break;
            case Type::FUNC_VOID:
                type = "void function\t";
                break;
            default:
                type = "\t";
        }

        *p_fout << elems[i].id << "\t" << elems[i].name << "\t" << type << elems[i].line << std::endl;
    }
}