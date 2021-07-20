#include "common.h"
#include "lexer.h"
#include "parser.hpp"
#include "QuadTable.h"

using namespace std;
extern int yyparse (void);

SymTable g_sym_table;
SynTree g_syn_tree;

string process_file_name(string file_name);
void handle_exception(const exception * p_exception
    , ofstream * p_sym_table_stream, ofstream * p_graph_stream, ofstream * p_quad_table_stream
    , string sym_table_name, string dot_name, string quad_table_name);

int main(int argc, char *argv[])
{
    QuadTable quad_table;
    ofstream graph_stream, sym_table_stream, quad_table_stream;
    // file_name_full是带文件类型、完整路径的文件名，file_name_path是带路径的文件名，
    // file_name是只有名字的文件名，之后是分别用于不同的带完整路径、文件类型的文件名
    string file_name_full, file_name_path, file_name;
    string sym_table_name, dot_name, graph_name, quad_table_name;
    string command;  // 调用graphviz的命令
    string command_dot, command_graph; // 因为是直接执行命令所以带空格的文件名都要加上双引号
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
    quad_table_name = file_name_path + "_quad.txt";
    command_dot = process_file_name(dot_name);
    command_graph = process_file_name(graph_name);
    // 打开输出文件
    sym_table_stream.open(sym_table_name);
    graph_stream.open(dot_name);
    quad_table_stream.open(quad_table_name);
    if (!sym_table_stream || !graph_stream || !quad_table_stream)
    {
        cerr << "Can't open needed output file." << endl;
        exit(EXIT_FAILURE);
    }

    try
    {
        // 进行语法分析，生成抽象语法树
#ifdef DEBUG
        cout << "------------------------------------------------------In parser" << endl;
#endif
        yyparse();
        // 输出符号表、语法树和中间表达式
#ifdef DEBUG
        cout << "                                                   After parser" << endl;
        cout << "-------------------------------------------------In gen_table()" << endl;
#endif
        g_sym_table.gen_table(&sym_table_stream);
#ifdef DEBUG
        cout << "                                              After gen_table()" << endl;
        cout << "-------------------------------------------------In gen_graph()" << endl;
#endif
        g_syn_tree.gen_graph(&graph_stream, file_name);
#ifdef DEBUG
        cout << "                                              After gen_graph()" << endl;
        cout << "----------------------------------------------------In gen_ir()" << endl;
#endif
        g_syn_tree.gen_ir(&quad_table);
#ifdef DEBUG
        cout << "                                                 After gen_ir()" << endl;
#endif
        quad_table.export_to_file(&quad_table_stream);
        // 使用graphviz生成树
        command = "dot -Efontname=\"Microsoft Yahei\" -Tpng -o " + command_graph + " " + command_dot;
        system((char*)command.c_str());

        sym_table_stream.close();
        graph_stream.close();
        quad_table_stream.close();
        remove(dot_name.c_str());
    }
    catch(const SymTableException * p_sym_table_exception)
    {
        handle_exception(p_sym_table_exception, &sym_table_stream, &graph_stream, &quad_table_stream
            , sym_table_name, dot_name, quad_table_name);
    }
    catch(const SynTreeException * p_syn_tree_exception)
    {
        handle_exception(p_syn_tree_exception, &sym_table_stream, &graph_stream, &quad_table_stream
            , sym_table_name, dot_name, quad_table_name);
    }
    catch(const ParserException * p_parser_exception)
    {
        handle_exception(p_parser_exception, &sym_table_stream, &graph_stream, &quad_table_stream
            , sym_table_name, dot_name, quad_table_name);
    }
    catch(const LexerException * p_lexer_exception)
    {
        handle_exception(p_lexer_exception, &sym_table_stream, &graph_stream, &quad_table_stream
            , sym_table_name, dot_name, quad_table_name);
    }

    return 0;
}

string process_file_name(string file_name)
{
    string result;
    char * sub;
    const char * delim = "/";

    sub = strtok((char *) file_name.c_str(), delim);
    while (sub)
    {
        result += "\"" + ((string) sub) + "\"/";
        sub = strtok(NULL, delim);
    }
    // 删除最后多余的/
    result = result.substr(0, result.length() - 1);

    return result;
}

void handle_exception(const exception * p_exception
    , ofstream * p_sym_table_stream, ofstream * p_graph_stream, ofstream * p_quad_table_stream
    , string sym_table_name, string dot_name, string quad_table_name)
{
    cerr << p_exception->what() << endl;
    cerr << "Compile Failed!!!!!!" << endl;
    // 清除打开文件
    p_sym_table_stream->close();
    p_graph_stream->close();
    p_quad_table_stream->close();
    remove(sym_table_name.c_str());
    remove(dot_name.c_str());
    remove(quad_table_name.c_str());

    exit(EXIT_FAILURE);
}
