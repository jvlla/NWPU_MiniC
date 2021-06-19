#include "Op.h"
#include "SynTreeException.h"
#include "Variable.h"
#include <iostream>

Op::Op(SynNode * p_first, SynNode * p_second, Operator * p_operator, int line): Expr(line, SynNode::OP)
{
    this->p_first_ = p_first;
    this->p_first_->set_prev(this);
    this->p_second_ = p_second;
    this->p_second_->set_prev(this);
    this->p_operator_ = p_operator;
}

// 输出用于产生图的dot文件
void Op::gen_graph(std::ofstream * p_fout) const
{
    Expr::gen_graph(p_fout);
    this->p_first_->gen_graph(p_fout);
    this->p_second_->gen_graph(p_fout);
}

const Terminal * Op::gen_ir(int label_in, int label_out, int label_ret, TempVariable * temp_ret, 
    QuadTable * p_quad_table)
{
    const Terminal * ret_terminal_1, * ret_terminal_2;  // 子节点返回对象
    std::string arg_1, arg_2, result;  // 输出到四元式的字符串

    result = Expr::get_temp_variable()->to_string();
    // 只有当&&, ||情况下需要考虑短路求值，因为只有这两种情况下一个节点的值就可能决定返回值
    if (this->p_operator_->get_type() != Operator::BINARY_AND 
        && this->p_operator_->get_type() != Operator::BINARY_OR)
    {
        ret_terminal_1 = 
            this->p_first_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        ret_terminal_2 = 
            this->p_second_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
        arg_1 = ret_terminal_1->to_string();
        arg_2 = ret_terminal_2->to_string();
        switch (this->p_operator_->get_type())
        {
            // 加减乘除、赋值类似，无需进行跳转，顺序执行
            case Operator::BINARY_ASSIGN:
                // 如果两边都是一维数组
                // 其实不应该一次性判断是Variable节点和是array型的Variable节点，因为求值顺序不一定，
                // 强制类型转换可能会出错，不过没那么严谨了，方便一点
                if ((ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ret_terminal_2->get_node_type() == SynNode::VARIABLE)
                    && (((Variable *) ret_terminal_1)->is_arr() && ((Variable *) ret_terminal_2)->is_arr()))
                {
                    TempVariable * p_new_temp = new TempVariable(SynNode::get_line());

                    // a = b[c] 翻译为 (=[], b[c], -, a), 见曾老师PPT Ch05-5
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    // b[c] = a 翻译为 ([]=, a, -, b[c])
                    p_quad_table->add("[]=", p_new_temp->to_string(), ""
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]");
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", result);
                }
                // 如果左边是一维数组
                else if (ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_1)->is_arr())
                {
                    p_quad_table->add("[]=", arg_2, ""
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]");
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", result);
                }
                // 如果右边是一维数组
                else if (ret_terminal_2->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_2)->is_arr())
                {
                    TempVariable * p_new_temp = new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("=", p_new_temp->to_string(), "", arg_1);
                    p_quad_table->add("=", arg_1, "", result);
                }
                // 如果两边都不是数组
                else
                {
                    p_quad_table->add("=", arg_2, "", arg_1);
                    p_quad_table->add("=", arg_1, "", result);
                }
                break;
            case Operator::BINARY_ADD:
                // 如果两边都是一维数组
                if ((ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ret_terminal_2->get_node_type() == SynNode::VARIABLE)
                    && (((Variable *) ret_terminal_1)->is_arr() && ((Variable *) ret_terminal_2)->is_arr()))
                {
                    TempVariable * p_new_temp_1 = new TempVariable(SynNode::get_line());
                    TempVariable * p_new_temp_2 = new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_1->to_string());
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_2->to_string());
                    p_quad_table->add("+", p_new_temp_1->to_string(), p_new_temp_2->to_string(), result);
                }
                // 如果左边是一维数组
                else if (ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_1)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("+", p_new_temp->to_string(), arg_2, result);
                }
                // 如果右边是一维数组
                else if (ret_terminal_2->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_2)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("+", arg_1, p_new_temp->to_string(), result);
                }
                else
                    p_quad_table->add("+", arg_1, arg_2, result);
                break; 
            case Operator::BINARY_SUB:
                // 如果两边都是一维数组
                if ((ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ret_terminal_2->get_node_type() == SynNode::VARIABLE)
                    && (((Variable *) ret_terminal_1)->is_arr() && ((Variable *) ret_terminal_2)->is_arr()))
                {
                    TempVariable * p_new_temp_1 = new TempVariable(SynNode::get_line());
                    TempVariable * p_new_temp_2 = new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_1->to_string());
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_2->to_string());
                    p_quad_table->add("-", p_new_temp_1->to_string(), p_new_temp_2->to_string(), result);
                }
                // 如果左边是一维数组
                else if (ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_1)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("-", p_new_temp->to_string(), arg_2, result);
                }
                // 如果右边是一维数组
                else if (ret_terminal_2->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_2)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("-", arg_1, p_new_temp->to_string(), result);
                }
                else
                    p_quad_table->add("-", arg_1, arg_2, result);
                break; 
            case Operator::BINARY_MUL:
                // 如果两边都是一维数组
                if ((ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ret_terminal_2->get_node_type() == SynNode::VARIABLE)
                    && (((Variable *) ret_terminal_1)->is_arr() && ((Variable *) ret_terminal_2)->is_arr()))
                {
                    TempVariable * p_new_temp_1 = new TempVariable(SynNode::get_line());
                    TempVariable * p_new_temp_2 = new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_1->to_string());
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_2->to_string());
                    p_quad_table->add("*", p_new_temp_1->to_string(), p_new_temp_2->to_string(), result);
                }
                // 如果左边是一维数组
                else if (ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_1)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("*", p_new_temp->to_string(), arg_2, result);
                }
                // 如果右边是一维数组
                else if (ret_terminal_2->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_2)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("*", arg_1, p_new_temp->to_string(), result);
                }
                else
                    p_quad_table->add("*", arg_1, arg_2, result);
                break; 
            case Operator::BINARY_DIV:
                // 如果两边都是一维数组
                if ((ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ret_terminal_2->get_node_type() == SynNode::VARIABLE)
                    && (((Variable *) ret_terminal_1)->is_arr() && ((Variable *) ret_terminal_2)->is_arr()))
                {
                    TempVariable * p_new_temp_1 = new TempVariable(SynNode::get_line());
                    TempVariable * p_new_temp_2 = new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_1->to_string());
                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp_2->to_string());
                    p_quad_table->add("/", p_new_temp_1->to_string(), p_new_temp_2->to_string(), result);
                }
                // 如果左边是一维数组
                else if (ret_terminal_1->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_1)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_1)->get_name() + "[" + ((Variable *) ret_terminal_1)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("/", p_new_temp->to_string(), arg_2, result);
                }
                // 如果右边是一维数组
                else if (ret_terminal_2->get_node_type() == SynNode::VARIABLE
                    && ((Variable *) ret_terminal_2)->is_arr())
                {
                    TempVariable * p_new_temp= new TempVariable(SynNode::get_line());

                    p_quad_table->add("=[]"
                        , ((Variable *) ret_terminal_2)->get_name() + "[" + ((Variable *) ret_terminal_2)->get_dim_terminal()->to_string() + "]"
                        , "", p_new_temp->to_string());
                    p_quad_table->add("/", arg_1, p_new_temp->to_string(), result);
                }
                else
                    p_quad_table->add("/", arg_1, arg_2, result);
                break; 
            // >, <, >=, <=, ==, != 六种类似，以>为例，类似if(arg_1 > arg_2) result = 1 else result = 0
            // 使用quad_if_else()函数
            // 这些与短路求值无关，就是正常的if else判断
            case Operator::BINARY_GREATER:
                quad_if_else(arg_1, arg_2, result, "JG", p_quad_table);
                break;
            case Operator::BINARY_LESS:
                quad_if_else(arg_1, arg_2, result, "JL", p_quad_table);
                break;
            case Operator::BINARY_GREATER_EQUAL:
                quad_if_else(arg_1, arg_2, result, "JGE", p_quad_table);
                break;
            case Operator::BINARY_LESS_EQUAL:
                quad_if_else(arg_1, arg_2, result, "JLE", p_quad_table);
                break;
            case Operator::BINARY_EQUAL:
                quad_if_else(arg_1, arg_2, result, "JE", p_quad_table);
                break;
            case Operator::BINARY_NOT_EQUAL:
                quad_if_else(arg_1, arg_2, result, "JNE", p_quad_table);
                break;
            default:
                throw new SynTreeException("Illegal unary operator", SynNode::get_line());
                break;
        }
    }
    else
    {
        long label[5];
        for (int i = 0; i < 5; i++)
            label[i] = SynNode::get_new_label();
        // 以&&为例，这个翻译类似于if(a!=0){再对b判断} else r=0; 是两个if嵌套
        if (this->p_operator_->get_type() == Operator::BINARY_AND)
        {
            ret_terminal_1 = 
                this->p_first_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
            arg_1 = ret_terminal_1->to_string();
            p_quad_table->add("JNZ", arg_1, "", "L" + std::to_string(label[0]));
            p_quad_table->add_jump_label(label[3]);
            p_quad_table->add_label(label[0]);
            // ----进入内层if并对arg_2进行求值，这样在外层为假时不需要执行内层运算，是短路求值
            ret_terminal_2 = 
                this->p_second_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
            arg_2 = ret_terminal_2->to_string();
            p_quad_table->add("JNZ", arg_2, "", "L" + std::to_string(label[1]));
            p_quad_table->add_jump_label(label[2]);
            p_quad_table->add_label(label[1]);
            p_quad_table->add("=", "1", "", result);
            p_quad_table->add_jump_label(label[4]);
            p_quad_table->add_label(label[2]);
            // 这个可以不需要直接顺序执行
            // p_quad_table->add("=", "0", "", result);
            // p_quad_table->add_jump_label(label[4]);
            // ----内层if结束
            p_quad_table->add_label(label[3]);
            p_quad_table->add("=", "0", "", result);
            p_quad_table->add_label(label[4]);
        }
        else
        {
            // 基本同上，改变判断条件及赋值结果
            ret_terminal_1 = 
                this->p_first_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
            arg_1 = ret_terminal_1->to_string();
            p_quad_table->add("JZ", arg_1, "", "L" + std::to_string(label[0]));
            p_quad_table->add_jump_label(label[3]);
            p_quad_table->add_label(label[0]);
            // ----进入内层if并对arg_2进行求值，这样在外层为假时不需要执行内层运算，是短路求值
            ret_terminal_2 = 
                this->p_second_->gen_ir(label_in, label_out, label_ret, temp_ret, p_quad_table);
            arg_2 = ret_terminal_2->to_string();
            p_quad_table->add("JZ", arg_2, "", "L" + std::to_string(label[1]));
            p_quad_table->add_jump_label(label[2]);
            p_quad_table->add_label(label[1]);
            p_quad_table->add("=", "0", "", result);
            p_quad_table->add_jump_label(label[4]);
            p_quad_table->add_label(label[2]);
            // ----内层if结束
            p_quad_table->add_label(label[3]);
            p_quad_table->add("=", "1", "", result);
            p_quad_table->add_label(label[4]);
        }
    }
    
    return Expr::get_temp_variable();
}

// 被emit_node()调用，返回可以在图中以文字显示的节点内容
std::string Op::get_node_content() const
{
    return this->p_operator_->to_string();
}