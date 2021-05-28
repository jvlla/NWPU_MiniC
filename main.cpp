#include "common.h"
#include "lexer.h"
#include "parser.hpp"

extern int yyparse (void);

SymTable sym_table;
SynTree syn_tree;
ofstream graph_stream, sym_table_stream;

int main(int argc, char *argv[])
{
    // file_name_full是带文件类型、完整路径的文件名，file_name_path是带路径的文件名，
    // file_name是只有名字的文件名，之后是分别用于不同的带完整路径、文件类型的文件名
    string file_name_full, file_name_path, file_name, sym_table_name, dot_name, graph_name;
    string command;  // 调用graphviz的命令
    int pos_point, pos_slash;
    
    // 如果没有提供输入文件
    if (argc == 1)
    {
        yyin = stdin;
        file_name_path = "std_input";
    }
    else
    {
        if((yyin = fopen(argv[1],"r")) == NULL)
        {
            cerr << "Can't open file " << argv[1] << endl;
            exit(EXIT_FAILURE);
        }
        file_name_full = argv[1];
        pos_point = file_name_full.find_last_of(".");
        file_name_path = file_name_full.substr(0, pos_point);
    }

    // 从file_name_path最后一个/之后选出作为file_name
    pos_slash = file_name_path.find_last_of("//");
    if (pos_slash != -1)
        file_name = file_name_path.substr(pos_slash + 1, file_name.length() - pos_slash - 1);
    else
        file_name = file_name_path;
    // 这些文件名都是带路径的组合上不同的后半部分文件名、后缀
    sym_table_name = file_name_path + "_symbol_table.txt";
    dot_name = file_name_path + ".dot";
    graph_name = file_name_path + ".png";
    graph_stream.open(dot_name);
    sym_table_stream.open(sym_table_name);

    yyparse();
    syn_tree.gen_graph(&graph_stream, file_name);
    sym_table.gen_table(&sym_table_stream);
    // 使用graphviz生成树
    command = "dot -Efontname=\"Microsoft Yahei\" -Tpng -o " + graph_name + " " + dot_name;
    system((char*)command.c_str());

    return 0;
}
