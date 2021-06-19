#include "FuncCall.h"
#include <iostream>
#include "SynTreeException.h"

FuncCall::FuncCall(std::string func_name, SynNode *p_params_nodes[PARAMS_SIZE]
        , TypeFunc * p_func_type, long func_labe_in, Terminal * p_func_terminal, 
        SymTable * p_sym_table, int line): Expr(line, SynNode::FUNC_CALL)
{
    int * p_params_id;
    Type * p_call_params_type, * p_func_params_type;

    this->func_name_ = func_name;
    this->p_func_type_ = p_func_type;
    this->func_labe_in_ = func_labe_in;
    this->p_func_terminal_ = p_func_terminal;
    this->p_sym_table_ = p_sym_table;
    p_params_id = this->p_func_type_->get_params_type();
    for (int i = 0; i < PARAMS_SIZE; i++)
    {
        this->p_params_nodes_[i] = p_params_nodes[i];
        // 当两边都没有值，什么都不用做
        if (p_params_id[i] == -1 && this->p_params_nodes_[i] == NULL)
            ;
        // 当都有值，进行参数检查
        else if (p_params_id[i] != -1 && this->p_params_nodes_[i] != NULL)
        {
            // 不做了吧，反正值目前情况也只能是int，类型检查太折磨了，算了
        }
        // 当两边一边有值一边没值
        else
        {
            std::cout << p_params_id[i] << std::endl;
            std::cout << this->p_params_nodes_[i] << std::endl;
            throw new SynTreeException("unmatched parmater number", SynNode::get_line());
        }

        if (this->p_params_nodes_[i] != NULL)
            this->p_params_nodes_[i]->set_prev(this);
    }
}

// 输出用于产生图的dot文件
void FuncCall::gen_graph(std::ofstream * p_fout) const
{
    Expr::gen_graph(p_fout);
    for (int i = 0; i < PARAMS_SIZE; i++)
        if (this->p_params_nodes_[i] != NULL)
            this->p_params_nodes_[i]->gen_graph(p_fout);
}

const Terminal * FuncCall::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    const Terminal * p_terminal_node;
    std::string str_node, str_param;
    int * p_params_id;  // 形参id号

    p_params_id = this->p_func_type_->get_params_type();
    for (int i = 0; i < PARAMS_SIZE; i++)
    {
        if (this->p_params_nodes_[i] != NULL)
        {
            p_terminal_node = 
                this->p_params_nodes_[i]->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
            str_node = p_terminal_node->to_string();

            str_param = p_sym_table_->get_name(p_params_id[i]);
            p_quad_table->add("=", str_node, "", str_param);
        }
    }
    p_quad_table->add("call", "", "", "L" + std::to_string(this->func_labe_in_));
    p_quad_table->add("=", this->p_func_terminal_->to_string(), "", (Expr::get_temp_variable())->to_string());

    return Expr::get_temp_variable();
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string FuncCall::get_node_content() const
{
    return "Call " + this->func_name_ + "()";
}
